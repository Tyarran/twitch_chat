defmodule TwitchChat.Commands.HosttargetParser do
  @moduledoc """
    Twitch chat HOSTTARGET command
  """
  alias TwitchChat.Commands.HosttargetCommand

  def parse(%ExIRC.Message{args: [args]}) do
    [_, _, hosting_channel, channel, number_of_viewers] = String.split(args, " ")

    %HosttargetCommand{
      hosting_channel: hosting_channel,
      channel: parse_value(channel),
      number_of_viewers: parse_int(number_of_viewers),
      cmd: :hosttarget
    }
  end

  defp parse_value(":" <> value), do: value
  defp parse_int(value), do: String.to_integer(value)
end
