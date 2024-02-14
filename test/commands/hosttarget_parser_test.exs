defmodule HosttargetParserTest do
  use ExUnit.Case, async: true

  alias TwitchChat.Commands.HosttargetCommand
  alias TwitchChat.Commands.HosttargetParser

  test "parse with channel" do
    message = %ExIRC.Message{
      server: [],
      nick: [],
      user: [],
      host: [],
      ctcp: false,
      cmd: "",
      args: ["tmi.twitch.tv HOSTTARGET #abc :xyz 10"]
    }

    result = HosttargetParser.parse(message)

    assert result == %HosttargetCommand{
             hosting_channel: "#abc",
             channel: "xyz",
             number_of_viewers: 10,
             cmd: :hosttarget
           }
  end

  test "parse without channel" do
    message = %ExIRC.Message{
      server: [],
      nick: [],
      user: [],
      host: [],
      ctcp: false,
      cmd: "",
      args: ["tmi.twitch.tv HOSTTARGET #abc :- 10"]
    }

    result = HosttargetParser.parse(message)

    assert result == %HosttargetCommand{
             hosting_channel: "#abc",
             channel: "-",
             number_of_viewers: 10,
             cmd: :hosttarget
           }
  end
end
