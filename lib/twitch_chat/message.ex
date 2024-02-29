defmodule TwitchChat.Message do
  @moduledoc """
    TwitchChat.Message
  """

  alias TwitchChat.Message.MessageParser

  @type t ::
          :reconnect
          | {:clearchat, String.t(), String.t(), map()}
          | {:clearchat, String.t(), map()}
          | {:clearmsg, String.t(), String.t(), map()}
          | {:globaluserstate, map()}
          | {:hosttarget, String.t(), String.t(), non_neg_integer()}
          | {:hosttarget, String.t(), non_neg_integer()}
          | {:notice, String.t(), String.t(), map()}
          | {:privmsg, String.t(), String.t(), String.t(), map()}
          | {:roomstate, String.t(), map()}
          | {:usernotice, String.t(), String.t(), map()}
          | {:userstate, String.t(), map()}
          | {:whisper, String.t(), String.t(), String.t(), map()}

  @callback parse(String.t()) :: {:ok, t()} | {:error, atom()}

  def parse(%ExIRC.Message{args: [args], cmd: tag_string}) do
    command = String.trim(tag_string <> " :" <> args)
    impl = Application.get_env(:twitch_chat, :twitch_message, MessageParser)
    impl.parse(command)
  end
end
