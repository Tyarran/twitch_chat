defmodule TwitchChat.Application do
  @moduledoc """
      TwitchChat application
  """
  alias TwitchChat.Example.BotSupervisor

  def start(_type, _args) do
    if Application.fetch_env!(:twitch_chat, :env) == :test do
      Supervisor.start_link([], strategy: :one_for_one, name: TwitchChat.Supervisor)
    else
      children = [BotSupervisor]
      opts = [strategy: :one_for_one, name: TwitchChat.Supervisor]
      Supervisor.start_link(children, opts)
    end
  end
end
