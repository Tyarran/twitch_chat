defmodule ClearchatParserTest do
  use ExUnit.Case, async: true

  alias TwitchChat.Commands.ClearchatCommand
  alias TwitchChat.Commands.ClearchatParser
  alias TwitchChat.Tags.ClearchatTags

  test "parse permaban" do
    message = %ExIRC.Message{
      server: [],
      nick: [],
      user: [],
      host: [],
      ctcp: false,
      cmd: "@room-id=12345678;target-user-id=87654321;tmi-sent-ts=1642715756806",
      args: ["tyarran!tyarran@tyarran.tmi.twitch.tv CLEARCHAT #dallas :HeyGuys"]
    }

    result = ClearchatParser.parse(message)

    assert result == %ClearchatCommand{
             tags: %ClearchatTags{
               ban_duration: nil,
               room_id: "12345678",
               target_user_id: "87654321",
               tmi_sent_ts: "1642715756806"
             },
             channel: "#dallas",
             user: "HeyGuys",
             cmd: :clearchat
           }
  end

  test "parse clear all messages" do
    message = %ExIRC.Message{
      server: [],
      nick: [],
      user: [],
      host: [],
      ctcp: false,
      cmd: "@room-id=12345678;tmi-sent-ts=1642715695392",
      args: ["tmi.twitch.tv CLEARCHAT #dallas"]
    }

    result = ClearchatParser.parse(message)

    assert result == %ClearchatCommand{
             tags: %ClearchatTags{
               ban_duration: nil,
               room_id: "12345678",
               target_user_id: nil,
               tmi_sent_ts: "1642715695392"
             },
             channel: "#dallas",
             user: nil,
             cmd: :clearchat
           }
  end

  test "parse clear all messages of given user" do
    message = %ExIRC.Message{
      server: [],
      nick: [],
      user: [],
      host: [],
      ctcp: false,
      cmd: "@ban-duration=350;room-id=12345678;target-user-id=87654321;tmi-sent-ts=1642719320727",
      args: ["tmi.twitch.tv CLEARCHAT #dallas :ronni"]
    }

    result = ClearchatParser.parse(message)

    assert result == %ClearchatCommand{
             tags: %ClearchatTags{
               ban_duration: "350",
               room_id: "12345678",
               target_user_id: "87654321",
               tmi_sent_ts: "1642719320727"
             },
             channel: "#dallas",
             user: "ronni",
             cmd: :clearchat
           }
  end
end
