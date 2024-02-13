defmodule TwitchChat.Commands.PrivmsgParser do
  @moduledoc """
    Parse Twitch chat PRIVMSG command
  """

  alias TwitchChat.Commands
  alias TwitchChat.Tags.PrivmsgTags

  def parse(%ExIRC.Message{cmd: badge_info, args: [args]}) do
    [user, cmd, channel, msg] = String.split(args)

    %Commands.PrivmsgCommand{
      tags: parse_badge_info(badge_info),
      channel: channel,
      message: parse_message(msg),
      nick: parse_nick(user),
      cmd: parse_value("cmd", cmd)
    }
  end

  defp parse_nick(raw_user_info) do
    raw_user_info
    |> String.split("!")
    |> List.first()
  end

  defp parse_message(":" <> message), do: message

  defp parse_badge_info(badge_info) do
    badge_info
    |> String.split(";")
    |> Enum.map(fn item ->
      [key, value] = String.split(item, "=")
      {key, parse_value(key, value)}
    end)
    |> Map.new()
    |> PrivmsgTags.build()
  end

  @spec parse_value(String.t(), String.t()) :: any()
  defp parse_value("badges", value), do: String.split(value, ",")
  defp parse_value("cmd", "PRIVMSG"), do: :privmsg
  defp parse_value(_key, value), do: value
end
