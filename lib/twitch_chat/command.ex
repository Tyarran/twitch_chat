defmodule TwitchChat.Command do
  @moduledoc """
    TwitchChat.Command
  """
  def clear(channel) do
    "PRIVMSG #{channel} :/clear\r\n"
    # "PRIVMSG :/clear\r\n"
  end

  def help(channel) do
    "PRIVMSG #{channel} :/help"
  end
end
