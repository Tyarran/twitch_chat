defmodule TwitchChat.Parser.ExIRCMessageParser do
  @moduledoc """
    ExIRC Twitch message parser
  """
  alias TwitchChat.Message
  alias TwitchChat.Parser
  alias TwitchChat.Parser.CommandParser

  @behaviour TwitchChat.Parser

  @spec parse(Parser.command()) :: {:ok, Message.t()} | {:error, any()}
  @impl true
  def parse(%ExIRC.Message{args: [args], cmd: tag_string}) do
    command = String.trim(tag_string <> " :" <> args)
    CommandParser.parse(command)
  end
end
