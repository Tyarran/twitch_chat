defmodule TwitchChat.TwitchHandler do
  @moduledoc """
    ExIRC client handler for Twitch chat
  """

  use GenServer

  alias TwitchChat.Registry, as: TCRegistry

  @ignored_commands ["002", "003", "004", "366", "375", "372", "376", "CAP"]

  def start_link(nick) do
    GenServer.start_link(
      __MODULE__,
      %{bot: nil, client: nil, host: nil, port: nil, pending_messages: [], nick: nick},
      name: __MODULE__
    )
  end

  def init(state) do
    client_id = Application.fetch_env!(:twitch_chat, :client_id)
    client_secret = Application.fetch_env!(:twitch_chat, :client_secret)
    host = Application.fetch_env!(:twitch_chat, :host)
    port = Application.fetch_env!(:twitch_chat, :port)

    # OAuth
    {:ok, credentials} = TwitchChat.OAuth.get_credentials(client_id, client_secret)
    pass = "oauth:#{credentials.access_token}"
    TCRegistry.register(:pass, pass)

    {:ok, client} = ExIRC.start_link!()
    {:ok, %{state | :client => client, port: port, host: host}}
  end

  def connect do
    GenServer.cast(__MODULE__, :connect)
  end

  def add_bot(bot) do
    GenServer.cast(__MODULE__, {:add_bot, bot})
  end

  def msg(cmd, channel, message) do
    GenServer.cast(__MODULE__, {:msg, cmd, channel, message})
  end

  def logon(pass, nick) do
    GenServer.cast(__MODULE__, {:logon, pass, nick})
  end

  def join(channel) do
    GenServer.cast(__MODULE__, {:join, channel})
  end

  def handle_cast(:connect, state) do
    ExIRC.Client.add_handler(state.client, self())
    :ok = ExIRC.Client.connect_ssl!(state.client, state.host, state.port)
    {:noreply, state}
  end

  def handle_cast({:add_bot, bot}, state) do
    {:noreply, %{state | :bot => bot}}
  end

  def handle_cast({:join, channel}, state) do
    ExIRC.Client.join(state.client, channel)
    {:noreply, state}
  end

  def handle_cast({:msg, cmd, channel, message}, state) do
    if ExIRC.Client.is_logged_on?(state.client) do
      ExIRC.Client.msg(state.client, cmd, channel, message)
      {:noreply, state}
    else
      new_state = [{cmd, channel, message} | state.pending_messages]

      {:noreply, %{state | :pending_messages => new_state}}
    end
  end

  def handle_cast({:logon, pass, nick}, state) do
    ExIRC.Client.logon(state.client, pass, nick, nick, nick)
    {:noreply, state}
  end

  def handle_info({:joined, channel}, state) do
    ExIRC.Client.cmd(
      state.client,
      "CAP REQ :twitch.tv/commands twitch.tv/tags twitch.tv/membership"
    )

    state.pending_messages
    |> Enum.reverse()
    |> Enum.each(fn {cmd, channel, message} ->
      ExIRC.Client.msg(state.client, cmd, channel, message)
    end)

    broadcast({:joined, channel}, state)

    {:noreply, state}
  end

  def handle_info({:unrecognized, _, %ExIRC.Message{args: [args]} = _msg}, state) do
    [_, _cmdname | _rest] = String.split(args)

    {:noreply, state}
  end

  def handle_info({:unrecognized, command, _}, state) when command in @ignored_commands,
    do: {:noreply, state}

  def handle_info(args, state) do
    broadcast(args, state)
    {:noreply, state}
  end

  defp broadcast(data, state) do
    if state.bot do
      Process.send(state.bot, data, [])
    else
      :ok
    end
  end
end
