defmodule TwitchChat.Client do
  @moduledoc """
    Twitch chat backend behaviour
  """
  alias TwitchChat.Client.ExIRCClient

  defmodule Sender do
    @moduledoc """
      Sender
    """
    @enforce_keys [:nick, :host]
    defstruct @enforce_keys

    @type t :: %__MODULE__{
            nick: String.t(),
            host: String.t()
          }
  end

  @type client :: pid()
  @type event ::
          :connected
          | :logged_in
          | {:joined, String.t()}
          | {:joined, String.t(), Sender.t()}
          | {:parted, String.t()}
          | {:received, TwitchChat.Message.t()}

  @callback start_link() :: GenServer.on_start()
  @callback connect(client(), host: String.t(), port: integer()) :: :ok
  @callback logon(client(), String.t(), String.t()) :: :ok | {:error, :not_connected}
  @callback join(client(), String.t()) :: :ok | {:error, atom()}
  @callback add_handler(client(), pid()) :: :ok
  @callback cmd(client(), String.t()) :: :ok

  def start_link do
    get_impl().start_link()
  end

  def add_handler(client, module) do
    get_impl().add_handler(client, module)
  end

  def connect(client, opts \\ []) do
    if opts == [] do
      get_impl().connect(client)
    else
      get_impl().connect(client, opts)
    end
  end

  def join(client, channel) do
    get_impl().join(client, channel)
  end

  def logon(client, pass, nick) do
    get_impl().logon(client, pass, nick)
  end

  defp get_impl do
    Application.get_env(:twitch_chat, :twitch_client, ExIRCClient)
  end
end
