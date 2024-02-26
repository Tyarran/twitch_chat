defmodule TwitchChat.MessageParser.MessageParserTest do
  use ExUnit.Case, async: true

  alias TwitchChat.Args
  alias TwitchChat.Message
  alias TwitchChat.MessageParser.ExIRCMessageParser
  alias TwitchChat.Tags

  test "Parse a PRIVMSG message" do
    exirc_message = %ExIRC.Message{
      server: [],
      nick: [],
      user: [],
      host: [],
      ctcp: false,
      cmd:
        "@badge-info=;badges=broadcaster/1,premium/1;client-nonce=0ee90d941b4964a2fdbcc5f34af0aef8;color=;display-name=tyarran;emotes=;first-msg=0;flags=;id=de217260-60f0-4ce0-86fb-8799c59ccec1;mod=0;returning-chatter=0;room-id=175715982;subscriber=0;tmi-sent-ts=1707758140401;turbo=0;user-id=175715982;user-type=",
      args: ["tyarran!tyarran@tyarran.tmi.twitch.tv PRIVMSG #tyarran :Hello world!"]
    }

    result = ExIRCMessageParser.parse(exirc_message)

    assert result ==
             {:ok,
              %Message{
                tags: %Tags.PrivmsgTags{
                  badge_info: "",
                  badges: ["broadcaster/1", "premium/1"],
                  bits: nil,
                  color: "",
                  display_name: "tyarran",
                  emotes: "",
                  id: "de217260-60f0-4ce0-86fb-8799c59ccec1",
                  mod: "0",
                  pinned_chat_paid_amount: nil,
                  pinned_chat_paid_currency: nil,
                  pinned_chat_paid_exponent: nil,
                  pinned_chat_paid_level: nil,
                  pinned_chat_paid_is_system_messsage: nil,
                  reply_parent_msg_id: nil,
                  reply_parent_user_id: nil,
                  reply_parent_display_name: nil,
                  reply_parent_msg_body: nil,
                  reply_thread_parent_msg_id: nil,
                  reply_thread_parent_user_login: nil,
                  room_id: "175715982",
                  subscriber: "0",
                  tmi_sent_ts: "1707758140401",
                  turbo: "0",
                  user_id: "175715982",
                  user_type: "",
                  vip: nil
                },
                cmd: :privmsg,
                args: %Args.PrivmsgArgs{
                  message: "Hello world!",
                  channel: "#tyarran"
                },
                host: "tyarran@tyarran.tmi.twitch.tv",
                nick: "tyarran"
              }}
  end

  test "Parse a CLEARCHAT message" do
    exirc_message = %ExIRC.Message{
      server: [],
      nick: [],
      user: [],
      host: [],
      ctcp: false,
      cmd: "@room-id=12345678;target-user-id=87654321;tmi-sent-ts=1642715756806",
      args: ["tmi.twitch.tv CLEARCHAT #dallas :ronni"]
    }

    result = ExIRCMessageParser.parse(exirc_message)

    assert result ==
             {:ok,
              %Message{
                tags: %Tags.ClearchatTags{
                  ban_duration: nil,
                  room_id: "12345678",
                  target_user_id: "87654321",
                  tmi_sent_ts: "1642715756806"
                },
                cmd: :clearchat,
                args: %Args.ClearchatArgs{channel: "#dallas", user: "ronni"},
                host: "tmi.twitch.tv",
                nick: nil
              }}
  end

  test "parse a CLEARMSG message" do
    exirc_message = %ExIRC.Message{
      server: [],
      nick: [],
      user: [],
      host: [],
      ctcp: false,
      cmd:
        "@login=foo;room-id=;target-msg-id=94e6c7ff-bf98-4faa-af5d-7ad633a158a9;tmi-sent-ts=1642720582342",
      args: ["tmi.twitch.tv CLEARMSG #bar :what a great day"]
    }

    result = ExIRCMessageParser.parse(exirc_message)

    assert result ==
             {:ok,
              %Message{
                tags: %Tags.ClearmsgTags{
                  login: "foo",
                  room_id: "",
                  target_msg_id: "94e6c7ff-bf98-4faa-af5d-7ad633a158a9",
                  tmi_sent_ts: "1642720582342"
                },
                cmd: :clearmsg,
                args: %Args.ClearmsgArgs{
                  channel: "#bar",
                  message: "what a great day"
                },
                host: "tmi.twitch.tv",
                nick: nil
              }}
  end

  test "parse a GLOBALUSERSTATE message" do
    exirc_message = %ExIRC.Message{
      server: [],
      nick: [],
      user: [],
      host: [],
      ctcp: false,
      cmd:
        "@badge-info=subscriber/8;badges=subscriber/6;color=#0D4200;display-name=dallas;emote-sets=0,33,50,237,793,2126,3517,4578,5569,9400,10337,12239;turbo=0;user-id=12345678;user-type=admin",
      args: ["tmi.twitch.tv GLOBALUSERSTATE"]
    }

    result = ExIRCMessageParser.parse(exirc_message)

    assert result ==
             {:ok,
              %Message{
                tags: %Tags.GlobaluserstateTags{
                  badge_info: "subscriber/8",
                  badges: ["subscriber/6"],
                  color: "#0D4200",
                  display_name: "dallas",
                  emote_sets: "0,33,50,237,793,2126,3517,4578,5569,9400,10337,12239",
                  turbo: "0",
                  user_id: "12345678",
                  user_type: "admin"
                },
                cmd: :globaluserstate,
                args: nil,
                host: "tmi.twitch.tv",
                nick: nil
              }}
  end

  test "parse a HOSTTARGET message with channel arg" do
    exirc_message = %ExIRC.Message{
      server: [],
      nick: [],
      user: [],
      host: [],
      ctcp: false,
      cmd: "",
      args: ["tmi.twitch.tv HOSTTARGET #abc :xyz 10"]
    }

    result = ExIRCMessageParser.parse(exirc_message)

    assert result ==
             {:ok,
              %Message{
                tags: nil,
                cmd: :hosttarget,
                args: %Args.HosttargetArgs{
                  hosting_channel: "abc",
                  channel: "xyz",
                  number_of_viewers: 10
                },
                host: "tmi.twitch.tv",
                nick: nil
              }}
  end

  test "parse a HOSTTARGET message without channel arg" do
    exirc_message = %ExIRC.Message{
      server: [],
      nick: [],
      user: [],
      host: [],
      ctcp: false,
      cmd: "",
      args: ["tmi.twitch.tv HOSTTARGET #abc 10"]
    }

    result = ExIRCMessageParser.parse(exirc_message)

    assert result ==
             {:ok,
              %Message{
                tags: nil,
                cmd: :hosttarget,
                args: %Args.HosttargetArgs{
                  hosting_channel: "abc",
                  channel: nil,
                  number_of_viewers: 10
                },
                host: "tmi.twitch.tv",
                nick: nil
              }}
  end

  test "parse a RECONNECT message" do
    irc_message = %ExIRC.Message{
      server: [],
      nick: [],
      user: [],
      host: [],
      ctcp: false,
      cmd: "",
      args: ["tmi.twitch.tv RECONNECT"]
    }

    result = ExIRCMessageParser.parse(irc_message)

    assert result ==
             {:ok,
              %Message{
                tags: nil,
                cmd: :reconnect,
                args: nil,
                host: "tmi.twitch.tv",
                nick: nil
              }}
  end

  test "parse a ROOMSTATE message" do
    exirc_message = %ExIRC.Message{
      server: [],
      nick: [],
      user: [],
      host: [],
      ctcp: false,
      cmd: "@emote-only=0;followers-only=-1;r9k=0;rituals=0;room-id=12345678;slow=0;subs-only=0",
      args: ["tmi.twitch.tv ROOMSTATE #bar"]
    }

    result = ExIRCMessageParser.parse(exirc_message)

    assert result ==
             {:ok,
              %Message{
                tags: %Tags.RoomstateTags{
                  emote_only: "0",
                  followers_only: "-1",
                  r9k: "0",
                  room_id: "12345678",
                  slow: "0",
                  subs_only: "0"
                },
                args: %Args.RoomstateArgs{
                  channel: "#bar"
                },
                host: "tmi.twitch.tv",
                nick: nil,
                cmd: :roomstate
              }}
  end

  test "parse a WHISPER message" do
    exirc_message = %ExIRC.Message{
      server: [],
      nick: [],
      user: [],
      host: [],
      ctcp: false,
      cmd:
        "@badges=staff/1,bits-charity/1;color=#8A2BE2;display-name=PetsgomOO;emotes=;message-id=306;thread-id=12345678_87654321;turbo=0;user-id=87654321;user-type=staff",
      args: ["petsgomoo!petsgomoo@petsgomoo.tmi.twitch.tv WHISPER foo :hello world!"]
    }

    result = ExIRCMessageParser.parse(exirc_message)

    assert result ==
             {:ok,
              %Message{
                tags: %Tags.WhisperTags{
                  badges: "staff/1,bits-charity/1",
                  color: "#8A2BE2",
                  display_name: "PetsgomOO",
                  emotes: "",
                  message_id: "306",
                  thread_id: "12345678_87654321",
                  turbo: "0",
                  user_id: "87654321",
                  user_type: "staff"
                },
                args: %Args.WhisperArgs{
                  from_user: "foo",
                  to_user: "petsgomoo",
                  message: "hello world!"
                },
                host: "petsgomoo@petsgomoo.tmi.twitch.tv",
                nick: "petsgomoo",
                cmd: :whisper
              }}
  end

  test "parse a USERSTATE message" do
    exirc_message = %ExIRC.Message{
      server: [],
      nick: [],
      user: [],
      host: [],
      ctcp: false,
      cmd:
        "@badge-info=;badges=staff/1;color=#0D4200;display-name=ronni;emote-sets=0,33,50,237,793,2126,3517,4578,5569,9400,10337,12239;mod=1;subscriber=1;turbo=1;user-type=staff",
      args: ["tmi.twitch.tv USERSTATE #dallas"]
    }

    result = ExIRCMessageParser.parse(exirc_message)

    assert result ==
             {:ok,
              %Message{
                tags: %Tags.UserstateTags{
                  badge_info: "",
                  badges: ["staff/1"],
                  color: "#0D4200",
                  display_name: "ronni",
                  emote_sets: "0,33,50,237,793,2126,3517,4578,5569,9400,10337,12239",
                  id: nil,
                  mod: "1",
                  subscriber: "1",
                  turbo: "1",
                  user_type: "staff"
                },
                args: %Args.UserstateArgs{
                  channel: "#dallas"
                },
                host: "tmi.twitch.tv",
                nick: nil,
                cmd: :userstate
              }}
  end

  test "parse a USERNOTICE message" do
    exirc_message = %ExIRC.Message{
      server: [],
      nick: [],
      user: [],
      host: [],
      ctcp: false,
      cmd:
        "@badge-info=;badges=staff/1,broadcaster/1,turbo/1;color=#008000;display-name=ronni;emotes=;id=db25007f-7a18-43eb-9379-80131e44d633;login=ronni;mod=0;msg-id=resub;msg-param-cumulative-months=6;msg-param-streak-months=2;msg-param-should-share-streak=1;msg-param-sub-plan=Prime;msg-param-sub-plan-name=Prime;room-id=12345678;subscriber=1;system-msg=ronni\shas\ssubscribed\sfor\s6\smonths!;tmi-sent-ts=1507246572675;turbo=1;user-id=87654321;user-type=staff",
      args: ["tmi.twitch.tv USERNOTICE #dallas :Great stream -- keep it up!"]
    }

    result = ExIRCMessageParser.parse(exirc_message)

    assert result ==
             {:ok,
              %Message{
                tags: %Tags.UsernoticeTags{
                  badge_info: "",
                  badges: ["staff/1", "broadcaster/1", "turbo/1"],
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
                args: %Args.UsernoticeArgs{
                  channel: "#dallas",
                  message: "Great stream -- keep it up!"
                },
                host: "tmi.twitch.tv",
                nick: nil,
                cmd: :usernotice
              }}
  end

  test "parse a NOTICE message" do
    exirc_message = %ExIRC.Message{
      server: [],
      nick: [],
      user: [],
      host: [],
      ctcp: false,
      cmd: "@msg-id=whisper_restricted;target-user-id=12345678",
      args: ["tmi.twitch.tv NOTICE #bar :The message from foo is now deleted."]
    }

    result = ExIRCMessageParser.parse(exirc_message)

    assert result ==
             {:ok,
              %Message{
                tags: %Tags.NoticeTags{
                  msg_id: "whisper_restricted",
                  target_user_id: "12345678"
                },
                args: %Args.NoticeArgs{
                  channel: "#bar",
                  message: "The message from foo is now deleted."
                },
                host: "tmi.twitch.tv",
                nick: nil,
                cmd: :notice
              }}
  end

  test "try to parse invalid message" do
    exirc_message = %ExIRC.Message{
      server: [],
      nick: [],
      user: [],
      host: [],
      ctcp: false,
      cmd: "@msg-id=whisper_restricted;target-user-id=12345678",
      args: ["tmi.twitch.tv INVALIDMESSAGE #bar :This is an invalid message."]
    }

    result = ExIRCMessageParser.parse(exirc_message)

    assert result == {:error, {:not_supported, "INVALIDMESSAGE"}}
  end
end
