defmodule TwitchChat.MessageParser do
  @moduledoc """
    Twitch message parser
  """
  alias TwitchChat.MessageParser.ExIRCMessageParser

  @type exirc_message :: %ExIRC.Message{}

  @callback parse(exirc_message) :: {:ok, TwitchChat.Message.t()} | {:error, any()}

  @spec parse(exirc_message) :: {:ok, TwitchChat.Message.t()} | {:error, any()}
  def parse(%ExIRC.Message{} = message) do
    impl =
      Application.get_env(__MODULE__, :parse, ExIRCMessageParser)

    impl.parse(message)
  end
end
