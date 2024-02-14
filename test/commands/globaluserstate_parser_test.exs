defmodule GlobaluserstateParserTest do
  use ExUnit.Case, async: true

  alias TwitchChat.Commands.GlobaluserstateCommand
  alias TwitchChat.Commands.GlobaluserstateParser
  alias TwitchChat.Tags.GlobaluserstateTags

  test "parse" do
    message = %ExIRC.Message{
      server: [],
      nick: [],
      user: [],
      host: [],
      ctcp: false,
      cmd:
        "@badge-info=subscriber/8;badges=subscriber/6;color=#0D4200;display-name=dallas;emote-sets=0,33,50,237,793,2126,3517,4578,5569,9400,10337,12239;turbo=0;user-id=12345678;user-type=admin",
      args: ["tmi.twitch.tv GLOBALUSERSTATE"]
    }

    result = GlobaluserstateParser.parse(message)

    assert result == %GlobaluserstateCommand{
             tags: %GlobaluserstateTags{
               badge_info: "subscriber/8",
               badges: "subscriber/6",
               color: "#0D4200",
               display_name: "dallas",
               emote_sets: "0,33,50,237,793,2126,3517,4578,5569,9400,10337,12239",
               turbo: "0",
               user_id: "12345678",
               user_type: "admin"
             },
             cmd: :globaluserstate
           }
  end
end
