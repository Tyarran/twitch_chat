defmodule UserstateParserTest do
  use ExUnit.Case, async: true

  alias TwitchChat.Commands.UserstateCommand
  alias TwitchChat.Commands.UserstateParser
  alias TwitchChat.Tags.UserstateTags

  test "parse" do
    message = %ExIRC.Message{
      server: [],
      nick: [],
      user: [],
      host: [],
      ctcp: false,
      cmd:
        "@badge-info=;badges=staff/1;color=#0D4200;display-name=ronni;emote-sets=0,33,50,237,793,2126,3517,4578,5569,9400,10337,12239;mod=1;subscriber=1;turbo=1;user-type=staff",
      args: ["tmi.twitch.tv USERSTATE #dallas"]
    }

    result = UserstateParser.parse(message)

    assert result == %UserstateCommand{
             tags: %UserstateTags{
               badge_info: "",
               badges: "staff/1",
               color: "#0D4200",
               display_name: "ronni",
               emote_sets: "0,33,50,237,793,2126,3517,4578,5569,9400,10337,12239",
               id: nil,
               mod: "1",
               subscriber: "1",
               turbo: "1",
               user_type: "staff"
             },
             channel: "#dallas",
             cmd: :userstate
           }
  end
end
