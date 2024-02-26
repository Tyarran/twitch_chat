defmodule TwitchChat.Application do
  @moduledoc """
      TwitchChat application
  """
  alias TwitchChat.Example.EchoBot
  alias TwitchChat.OAuth.AuthCodeHandler

  def start(_type, _args) do
    if Application.fetch_env!(:twitch_chat, :env) != :test do
      client_id = Application.fetch_env!(:twitch_chat, :client_id)
      client_secret = Application.fetch_env!(:twitch_chat, :client_secret)
      {:ok, credentials} = TwitchChat.OAuth.get_credentials(client_id, client_secret)
      pass = "oauth:" <> credentials.access_token
      Application.put_env(:twitch_chat, :pass, pass)

      children = [
        AuthCodeHandler,
        {EchoBot, pass}
      ]

      opts = [strategy: :one_for_one, name: TwitchChat.Supervisor]

      Supervisor.start_link(children, opts)
      # Supervisor.start_link([], opts)
    else
      Supervisor.start_link([], strategy: :one_for_one, name: TwitchChat.Supervisor)
    end
  end
end
