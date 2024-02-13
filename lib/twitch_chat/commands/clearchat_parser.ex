defmodule TwitchChat.Commands.ClearchatParser do
  @moduledoc """
    Parse Twitch chat CLEARCHAT command
  """
  alias TwitchChat.Commands.ClearchatCommand
  alias TwitchChat.Tags.ClearchatTags

  def parse(%ExIRC.Message{args: [args], cmd: cmd}) do
    command = parse_args(String.split(args, " "))
    tags = parse_tags(cmd)

    %ClearchatCommand{
      tags: tags,
      channel: command.channel,
      user: command.user,
      cmd: command.cmd
    }
  end

  defp parse_args([_host, cmd_name, channel, user]) do
    %ClearchatCommand{
      tags: nil,
      channel: channel,
      user: parse_value(user),
      cmd: parse_value(cmd_name)
    }
  end

  defp parse_args([_host, cmd_name, channel]) do
    %ClearchatCommand{
      tags: nil,
      channel: channel,
      user: nil,
      cmd: parse_value(cmd_name)
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
    |> ClearchatTags.build()
  end

  # defp parse_value(["cmd", "CLEARCHAT"]), do: {"cmd", :clearchat}
  defp parse_value(":" <> username), do: username
  defp parse_value("CLEARCHAT"), do: :clearchat
  defp parse_value(["@" <> key, value]), do: {key, value}
  defp parse_value([key, value]), do: {key, value}
end
