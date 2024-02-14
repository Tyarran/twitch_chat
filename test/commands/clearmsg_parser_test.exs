defmodule ClearmsgParserTest do
  use ExUnit.Case, async: true

  alias TwitchChat.Commands.ClearmsgCommand
  alias TwitchChat.Commands.ClearmsgParser
  alias TwitchChat.Tags.ClearmsgTags

  test "parse" do
    message = %ExIRC.Message{
      server: [],
      nick: [],
      user: [],
      host: [],
      ctcp: false,
      cmd:
        "@login=foo;room-id=;target-msg-id=94e6c7ff-bf98-4faa-af5d-7ad633a158a9;tmi-sent-ts=1642720582342",
      args: ["tmi.twitch.tv CLEARMSG #bar :what a great day"]
    }

    result = ClearmsgParser.parse(message)

    assert result == %ClearmsgCommand{
             tags: %ClearmsgTags{
               login: "foo",
               room_id: "",
               target_msg_id: "94e6c7ff-bf98-4faa-af5d-7ad633a158a9",
               tmi_sent_ts: "1642720582342"
             },
             channel: "#bar",
             message: "what a great day",
             cmd: :clearmsg
           }
  end
end
