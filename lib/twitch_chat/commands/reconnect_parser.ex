defmodule TwitchChat.Commands.ReconnectParser do
  @moduledoc """
    Twitch chat RECONNECT command
  """
  def parse(%ExIRC.Message{}), do: %TwitchChat.Commands.ReconnectCommand{cmd: :reconnect}
end
