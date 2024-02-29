defmodule TwitchChat.Examples.BotSupervisor do
  @moduledoc """
    Example bot supervisor
  """
  use Supervisor

  alias TwitchChat.OAuth.AuthCodeHandler

  def start_link(_init_args) do
    Supervisor.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def init(_init_args) do
    {:ok, client} = TwitchChat.Client.start_link()
    {:ok, _pid} = AuthCodeHandler.start_link(nil)

    client_id = Application.fetch_env!(:twitch_chat, :client_id)
    client_secret = Application.fetch_env!(:twitch_chat, :client_secret)
    {:ok, credentials} = TwitchChat.OAuth.get_credentials(client_id, client_secret)
    pass = "oauth:" <> credentials.access_token
    Application.put_env(:twitch_chat, :pass, pass)

    children = [
      {TwitchChat.Example.EchoBot, client}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
