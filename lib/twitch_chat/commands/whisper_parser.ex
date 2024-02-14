defmodule TwitchChat.Commands.WhisperParser do
  @moduledoc """
    Twitch chat HOSTTARGET command
  """
  alias TwitchChat.Commands.WhisperCommand
  alias TwitchChat.Tags.WhisperTags

  def parse(%ExIRC.Message{cmd: cmd, args: [args]}) do
    [host, _, from_user | words] = String.split(args, " ")

    %WhisperCommand{
      tags: parse_tags(cmd),
      from_user: from_user,
      to_user: parse_to_user(host),
      message: parse_message(words),
      cmd: :whisper
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
    |> WhisperTags.build()
  end

  defp parse_to_user(host) do
    host
    |> String.split("!")
    |> List.first()
  end

  defp parse_message(words) do
    words
    |> Enum.join(" ")
    |> String.trim_leading(":")
  end

  # defp parse_value(":" <> value), do: value
  # defp parse_int(value), do: String.to_integer(value)
  defp parse_value(["@" <> key, value]), do: {key, value}
  defp parse_value([key, value]), do: {key, value}
end
