defmodule TwitchChat.Commands.ReconnectParser do
  def parse(%ExIRC.Message{}) do
    %TwitchChat.Commands.ReconnectCommand{cmd: :reconnect}
  end
end
