defmodule TwitchChat.Examples.EchoBot do
  @moduledoc """
    Example echo bot using TwitchChat.Client
  """
  use GenServer

  require Logger

  alias TwitchChat.Client

  # Client

  def start_link(client) do
    Logger.info("Starting echo bot")
    GenServer.start_link(__MODULE__, %{client: client}, name: __MODULE__)
  end

  def clear(channel) do
    command = TwitchChat.Command.clear(channel)
    GenServer.cast(__MODULE__, {:send_command, command})
  end

  def help(channel) do
    command = TwitchChat.Command.help(channel)
    GenServer.cast(__MODULE__, {:send_command, command})
  end

  # Server (callbacks)

  def init(state) do
    :ok = Client.add_handler(state.client, self())

    if Client.connected?(state.client) do
      Logger.info("Already connected")
      {:ok, state}
    else
      Logger.info("Not connected, connecting")
      :ok = Client.connect(state.client, host: "irc.chat.twitch.tv", port: 6697)
      {:ok, state}
    end

    Logger.info("Echo bot is started")
    {:ok, state}
  end

  def handle_cast({:send_command, command}, state) do
    Logger.info("Sending command: #{command}")
    :ok = Client.cmd(state.client, command)
    {:noreply, state}
  end

  def handle_info({:connected, server, port}, state) do
    Logger.info("connected to #{server}:#{port}")
    pass = Application.get_env(:twitch_chat, :pass)
    :ok = Client.logon(state.client, pass, "jeanmichelchatbot")
    {:noreply, state}
  end

  def handle_info(:logged_in, state) do
    Logger.info("[bot] logged in as tyarran")
    :ok = Client.join(state.client, "#tyarran")
    {:noreply, state}
  end

  def handle_info({:joined, channel}, state) do
    Logger.info("[bot] joined channel #{channel}")
    {:noreply, state}
  end

  def handle_info({:received, {:privmsg, _channel, _msg, _nick, tags}}, state) do
    msg_id = tags["id"]
    cmd = "@reply-parent-msg-id=#{msg_id} PRIVMSG #tyarran :Bien le bonjour !"

    Client.cmd(state.client, cmd)

    {:noreply, state}
  end

  def handle_info({:received, {:userstate, channel, tags}}, state) do
    console("userstate : #{channel}", &IO.ANSI.yellow/0)
    console("#{inspect(tags)}", &IO.ANSI.yellow/0)
    {:noreply, state}
  end

  def handle_info({:received, message}, state) do
    tags = elem(message, tuple_size(message) - 1)
    msg = Tuple.delete_at(message, tuple_size(message) - 1)

    if is_map(tags) do
      console("received: #{inspect(msg)} with tags: #{inspect(tags)}", &IO.ANSI.green/0)
    else
      console("received: #{inspect(msg)}", &IO.ANSI.green/0)
    end

    {:noreply, state}
  end

  def handle_info({:joined, channel, sender}, state) do
    console("#{sender.nick} joined #{channel}", &IO.ANSI.yellow/0)
    {:noreply, state}
  end

  def handle_info({:parted, channel, sender}, state) do
    console("#{sender.nick} left #{channel}", &IO.ANSI.yellow/0)
    {:noreply, state}
  end

  def handle_info(data, state) do
    console("unhandled: #{inspect(data)}", &IO.ANSI.red/0)
    {:noreply, state}
  end

  defp console(msg, color) do
    IO.puts(color.() <> msg <> IO.ANSI.reset())
  end
end
