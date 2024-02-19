ExUnit.start()

Hammox.defmock(TwitchChat.MockMessageParser, for: TwitchChat.MessageParser)
Hammox.defmock(TwitchChat.MockTwitchClient, for: TwitchChat.TwitchClient)

Application.put_env(TwitchChat.MessageParser, :parse, TwitchChat.MockMessageParser)
Application.put_env(:twitch_chat, :twitch_client, TwitchChat.MockTwitchClient)
