defmodule WebSocketBackend do
  use WebSockex

  def start_link(url) do
    WebSockex.start_link(url, __MODULE__, nil)
  end

  def init(state) do
    {:ok, %{state | server: self() |> dbg()}}
  end

  def connect(server, pass) do
    WebSockex.send_frame(server, {:text, "PASS #{pass}"})
    WebSockex.send_frame(server, {:text, "NICK tyarran"})

    WebSockex.send_frame(
      server,
      {:text, "CAP REQ :twitch.tv/membership twitch.tv/tags twitch.tv/commands"}
    )
  end

  def join(server, channel) do
    WebSockex.send_frame(server, {:text, "JOIN #{channel}"})
  end

  def send(server, cmd) do
    WebSockex.send_frame(server, {:text, cmd})
    # GenServer.cast(server, {:send, {type, txt}})
  end

  def handle_frame({:text, "PING" <> arguments}, state) do
    dbg("Sending PONG response")
    WebSockex.send_frame(state.server, {:text, "PONG" <> arguments})
    {:ok, state}
  end

  def handle_frame(frame, state) do
    IO.inspect(frame)
    {:ok, state}
  end

  # def handle_frame({type, msg}, state) do
  #   dbg({type, msg})
  #   {:ok, state}
  # end
  #
  # def handle_cast({:send, {type, msg} = frame}, state) do
  #   IO.puts("Sending #{type} frame with payload: #{msg}")
  #   {:reply, frame, state}
  # end
end
