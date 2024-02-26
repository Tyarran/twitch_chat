ExUnit.start()

Hammox.defmock(TwitchChat.MockMessageParser, for: TwitchChat.MessageParser)
# Hammox.defmock(TwitchChat.MockBackend, for: TwitchChat.Backend)

Application.put_env(TwitchChat.MessageParser, :parse, TwitchChat.MockMessageParser)
# Application.put_env(:twitch_chat, :twitch_backend, TwitchChat.MockBackend)
