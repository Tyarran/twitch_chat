defmodule TwitchChat.Application do
  @moduledoc """
      TwitchChat application
  """
  alias TwitchChat.OAuth.AuthCodeHandler
  alias TwitchChat.Registry
  # alias TwitchChat.TwitchHandler

  def start(_type, _args) do
    if Application.fetch_env!(:twitch_chat, :env) != :test do
      children = [
        Registry,
        AuthCodeHandler,
        {TwitchChat.ExampleBot, "tyarran"}
        # {TwitchHandler, Application.fetch_env!(:twitch_chat, :nick)}
      ]

      opts = [strategy: :one_for_one, name: TwitchChat.Supervisor]
      Supervisor.start_link(children, opts)
    else
      Supervisor.start_link([], strategy: :one_for_one, name: TwitchChat.Supervisor)
    end
  end
end
