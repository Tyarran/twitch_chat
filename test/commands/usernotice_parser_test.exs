defmodule UsernoticeParserTest do
  use ExUnit.Case, async: true

  alias TwitchChat.Commands.UsernoticeCommand
  alias TwitchChat.Commands.UsernoticeParser

  test "parse" do
    message = %ExIRC.Message{
      server: [],
      nick: [],
      user: [],
      host: [],
      ctcp: false,
      cmd:
        "@badge-info=;badges=staff/1,broadcaster/1,turbo/1;color=#008000;display-name=ronni;emotes=;id=db25007f-7a18-43eb-9379-80131e44d633;login=ronni;mod=0;msg-id=resub;msg-param-cumulative-months=6;msg-param-streak-months=2;msg-param-should-share-streak=1;msg-param-sub-plan=Prime;msg-param-sub-plan-name=Prime;room-id=12345678;subscriber=1;system-msg=ronni\shas\ssubscribed\sfor\s6\smonths!;tmi-sent-ts=1507246572675;turbo=1;user-id=87654321;user-type=staff",
      args: ["tmi.twitch.tv USERNOTICE #dallas :Great stream -- keep it up!"]
    }

    result = UsernoticeParser.parse(message)

    assert result == %UsernoticeCommand{
             tags: %TwitchChat.Tags.UsernoticeTags{
               badge_info: "",
               badges: "staff/1,broadcaster/1,turbo/1",
               color: "#008000",
               display_name: "ronni",
               emotes: "",
               id: "db25007f-7a18-43eb-9379-80131e44d633",
               login: "ronni",
               mod: "0",
               msg_id: "resub",
               msg_param_cumulative_months: "6",
               msg_param_streak_months: "2",
               msg_param_should_share_streak: "1",
               msg_param_sub_plan: "Prime",
               msg_param_sub_plan_name: "Prime",
               room_id: "12345678",
               subscriber: "1",
               system_msg: "ronni has subscribed for 6 months!",
               tmi_sent_ts: "1507246572675",
               turbo: "1",
               user_id: "87654321",
               user_type: "staff"
             },
             channel: "#dallas",
             message: "Great stream -- keep it up!",
             cmd: :usernotice
           }
  end
end
