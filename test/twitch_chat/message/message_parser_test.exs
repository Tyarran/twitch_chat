defmodule TwitchChat.Message.MessageParserTest do
  use ExUnit.Case, async: true

  alias TwitchChat.Message.MessageParser

  setup_all do
    messages = TestUtils.load_test_data("messages.json")

    {:ok, messages: messages}
  end

  test "Parse a PRIVMSG command", context do
    command = context.messages["privmsg"]

    result = MessageParser.parse(command)

    assert result ==
             {:ok,
              {:privmsg, "#tyarran", "Hello world!", "tyarran",
               %{
                 "badge-info" => "",
                 "badges" => ["broadcaster/1", "premium/1"],
                 "client-nonce" => "0ee90d941b4964a2fdbcc5f34af0aef8",
                 "color" => "",
                 "display-name" => "tyarran",
                 "emotes" => "",
                 "first-msg" => "0",
                 "flags" => "",
                 "id" => "de217260-60f0-4ce0-86fb-8799c59ccec1",
                 "mod" => "0",
                 "returning-chatter" => "0",
                 "room-id" => "175715982",
                 "subscriber" => "0",
                 "tmi-sent-ts" => "1707758140401",
                 "turbo" => "0",
                 "user-id" => "175715982",
                 "user-type" => ""
               }}}
  end

  test "Parse a CLEARMSG command", context do
    command = context.messages["clearmsg"]

    result = MessageParser.parse(command)

    assert result ==
             {:ok,
              {:clearmsg, "#bar", "what a great day",
               %{
                 "login" => "foo",
                 "room-id" => "",
                 "target-msg-id" => "94e6c7ff-bf98-4faa-af5d-7ad633a158a9",
                 "tmi-sent-ts" => "1642720582342"
               }}}
  end

  test "Parse a CLEARCHAT command", context do
    command = context.messages["clearchat"]

    result = MessageParser.parse(command)

    assert result ==
             {:ok,
              {:clearchat, "#dallas", "ronni",
               %{
                 "room-id" => "12345678",
                 "target-user-id" => "87654321",
                 "tmi-sent-ts" => "1642715756806"
               }}}
  end

  test "Parse a CLEARCHAT command (clear all messages)", context do
    command = context.messages["clearchat_all"]

    result = MessageParser.parse(command)

    assert result ==
             {:ok,
              {:clearchat, "#tyarran",
               %{
                 "room-id" => "175715982",
                 "tmi-sent-ts" => "1709077071468"
               }}}
  end

  test "Parse a GLOBALUSERSTATE command", context do
    command = context.messages["globaluserstate"]

    result = MessageParser.parse(command)

    assert result ==
             {:ok,
              {:globaluserstate,
               %{
                 "badge-info" => "subscriber/8",
                 "badges" => ["subscriber/6"],
                 "color" => "#0D4200",
                 "display-name" => "dallas",
                 "emote-sets" => "0,33,50,237,793,2126,3517,4578,5569,9400,10337,12239",
                 "turbo" => "0",
                 "user-id" => "12345678",
                 "user-type" => "admin"
               }}}
  end

  test "Parse a HOSTTARGET command with channel arg", context do
    command = context.messages["hosttarget_with_channel"]

    result = MessageParser.parse(command)

    assert result ==
             {:ok, {:hosttarget, "abc", "xyz", 10}}
  end

  test "Parse a HOSTTARGET command without channel arg", context do
    command = context.messages["hosttarget"]

    result = MessageParser.parse(command)

    assert result ==
             {:ok, {:hosttarget, "abc", 10}}
  end

  test "Parse a ROOMSTATE command", context do
    command = context.messages["roomstate"]

    result = MessageParser.parse(command)

    assert result ==
             {:ok,
              {:roomstate, "#bar",
               %{
                 "emote-only" => "0",
                 "followers-only" => "-1",
                 "r9k" => "0",
                 "room-id" => "12345678",
                 "slow" => "0",
                 "subs-only" => "0",
                 "rituals" => "0"
               }}}
  end

  test "Parse a RECONNECT command", context do
    command = context.messages["reconnect"]

    result = MessageParser.parse(command)

    assert result == {:ok, :reconnect}
  end

  test "Parse a WHISPER command", context do
    command = context.messages["whisper"]

    result = MessageParser.parse(command)

    assert result ==
             {:ok,
              {:whisper, "foo", "petsgomoo", "hello world!",
               %{
                 "badges" => ["staff/1", "bits-charity/1"],
                 "color" => "#8A2BE2",
                 "display-name" => "PetsgomOO",
                 "emotes" => "",
                 "message-id" => "306",
                 "thread-id" => "12345678_87654321",
                 "turbo" => "0",
                 "user-id" => "87654321",
                 "user-type" => "staff"
               }}}
  end

  test "Parse a USERSTATE command", context do
    command = context.messages["userstate"]

    result = MessageParser.parse(command)

    assert result ==
             {:ok,
              {:userstate, "#dallas",
               %{
                 "badge-info" => "",
                 "badges" => ["staff/1"],
                 "color" => "#0D4200",
                 "display-name" => "ronni",
                 "emote-sets" => "0,33,50,237,793,2126,3517,4578,5569,9400,10337,12239",
                 "mod" => "1",
                 "subscriber" => "1",
                 "turbo" => "1",
                 "user-type" => "staff"
               }}}
  end

  test "Parse a USERNOTICE command", context do
    command = context.messages["usernotice"]

    result = MessageParser.parse(command)

    assert result ==
             {:ok,
              {:usernotice, "#dallas", "Great stream -- keep it up!",
               %{
                 "badge-info" => "",
                 "badges" => ["staff/1", "broadcaster/1", "turbo/1"],
                 "color" => "#008000",
                 "display-name" => "ronni",
                 "emotes" => "",
                 "id" => "db25007f-7a18-43eb-9379-80131e44d633",
                 "login" => "ronni",
                 "mod" => "0",
                 "msg-id" => "resub",
                 "msg-param-cumulative-months" => "6",
                 "msg-param-streak-months" => "2",
                 "msg-param-should-share-streak" => "1",
                 "msg-param-sub-plan" => "Prime",
                 "msg-param-sub-plan-name" => "Prime",
                 "room-id" => "12345678",
                 "subscriber" => "1",
                 "system-msg" => "ronni has subscribed for 6 months!",
                 "tmi-sent-ts" => "1507246572675",
                 "turbo" => "1",
                 "user-id" => "87654321",
                 "user-type" => "staff"
               }}}
  end

  test "Parse a NOTICE command", context do
    command = context.messages["notice"]

    result = MessageParser.parse(command)

    assert result ==
             {:ok,
              {:notice, "#bar", "The message from foo is now deleted.",
               %{
                 "msg-id" => "whisper_restricted",
                 "target-user-id" => "12345678"
               }}}
  end

  test "Try to parse an invalid command" do
    invalid_command =
      "@msg-id=whisper_restricted;target-user-id=12345678 :tmi.twitch.tv INVALIDMESSAGE #bar :This is an invalid message."

    result = MessageParser.parse(invalid_command)

    assert result == {:error, {:not_supported, "INVALIDMESSAGE"}}
  end
end
