defmodule TwitchChat.Commands.ClearmsgParser do
  @moduledoc """
    Twitch chat CLEARMSG command
  """
  alias TwitchChat.Commands.ClearmsgCommand
  alias TwitchChat.Tags.ClearmsgTags

  def parse(%ExIRC.Message{cmd: cmd, args: [args]}) do
    [_, _, channel | message] = String.split(args, " ")
    tags = parse_tags(cmd)

    %ClearmsgCommand{
      tags: tags,
      channel: channel,
      message: parse_message(Enum.join(message, " ")),
      cmd: :clearmsg
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
    |> ClearmsgTags.build()
  end

  defp parse_message(":" <> message), do: message
  defp parse_value(["@" <> key, value]), do: {key, value}
  defp parse_value([key, value]), do: {key, value}
end
