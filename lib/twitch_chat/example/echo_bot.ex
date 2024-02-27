defmodule TwitchChat.Example.EchoBot do
  @moduledoc """
    Example echo bot using TwitchChat.Client
  """
  use GenServer

  require Logger

  alias TwitchChat.Client
  alias TwitchChat.Message

  # Client

  def start_link(client) do
    Logger.info("Starting echo bot")
    GenServer.start_link(__MODULE__, %{client: client})
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

  def handle_info({:connected, server, port}, state) do
    Logger.info("connected to #{server}:#{port}")
    pass = Application.get_env(:twitch_chat, :pass)
    :ok = Client.logon(state.client, pass, "tyarran")
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

  def handle_info({:received, %Message{cmd: :privmsg} = message}, state) do
    console("#{message.nick}: #{message.args.message}", &IO.ANSI.blue/0)
    {:noreply, state}
  end

  def handle_info({:received, %Message{cmd: :roomstate} = message}, state) do
    console("roomstate : #{message.args.channel}", &IO.ANSI.yellow/0)
    console("#{inspect(message.tags)}", &IO.ANSI.yellow/0)
    {:noreply, state}
  end

  def handle_info({:received, %Message{cmd: :userstate} = message}, state) do
    console("userstate : #{message.args.channel}", &IO.ANSI.yellow/0)
    console("#{inspect(message.tags)}", &IO.ANSI.yellow/0)
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
