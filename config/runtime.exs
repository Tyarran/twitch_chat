import Config

%{values: dotenv} = Dotenv.load()

config :twitch_chat,
  nick: "tyarran",
  host: "irc.chat.twitch.tv",
  port: 6697,
  client_id: dotenv["TWITCH_CLIENT_ID"],
  client_secret: dotenv["TWITCH_CLIENT_SECRET"],
  auth_server_port: 3000
