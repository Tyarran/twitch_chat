defmodule TwitchChat.Commands.RoomstateParser do
  @moduledoc """
    Twitch chat CLEARMSG command
  """
  alias TwitchChat.Commands.RoomstateCommand
  alias TwitchChat.Tags.RoomstateTags

  def parse(%ExIRC.Message{cmd: cmd, args: [args]}) do
    [_, _, channel] = String.split(args, " ")
    tags = parse_tags(cmd)

    %RoomstateCommand{
      tags: tags,
      channel: channel,
      cmd: :roomstate
    }
  end

  defp parse_tags(cmd) do
    cmd
    |> String.split(";")
    |> Enum.map(fn item ->
      item
      |> String.split("=")
      |> parse_value
    end)
    |> Map.new()
    |> RoomstateTags.build()
  end

  defp parse_value(["@" <> key, value]), do: {key, value}
  defp parse_value([key, value]), do: {key, value}
end
