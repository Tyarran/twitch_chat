defmodule NoticeParserTest do
  use ExUnit.Case, async: true

  alias TwitchChat.Commands.NoticeCommand
  alias TwitchChat.Commands.NoticeParser

  test "parse without target_user_id" do
    message = %ExIRC.Message{
      server: [],
      nick: [],
      user: [],
      host: [],
      ctcp: false,
      cmd: "@msg-id=delete_message_success",
      args: ["tmi.twitch.tv NOTICE #bar :The message from foo is now deleted."]
    }

    result = NoticeParser.parse(message)

    assert result == %NoticeCommand{
             tags: %TwitchChat.Tags.NoticeTags{
               msg_id: "delete_message_success",
               target_user_id: nil
             },
             channel: "#bar",
             message: "The message from foo is now deleted.",
             cmd: :notice
           }
  end

  test "parse with target_user_id" do
    message = %ExIRC.Message{
      server: [],
      nick: [],
      user: [],
      host: [],
      ctcp: false,
      cmd: "@msg-id=whisper_restricted;target-user-id=12345678",
      args: ["tmi.twitch.tv NOTICE #bar :The message from foo is now deleted."]
    }

    result = NoticeParser.parse(message)

    assert result == %NoticeCommand{
             tags: %TwitchChat.Tags.NoticeTags{
               msg_id: "whisper_restricted",
               target_user_id: "12345678"
             },
             channel: "#bar",
             message: "The message from foo is now deleted.",
             cmd: :notice
           }
  end
end
