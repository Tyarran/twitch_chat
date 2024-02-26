import Config

config :logger, :default_formatter,
  format: "$time [$metadata][$level] $message\r\n\r\r",
  metadata: [:module]
