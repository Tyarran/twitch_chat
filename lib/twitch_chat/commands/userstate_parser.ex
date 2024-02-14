defmodule TwitchChat.Commands.UserstateParser do
  @moduledoc """
    Twitch chat NOTICE command
  """
  alias TwitchChat.Commands.UserstateCommand
  alias TwitchChat.Tags.UserstateTags

  def parse(%ExIRC.Message{cmd: cmd, args: [args]}) do
    [_, _, channel] = String.split(args, " ")
    tags = parse_tags(cmd)

    %UserstateCommand{
      tags: tags,
      channel: channel,
      cmd: :userstate
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
    |> UserstateTags.build()
  end

  defp parse_value(["@" <> key, value]), do: {key, value}
  defp parse_value([key, value]), do: {key, value}
end
