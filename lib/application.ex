defmodule TwitchChat.Application do
  def start(_type, _args) do
    TwitchChat.OAuth.AuthCodeHandler.start_link()
  end
end
