defmodule ReconnectParserTest do
  use ExUnit.Case, async: true

  alias TwitchChat.Commands.ReconnectCommand
  alias TwitchChat.Commands.ReconnectParser

  test "parse with channel" do
    message = %ExIRC.Message{
      server: [],
      nick: [],
      user: [],
      host: [],
      ctcp: false,
      cmd: "",
      args: ["tmi.twitch.tv RECONNECT"]
    }

    result = ReconnectParser.parse(message)

    assert result == %ReconnectCommand{cmd: :reconnect}
  end
end
