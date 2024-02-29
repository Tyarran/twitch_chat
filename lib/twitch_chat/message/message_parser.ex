defmodule TwitchChat.Message.MessageParser do
  @moduledoc """
    Twitch message parser
  """

  @behaviour TwitchChat.Message

  @type parsing_error :: :invalid_message | {:not_supported, String.t()}

  @command_regex ~r/^(?:@(?<tags>[[:graph:]]* ))?:(?<command>.*)$/u

  def parse(command) do
    with {:ok, %{"tags" => tags_part, "command" => command_part}} <- split_tags_command(command),
         {:ok, tags} <- parse_part("tags", tags_part),
         {:ok, command_result} <- parse_part("command", command_part) do
      command_with_tags =
        if tags do
          Tuple.append(command_result, tags)
        else
          command_result
        end

      {:ok, command_with_tags}
    else
      error -> error
    end
  end

  defp split_tags_command(command_string) do
    %{"tags" => _tags_part, "command" => _command_part} =
      captures = Regex.named_captures(@command_regex, command_string)

    {:ok, captures}
  end

  defp parse_part("command", command_string) do
    with [host_info, command_with_args] <- String.split(command_string, " ", parts: 2),
         [command_name, args] <- split_command_args(String.trim(command_with_args)),
         [nick, _host] <- parse_host_info(host_info),
         {:ok, _command} = result <- parse_command(command_name, args, nick) do
      result
    else
      {:error, {:not_supported, command}} -> {:error, {:not_supported, command}}
      _error -> {:error, :command_parsing_error}
    end
  end

  defp parse_part("tags", "") do
    {:ok, nil}
  end

  defp parse_part("tags", tags_string) do
    tags =
      tags_string
      |> String.split(";")
      |> Enum.reduce(%{}, fn item, acc ->
        [key, value] = String.split(item, "=", parts: 2)
        {formated_key, formated_value} = read_field(key, value)
        Map.put(acc, formated_key, formated_value)
      end)

    {:ok, tags}
  end

  defp split_command_args(command) do
    case String.split(command, " ", parts: 2) do
      [cmd] -> [cmd, ""]
      [cmd, args] -> [cmd, args]
    end
  end

  defp parse_command("PRIVMSG", args, nick) do
    [channel, msg] = String.split(args, " :", parts: 2)
    {:ok, {:privmsg, channel, msg, nick}}
  end

  defp parse_command("CLEARCHAT", args, _to_nick) do
    case String.split(args, " :", parts: 2) do
      [channel, user] ->
        {:ok, {:clearchat, channel, user}}

      [channel] ->
        {:ok, {:clearchat, channel}}
    end
  end

  defp parse_command("CLEARMSG", args, _to_nick) do
    case String.split(args, " :", parts: 2) do
      [channel, msg] ->
        {:ok, {:clearmsg, channel, msg}}
    end
  end

  defp parse_command("GLOBALUSERSTATE", _args, _to_nick) do
    {:ok, {:globaluserstate}}
  end

  defp parse_command("HOSTTARGET", args, _to_nick) do
    case String.split(args, " ") do
      ["#" <> hosting_channel, ":" <> channel, number_of_viewers] ->
        {:ok, {:hosttarget, hosting_channel, channel, String.to_integer(number_of_viewers)}}

      ["#" <> hosting_channel, number_of_viewers] ->
        {:ok, {:hosttarget, hosting_channel, String.to_integer(number_of_viewers)}}
    end
  end

  defp parse_command("RECONNECT", _args, _to_nick) do
    {:ok, :reconnect}
  end

  defp parse_command("ROOMSTATE", channel, _to_nick) do
    {:ok, {:roomstate, channel}}
  end

  defp parse_command("WHISPER", args, nick) do
    [from_user, message] = String.split(args, " :", parts: 2)
    {:ok, {:whisper, from_user, nick, message}}
  end

  defp parse_command("USERSTATE", channel, _to_nick) do
    {:ok, {:userstate, channel}}
  end

  defp parse_command("USERNOTICE", args, _to_nick) do
    [channel, message] = String.split(args, " :", parts: 2)
    {:ok, {:usernotice, channel, message}}
  end

  defp parse_command("NOTICE", args, _to_nick) do
    [channel, message] = String.split(args, " :", parts: 2)
    {:ok, {:notice, channel, message}}
  end

  defp parse_command(invalid, _args, _to_nick) do
    {:error, {:not_supported, invalid}}
  end

  defp read_field("badges" = key, value), do: {key, String.split(value, ",")}

  defp read_field(key, value) do
    formated_value =
      value
      |> String.replace("\\s", " ")
      |> String.trim()

    {key, formated_value}
  end

  defp parse_host_info(host_info) do
    case String.split(host_info, "!") do
      [host] -> [nil, host]
      [nick, host] -> [nick, host]
    end
  end
end
