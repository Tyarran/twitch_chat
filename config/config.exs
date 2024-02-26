import Config

config :twitch_chat, :env, Mix.env()

import_config "#{config_env()}.exs"
