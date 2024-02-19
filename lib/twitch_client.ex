defmodule TwitchChat.TwitchClient do
  @moduledoc """
    TwitchChat.TwitchClient
  """

  alias TwitchChat.TwitchClient.ExIRCClient

  @type client :: pid()

  @callback run() :: {:ok, client()} | {:error, any()}
  @callback add_handler(client(), pid()) :: :ok
  @callback connect(client(), String.t(), non_neg_integer()) :: :ok
  @callback join(client(), String.t()) :: :ok | {:error, atom()}
  @callback cmd(client(), String.t()) :: :ok | {:error, atom()}
  @callback msg(client(), atom(), String.t(), String.t()) :: :ok | {:error, atom()}
  @callback logon(client(), String.t(), String.t()) :: :ok | {:error, :not_connected}
  @callback logged_on?(client()) :: boolean()

  def run do
    get_impl().run()
  end

  def add_handler(client, handler) do
    get_impl().add_handler(client, handler)
  end

  def connect(client, host, port) do
    get_impl().connect(client, host, port)
  end

  def join(client, channel) do
    get_impl().join(client, channel)
  end

  def cmd(client, cmd) do
    get_impl().cmd(client, cmd)
  end

  def msg(client, cmd, channel, message) do
    get_impl().msg(client, cmd, channel, message)
  end

  def logon(client, pass, nick) do
    get_impl().logon(client, pass, nick)
  end

  def logged_on?(client) do
    get_impl().logged_on?(client)
  end

  defp get_impl do
    Application.get_env(:twitch_chat, :twitch_client, ExIRCClient)
  end
end
