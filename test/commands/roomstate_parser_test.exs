defmodule RoomstateParserTest do
  use ExUnit.Case, async: true

  alias TwitchChat.Commands.RoomstateCommand
  alias TwitchChat.Commands.RoomstateParser

  test "parse with channel" do
    message = %ExIRC.Message{
      server: [],
      nick: [],
      user: [],
      host: [],
      ctcp: false,
      cmd: "@emote-only=0;followers-only=-1;r9k=0;rituals=0;room-id=12345678;slow=0;subs-only=0",
      args: ["tmi.twitch.tv ROOMSTATE #bar"]
    }

    result = RoomstateParser.parse(message)

    assert result == %RoomstateCommand{
             tags: %TwitchChat.Tags.RoomstateTags{
               emote_only: "0",
               followers_only: "-1",
               r9k: "0",
               room_id: "12345678",
               slow: "0",
               subs_only: "0"
             },
             channel: "#bar",
             cmd: :roomstate
           }
  end
end
