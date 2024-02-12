defmodule TwitchChat.Application do
  @moduledoc """
      TwitchChat application
  """
  alias TwitchChat.Registry
  alias TwitchChat.TwitchHandler

  def start(_type, _args) do
    if Mix.env() != :test do
      children = [
        Registry,
        {TwitchHandler, Application.fetch_env!(:twitch_chat, :nick)}
      ]

      opts = [strategy: :one_for_one, name: TwitchChat.Supervisor]
      Supervisor.start_link(children, opts)
    else
      Supervisor.start_link([], strategy: :one_for_one, name: TwitchChat.Supervisor)
    end
  end

  # def start(_type, _args) do
  #   children = [
  #     # Start the Telemetry supervisor
  #     StreamaeWeb.Telemetry,
  #     # Start the PubSub system
  #     {Phoenix.PubSub, name: Streamae.PubSub},
  #     # Start the Endpoint (http/https)
  #     StreamaeWeb.Endpoint
  #     # Start a worker by calling: Streamae.Worker.start_link(arg)
  #     # {Streamae.Worker, arg}
  #   ]
  #
  #   # See https://hexdocs.pm/elixir/Supervisor.html
  #   # for other strategies and supported options
  #   opts = [strategy: :one_for_one, name: Streamae.Supervisor]
  #   Supervisor.start_link(children, opts)
  # end
end
