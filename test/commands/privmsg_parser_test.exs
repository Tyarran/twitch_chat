defmodule PrivmsgParserTest do
  use ExUnit.Case, async: true

  alias TwitchChat.Commands.PrivmsgCommand
  alias TwitchChat.Commands.PrivmsgParser
  alias TwitchChat.Tags.PrivmsgTags

  test "parse" do
    message = %ExIRC.Message{
      server: [],
      nick: [],
      user: [],
      host: [],
      ctcp: false,
      cmd:
        "@badge-info=;badges=broadcaster/1,premium/1;client-nonce=0ee90d941b4964a2fdbcc5f34af0aef8;color=;display-name=tyarran;emotes=;first-msg=0;flags=;id=de217260-60f0-4ce0-86fb-8799c59ccec1;mod=0;returning-chatter=0;room-id=175715982;subscriber=0;tmi-sent-ts=1707758140401;turbo=0;user-id=175715982;user-type=",
      args: ["tyarran!tyarran@tyarran.tmi.twitch.tv PRIVMSG #tyarran :Hello world!"]
    }

    result = PrivmsgParser.parse(message)

    assert result == %PrivmsgCommand{
             tags: %PrivmsgTags{
               badge_info: nil,
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
             channel: "#tyarran",
             message: "Hello world!",
             nick: "tyarran",
             cmd: :privmsg
           }
  end
end
