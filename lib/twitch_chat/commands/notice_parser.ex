defmodule TwitchChat.Commands.NoticeParser do
  @moduledoc """
    Twitch chat NOTICE command
  """
  alias TwitchChat.Commands.NoticeCommand
  alias TwitchChat.Tags.NoticeTags

  def parse(%ExIRC.Message{cmd: cmd, args: [args]}) do
    [_, _, channel | message] = String.split(args, " ")
    tags = parse_tags(cmd)

    %NoticeCommand{
      tags: tags,
      channel: channel,
      message: parse_message(Enum.join(message, " ")),
      cmd: :notice
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
    |> NoticeTags.build()
  end

  defp parse_message(":" <> message), do: message
  defp parse_value(["@" <> key, value]), do: {key, value}
  defp parse_value([key, value]), do: {key, value}
end
