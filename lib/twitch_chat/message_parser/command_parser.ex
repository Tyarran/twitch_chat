defmodule TwitchChat.Command.TwitchCommandParser do
  alias TwitchChat.Tags
  alias TwitchChat.Args

  @type parsing_error :: :invalid_command

  @command_regex ~r/^(?:@(?<tags>[[:graph:]]* ))?:(?<command>.*)$/u

  def parse(command) when is_binary(command) do
    with {:ok, parts} <- split_tags_command(command),
         [{:ok, {cmd, args, host, nick}}, tags] <- parse_parts(parts) do
      {:ok,
       %TwitchChat.Message{
         cmd: cmd,
         args: args,
         tags: build_tags(cmd, tags),
         host: host,
         nick: nick
       }}
    else
      [{:error, {:not_supported, _cmd}} = error, _] -> error
      {:error, _reason} = error -> error
    end
  end

  def parse(_invalid), do: {:error, :invalid_command}

  defp split_tags_command(command_string) do
    case Regex.named_captures(@command_regex, command_string) do
      %{"tags" => _tags_part, "command" => _command_part} = captures ->
        {:ok, captures}

      nil ->
        {:error, :invalid_command}
    end
  end

  defp parse_parts(parts) do
    Enum.map(parts, fn {key, part} ->
      parse_part(key, String.trim(part))
    end)
  end

  defp parse_part("command", command_string) do
    with [host_info, command_name | args] <- String.split(command_string, " ", parts: 3),
         [nick, host] <- parse_host_info(host_info),
         {:ok, {cmd, args}} <- parse_command(command_name, List.first(args, ""), nick) do
      {:ok, {cmd, args, host, nick}}
    else
      {:not_supported, cmd} -> {:error, {:not_supported, cmd}}
      :invalid_command -> {:error, :invalid_command}
    end
  end

  defp parse_part("tags", "") do
    nil
  end

  defp parse_part("tags", tags_string) do
    tags_string
    |> String.split(";")
    |> Enum.reduce(%{}, fn item, acc ->
      [key, value] = String.split(item, "=", parts: 2)
      {formated_key, formated_value} = read_field(key, value)
      Map.put(acc, formated_key, formated_value)
    end)
  end

  defp parse_command("PRIVMSG", args, _to_nick) do
    case String.split(args, " :", parts: 2) do
      [channel, msg] ->
        args = %Args.PrivmsgArgs{channel: channel, message: msg}
        {:ok, {:privmsg, args}}

      _error ->
        :invalid_command
    end
  end

  defp parse_command("CLEARCHAT", args, _to_nick) do
    case String.split(args, " :", parts: 2) do
      [channel, user] ->
        args = %Args.ClearchatArgs{channel: channel, user: user}
        {:ok, {:clearchat, args}}

      _error ->
        :invalid_command
    end
  end

  defp parse_command("CLEARMSG", args, _to_nick) do
    case String.split(args, " :", parts: 2) do
      [channel, msg] ->
        args = %Args.ClearmsgArgs{channel: channel, message: msg}
        {:ok, {:clearmsg, args}}

      _error ->
        :invalid_command
    end
  end

  defp parse_command("GLOBALUSERSTATE", _args, _to_nick) do
    {:ok, {:globaluserstate, nil}}
  end

  defp parse_command("HOSTTARGET", args, _to_nick) do
    args =
      case String.split(args, " ") do
        ["#" <> hosting_channel, ":" <> channel, number_of_viewers] ->
          %Args.HosttargetArgs{
            hosting_channel: hosting_channel,
            channel: channel,
            number_of_viewers: String.to_integer(number_of_viewers)
          }

        ["#" <> hosting_channel, number_of_viewers] ->
          %Args.HosttargetArgs{
            hosting_channel: hosting_channel,
            channel: nil,
            number_of_viewers: String.to_integer(number_of_viewers)
          }

        _error ->
          :invalid
      end

    if args == :invalid do
      :invalid_command
    else
      {:ok, {:hosttarget, args}}
    end
  end

  defp parse_command("RECONNECT", _args, _to_nick) do
    {:ok, {:reconnect, nil}}
  end

  defp parse_command("ROOMSTATE", channel, _to_nick) do
    {:ok, {:roomstate, %Args.RoomstateArgs{channel: channel}}}
  end

  defp parse_command("WHISPER", args, to_nick) do
    case String.split(args, " :", parts: 2) do
      [from_user, message] ->
        {:ok,
         {:whisper, %Args.WhisperArgs{from_user: from_user, to_user: to_nick, message: message}}}

      _error ->
        :invalid_command
    end
  end

  defp parse_command("USERSTATE", channel, _to_nick) do
    {:ok, {:userstate, %Args.UserstateArgs{channel: channel}}}
  end

  defp parse_command("USERNOTICE", args, _to_nick) do
    case String.split(args, " :", parts: 2) do
      [channel, message] ->
        {:ok, {:usernotice, %Args.UsernoticeArgs{channel: channel, message: message}}}

      _error ->
        :invalid_command
    end
  end

  defp parse_command("NOTICE", args, _to_nick) do
    case String.split(args, " :", parts: 2) do
      [channel, message] ->
        {:ok, {:notice, %Args.NoticeArgs{channel: channel, message: message}}}

      _error ->
        :invalid_command
    end
  end

  defp parse_command(invalid, _args, _to_nick) do
    {:not_supported, invalid}
  end

  defp read_field("badges" = key, value), do: {key, String.split(value, ",")}
  defp read_field(key, value), do: {key, String.replace(value, "\\s", " ")}

  defp parse_host_info(host_info) do
    case String.split(host_info, "!") do
      [host] -> [nil, host]
      [nick, host] -> [nick, host]
    end
  end

  defp build_tags(:privmsg, tags), do: Tags.PrivmsgTags.new(tags)
  defp build_tags(:clearchat, tags), do: Tags.ClearchatTags.new(tags)
  defp build_tags(:clearmsg, tags), do: Tags.ClearmsgTags.new(tags)
  defp build_tags(:globaluserstate, tags), do: Tags.GlobaluserstateTags.new(tags)
  defp build_tags(:hosttarget, _tags), do: nil
  defp build_tags(:reconnect, _tags), do: nil
  defp build_tags(:roomstate, tags), do: Tags.RoomstateTags.new(tags)
  defp build_tags(:whisper, tags), do: Tags.WhisperTags.new(tags)
  defp build_tags(:userstate, tags), do: Tags.UserstateTags.new(tags)
  defp build_tags(:usernotice, tags), do: Tags.UsernoticeTags.new(tags)
  defp build_tags(:notice, tags), do: Tags.NoticeTags.new(tags)
  defp build_tags(_invalid, _tags), do: nil
end
