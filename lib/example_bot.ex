defmodule TwitchChat.ExampleBot do
  @moduledoc """
    Example bot using TwitchChat
  """
  use GenServer

  alias TwitchChat.Registry, as: TCRegistry
  alias TwitchChat.TwitchHandler

  def start_link(nick) do
    GenServer.start_link(
      __MODULE__,
      %{handler: nil, nick: nick},
      name: __MODULE__
    )
  end

  def init(state) do
    {:ok, _twitch_handler} = TwitchHandler.start_link(state.nick)
    TwitchHandler.add_bot(self())
    TwitchHandler.connect()
    {:ok, state}
  end

  def handle_info({:connected, server, port}, state) do
    debug("connected to #{server}:#{port}")

    pass = TCRegistry.get(:pass)
    :ok = TwitchHandler.logon(pass, state.nick)
    {:noreply, state}
  end

  def handle_info(:logged_in, state) do
    debug("logged in")
    :ok = TwitchHandler.join("#tyarran")
    {:noreply, state}
  end

  def handle_info({:joined, channel}, state) do
    debug("Joined #{channel}")

    choice =
      0..100
      |> Enum.random()
      |> Integer.to_string()

    Process.send_after(
      self(),
      {:random, choice},
      60_000
    )

    {:noreply, state}
  end

  def handle_info({:random, choice}, state) do
    TwitchHandler.msg(:privmsg, "#tyarran", "[bot] J'ai choisi un nombre au hasard : #{choice}")

    choice =
      0..100
      |> Enum.random()
      |> Integer.to_string()

    Process.send_after(
      self(),
      {:random, choice},
      60_000
    )

    {:noreply, state}
  end

  def handle_info({:received, message}, state) do
    debug(inspect(message))
    {:noreply, state}
  end

  def handle_info(arg, state) do
    debug("unhandled: #{inspect(arg)}")
    {:noreply, state}
  end

  defp debug(msg) do
    IO.puts(IO.ANSI.yellow() <> msg <> IO.ANSI.reset())
  end
end
