defmodule TwitchChat.MessageParser do
  @moduledoc """
    Parse Twitch chat messages
  """
  alias TwitchChat.BadgeInfo
  alias TwitchChat.Message

  def parse(%ExIRC.Message{cmd: badge_info, args: [args]} = _message) do
    [user, cmd, channel, msg] = String.split(args)

    %Message{
      badge_info: parse_badge_info(badge_info),
      channel: channel,
      message: parse_message(msg),
      nick: parse_nick(user),
      cmd: cmd
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
      {key, value}
    end)
    |> Map.new()
    |> BadgeInfo.from_map()
  end
end
