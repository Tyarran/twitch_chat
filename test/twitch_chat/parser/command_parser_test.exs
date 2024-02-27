defmodule TwitchChat.Parser.CommandParserTest do
  use ExUnit.Case, async: true

  alias TwitchChat.Args
  alias TwitchChat.Message
  alias TwitchChat.Parser.CommandParser
  alias TwitchChat.Tags

  setup_all do
    commands = TestUtils.load_test_data("commands.json")

    {:ok, commands: commands}
  end

  test "Try to parse \"nil\" command" do
    result = CommandParser.parse(nil)

    assert result == {:error, :invalid_command}
  end

  test "Parse a PRIVMSG command", context do
    command = context.commands["privmsg"]

    result = CommandParser.parse(command)

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

  test "Parse a CLEARMSG command", context do
    command = context.commands["clearmsg"]

    result = CommandParser.parse(command)

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

  test "Parse a CLEARCHAT command", context do
    command = context.commands["clearchat"]

    result = CommandParser.parse(command)

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

  test "Parse a GLOBALUSERSTATE command", context do
    command = context.commands["globaluserstate"]

    result = CommandParser.parse(command)

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

  test "Parse a HOSTTARGET command with channel arg", context do
    command = context.commands["hosttarget_with_channel"]

    result = CommandParser.parse(command)

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

  test "Parse a HOSTTARGET command without channel arg", context do
    command = context.commands["hosttarget"]

    result = CommandParser.parse(command)

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

  test "Parse a ROOMSTATE command", context do
    command = context.commands["roomstate"]

    result = CommandParser.parse(command)

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

  test "Parse a RECONNECT command", context do
    command = context.commands["reconnect"]

    result = CommandParser.parse(command)

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

  test "Parse a WHISPER command", context do
    command = context.commands["whisper"]

    result = CommandParser.parse(command)

    assert result ==
             {:ok,
              %Message{
                tags: %Tags.WhisperTags{
                  badges: ["staff/1", "bits-charity/1"],
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

  test "Parse a USERSTATE command", context do
    command = context.commands["userstate"]

    result = CommandParser.parse(command)

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

  test "Parse a USERNOTICE command", context do
    command = context.commands["usernotice"]

    result = CommandParser.parse(command)

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

  test "Parse a NOTICE command", context do
    command = context.commands["notice"]

    result = CommandParser.parse(command)

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

  test "Try to parse an invalid command" do
    invalid_command =
      "@msg-id=whisper_restricted;target-user-id=12345678 :tmi.twitch.tv INVALIDMESSAGE #bar :This is an invalid message."

    result = CommandParser.parse(invalid_command)

    assert result == {:error, {:not_supported, "INVALIDMESSAGE"}}
  end
end
