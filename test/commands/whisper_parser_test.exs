defmodule WhisperParserTest do
  use ExUnit.Case, async: true

  alias TwitchChat.Commands.WhisperCommand
  alias TwitchChat.Commands.WhisperParser
  alias TwitchChat.Tags.WhisperTags

  test "parse" do
    message = %ExIRC.Message{
      server: [],
      nick: [],
      user: [],
      host: [],
      ctcp: false,
      cmd:
        "@badges=staff/1,bits-charity/1;color=#8A2BE2;display-name=PetsgomOO;emotes=;message-id=306;thread-id=12345678_87654321;turbo=0;user-id=87654321;user-type=staff",
      args: ["petsgomoo!petsgomoo@petsgomoo.tmi.twitch.tv WHISPER foo :hello world!"]
    }

    result = WhisperParser.parse(message)

    assert result == %WhisperCommand{
             tags: %WhisperTags{
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
             from_user: "foo",
             to_user: "petsgomoo",
             message: "hello world!",
             cmd: :whisper
           }
  end
end
