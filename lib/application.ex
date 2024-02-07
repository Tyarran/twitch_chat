defmodule TwitchChat.Application do
  @moduledoc """
      TwitchChat application
  """
  alias TwitchChat.OAuth.AuthCodeHandler

  def start(_type, _args) do
    AuthCodeHandler.start_link()
  end
end
