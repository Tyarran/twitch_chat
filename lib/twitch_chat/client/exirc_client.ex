defmodule TwitchChat.Client.ExIRCClient do
  @moduledoc """
    ExIRC client handler for Twitch chat
  """
  use GenServer

  require Logger

  alias TwitchChat.Client
  alias TwitchChat.Parser

  @behaviour TwitchChat.Client

  @ignored_commands ["002", "003", "004", "366", "375", "372", "376", "CAP"]

  defmodule State do
    @moduledoc """
        State for the TwitchHandler GenServer
    """
    defstruct handlers: [], backend: nil, pending_messages: [], registry: nil

    @type cmd :: :privmsg
    @type channel :: String.t()
    @type msg :: String.t()

    @type message :: {cmd(), channel(), msg()}

    @type t :: %__MODULE__{
            handlers: [pid()],
            registry: pid(),
            backend: Client.client(),
            pending_messages: [message()]
          }
  end

  # Client

  @impl true
  def start_link do
    GenServer.start_link(__MODULE__, %State{})
  end

  @impl true
  def connect(server, opts \\ [host: "irc.chat.twitch.tv", port: 6697]) do
    host = Keyword.get(opts, :host)
    port = Keyword.get(opts, :port)
    GenServer.cast(server, {:connect, host, port})
  end

  @impl true
  def logon(server, pass, nick) do
    GenServer.cast(server, {:logon, pass, nick})
  end

  @impl true
  def join(server, channel) do
    GenServer.cast(server, {:join, channel})
  end

  @impl true
  def add_handler(server, handler) do
    GenServer.call(server, {:add_handler, handler})
  end

  @impl true
  def cmd(server, cmd) do
    GenServer.cast(server, cmd)
  end

  # Server

  @impl true
  def init(state) do
    {:ok, backend} = ExIRC.Client.start_link()
    ExIRC.Client.add_handler(backend, self())
    {:ok, %{state | :backend => backend}}
  end

  @impl true
  def handle_call({:add_handler, handler}, _from, state) do
    {:reply, :ok, %{state | :handlers => [handler | state.handlers]}}
  end

  @impl true
  def handle_cast({:connect, host, port}, state) do
    Logger.debug("Connecting to Twitch")
    ExIRC.Client.connect_ssl!(state.backend, host, port)
    {:noreply, state}
  end

  def handle_cast({:logon, pass, nick}, state) do
    Logger.debug("Trying to logon")
    ExIRC.Client.logon(state.backend, pass, nick, nick, nick)
    {:noreply, state}
  end

  def handle_cast({:join, channel}, state) do
    Logger.debug("Join channel #{channel}")
    ExIRC.Client.join(state.backend, channel)
    {:noreply, state}
  end

  def handle_cast({:cmd, cmd}, state) do
    Logger.debug("Sending command: #{cmd}")
    ExIRC.Client.cmd(state.backend, cmd)
    {:noreply, state}
  end

  @impl true
  def handle_info(:logged_in = data, state) do
    ExIRC.Client.cmd(
      state.backend,
      "CAP REQ :twitch.tv/commands twitch.tv/tags twitch.tv/membership"
    )

    broadcast(data, state)
    {:noreply, state}
  end

  def handle_info({:unrecognized, command, _}, state) when command in @ignored_commands do
    Logger.warning("Ignoring command: #{command}")
    {:noreply, state}
  end

  def handle_info({:unrecognized, _, %ExIRC.Message{} = message}, state) do
    case Parser.parse(message) do
      {:ok, result} ->
        command =
          result.cmd
          |> Atom.to_string()
          |> String.upcase()

        Logger.info("Received message: #{command} -> broadcast to handlers")
        broadcast({:received, result}, state)

      {:error, {:not_supported, invalid_command}} ->
        Logger.warning("Unsupported command: #{invalid_command}")

      {:error, reason} ->
        Logger.error("Error parsing message: #{reason}")
    end

    {:noreply, state}
  end

  def handle_info(event, state)
      when elem(event, 0) in [:connected, :logged_in, :joined, :parted] do
    Logger.debug("Broadcasting event: #{inspect(event)}")
    broadcast(event, state)
    {:noreply, state}
  end

  def handle_info(event, state) do
    Logger.warning("Unhandled event: #{inspect(event)}")
    {:noreply, state}
  end

  defp broadcast(data, state) do
    case state.handlers do
      [] ->
        Logger.warning("No handlers to broadcast: #{inspect(data)}")
        :ok

      handlers ->
        Enum.each(handlers, fn handler ->
          Logger.debug("Broadcasting to handler: #{inspect(handler)}")
          Process.send(handler, data, [])
        end)
    end
  end
end
