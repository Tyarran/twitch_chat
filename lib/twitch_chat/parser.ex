defmodule TwitchChat.Parser do
  @moduledoc """
    Twitch command parser
  """
  alias TwitchChat.Parser.ExIRCMessageParser

  @type frame :: {:text, String.t()}
  @type command :: %ExIRC.Message{} | frame()

  @callback parse(command) :: {:ok, TwitchChat.Message.t()} | {:error, any()}

  @spec parse(command) :: {:ok, TwitchChat.Message.t()} | {:error, any()}
  def parse(%ExIRC.Message{} = message) do
    ExIRCMessageParser.parse(message)
  end

  def parse({:text, command}) do
    command
  end
end
