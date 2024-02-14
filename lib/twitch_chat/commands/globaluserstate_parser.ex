defmodule TwitchChat.Commands.GlobaluserstateParser do
  @moduledoc """
    Twitch chat GLOBALUSERSTATE command
  """
  alias TwitchChat.Commands.GlobaluserstateCommand
  alias TwitchChat.Tags.GlobaluserstateTags

  def parse(%ExIRC.Message{cmd: cmd}) do
    %GlobaluserstateCommand{
      tags: parse_tags(cmd),
      cmd: :globaluserstate
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
    |> GlobaluserstateTags.build()
  end

  defp parse_value(["@" <> key, value]), do: {key, value}
  defp parse_value([key, value]), do: {key, value}
end
