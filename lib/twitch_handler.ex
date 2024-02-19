defmodule TwitchChat.TwitchHandler do
  @moduledoc """
    ExIRC client handler for Twitch chat
  """
  alias TwitchChat.MessageParser
  alias TwitchChat.TwitchClient

  use GenServer

  require Logger

  # alias TwitchChat.Registry, as: TCRegistry

  @ignored_commands ["002", "003", "004", "366", "375", "372", "376", "CAP"]

  def start_link do
    GenServer.start_link(
      __MODULE__,
      %{handlers: [], client: nil, pending_messages: []},
      name: __MODULE__
    )
  end

  def init(state) do
    {:ok, client} = TwitchClient.run()
    # {:ok, client} = ExIRC.start_link!()
    {:ok, %{state | :client => client}}
  end

  # def init(state) do
  #   client_id = Application.fetch_env!(:twitch_chat, :client_id)
  #   client_secret = Application.fetch_env!(:twitch_chat, :client_secret)
  #   host = Application.fetch_env!(:twitch_chat, :host)
  #   port = Application.fetch_env!(:twitch_chat, :port)
  #
  #   # OAuth
  #   {:ok, credentials} = TwitchChat.OAuth.get_credentials(client_id, client_secret)
  #   pass = "oauth:#{credentials.access_token}"
  #   TCRegistry.register(:pass, pass)
  #
  #   {:ok, client} = ExIRC.start_link!()
  #   {:ok, %{state | :client => client, port: port, host: host}}
  # end

  def connect do
    GenServer.cast(__MODULE__, :connect)
  end

  def add_handler(bot) do
    GenServer.cast(__MODULE__, {:add_handler, bot})
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
    :ok = TwitchClient.connect(state.client, "irc.chat.twitch.tv", 6667)

    {:noreply, state}
  end

  def handle_cast({:add_handler, handler}, state) do
    handlers = Map.get(state, :handlers, [])
    new_handlers = [handler | handlers]

    {:noreply, %{state | :handlers => Enum.dedup(new_handlers)}}
  end

  def handle_cast({:join, channel}, state) do
    case TwitchClient.join(state.client, channel) do
      :ok ->
        {:noreply, state}

      {:error, reason} ->
        Logger.error("Failed to join channel #{channel}: #{reason}")
        {:stop, reason, state}
    end
  end

  def handle_cast({:msg, cmd, channel, message}, state) do
    if TwitchClient.logged_on?(state.client) do
      case TwitchClient.msg(state.client, cmd, channel, message) do
        :ok ->
          {:noreply, state}

        {:error, reason} ->
          Logger.error("Failed to send message to #{channel}: #{reason}")
          {:noreply, state}
      end
    else
      new_state = [{cmd, channel, message} | state.pending_messages]

      {:noreply, %{state | :pending_messages => new_state}}
    end
  end

  def handle_cast({:logon, pass, nick}, state) do
    case TwitchClient.logon(state.client, pass, nick) do
      :ok ->
        {:noreply, state}

      {:error, reason} ->
        Logger.error("Failed to logon: #{reason}")
        {:noreply, state}
    end
  end

  def handle_info({:joined, channel}, state) do
    TwitchClient.cmd(
      state.client,
      "CAP REQ :twitch.tv/commands twitch.tv/tags twitch.tv/membership"
    )

    state.pending_messages
    |> Enum.reverse()
    |> Enum.each(fn {cmd, channel, message} ->
      TwitchClient.msg(state.client, cmd, channel, message)
    end)

    broadcast({:joined, channel}, state)

    {:noreply, state}
  end

  def handle_info({:unrecognized, _, %ExIRC.Message{} = message}, state) do
    MessageParser.parse(message)

    {:noreply, state}
  end

  def handle_info({:unrecognized, command, _}, state) when command in @ignored_commands,
    do: {:noreply, state}

  def handle_info(args, state) do
    broadcast(args, state)
    {:noreply, state}
  end

  defp broadcast(data, state) do
    if Enum.empty?(state.handlers) do
      :ok
    else
      Enum.each(state.handlers, fn handler -> Process.send(handler, data, []) end)
    end
  end
end
