defmodule TwitchChat.Example.EchoBot do
  @moduledoc """
    Example echo bot using TwitchChat.Client
  """
  use GenServer

  require Logger

  alias TwitchChat.Client
  alias TwitchChat.Message

  # Client

  def start_link(pass) do
    Application.put_env(:twitch_chat, :pass, pass)
    GenServer.start_link(__MODULE__, %{client: nil})
  end

  # Server (callbacks)

  def init(state) do
    {:ok, client} = Client.start_link()
    :ok = Client.add_handler(client, self())
    :ok = Client.connect(client)
    {:ok, %{state | client: client}}
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

  def handle_info({:received, %Message{cmd: :roomstate}}, state) do
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
