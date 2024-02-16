defmodule TwitchChat.MessageParser do
  @moduledoc """
    Twitch message parser
  """
  alias TwitchChat.Args
  alias TwitchChat.Message
  alias TwitchChat.Tags

  @type exirc_message :: %ExIRC.Message{}

  @spec parse(exirc_message) :: {:ok, TwitchChat.Message.t()} | {:error, any()}
  def parse(%ExIRC.Message{args: [args], cmd: tag_string}) do
    [host_info, cmd | args_words] = String.split(args, " ")
    args = Enum.join(args_words, " ")
    tags = read_tags(tag_string)
    [nick, host] = parse_host_info(host_info)

    message = parse(String.upcase(cmd), nick, host, args, tags)
    {:ok, message}
  end

  def parse(%ExIRC.Message{} = message) do
    {:error, "Unknown message format: #{inspect(message)}"}
  end

  defp read_tags(""), do: %{}

  defp read_tags(tag_string) do
    tag_string
    |> String.split(";")
    |> Enum.reduce(%{}, fn item, acc ->
      [key, value] = String.split(item, "=", parts: 2)
      {formated_key, formated_value} = read_field(key, value)
      Map.put(acc, formated_key, formated_value)
    end)
  end

  defp read_field("@" <> key, value) do
    {key, value}
  end

  defp read_field("badges" = key, value), do: {key, String.split(value, ",")}

  defp read_field("tmi_sent_ts" = key, value) do
    case DateTime.from_unix(String.to_integer(value)) do
      {:ok, datetime} -> {key, datetime}
      _ -> {key, value}
    end
  end

  defp read_field(key, value), do: {key, value}

  defp parse("PRIVMSG", nick, host, raw_args, %{} = raw_tags) do
    tags = Tags.PrivmsgTags.new(raw_tags)

    [channel, msg] = String.split(raw_args, " :", parts: 2)
    args = %Args.PrivmsgArgs{channel: channel, message: msg}

    %Message{
      tags: tags,
      cmd: :privmsg,
      args: args,
      host: host,
      nick: nick
    }
  end

  defp parse("CLEARCHAT", nick, host, raw_args, %{} = raw_tags) do
    tags = Tags.ClearchatTags.new(raw_tags)

    [channel, user] = String.split(raw_args, " :", parts: 2)
    args = %Args.ClearchatArgs{channel: channel, user: user}

    %Message{
      tags: tags,
      cmd: :clearchat,
      args: args,
      host: host,
      nick: nick
    }
  end

  defp parse("CLEARMSG", nick, host, raw_args, %{} = raw_tags) do
    tags = Tags.ClearmsgTags.new(raw_tags)

    [channel, msg] = String.split(raw_args, " :", parts: 2)
    args = %Args.ClearmsgArgs{channel: channel, message: msg}

    %Message{
      tags: tags,
      cmd: :clearmsg,
      args: args,
      host: host,
      nick: nick
    }
  end

  defp parse("GLOBALUSERSTATE", nick, host, _raw_args, %{} = raw_tags) do
    tags = Tags.GlobaluserstateTags.new(raw_tags)

    %Message{
      tags: tags,
      cmd: :globaluserstate,
      args: nil,
      host: host,
      nick: nick
    }
  end

  defp parse("HOSTTARGET", nick, host, raw_args, %{} = _raw_tags) do
    args =
      case String.split(raw_args, " ") do
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
      end

    %Message{
      tags: nil,
      cmd: :hosttarget,
      args: args,
      host: host,
      nick: nick
    }
  end

  defp parse("ROOMSTATE", nick, host, channel, %{} = raw_tags) do
    tags = Tags.RoomstateTags.new(raw_tags)
    args = %Args.RoomstateArgs{channel: channel}

    %Message{
      tags: tags,
      cmd: :roomstate,
      args: args,
      host: host,
      nick: nick
    }
  end

  defp parse("RECONNECT", nick, host, _raw_args, %{} = _raw_tags) do
    %Message{
      tags: nil,
      cmd: :reconnect,
      args: nil,
      host: host,
      nick: nick
    }
  end

  defp parse("WHISPER", nick, host, raw_args, %{} = raw_tags) do
    tags = Tags.WhisperTags.new(raw_tags)
    [from_user, message] = String.split(raw_args, " :", parts: 2)
    args = %Args.WhisperArgs{from_user: from_user, to_user: nick, message: message}

    %Message{
      tags: tags,
      cmd: :whisper,
      args: args,
      host: host,
      nick: nick
    }
  end

  defp parse("USERSTATE", nick, host, channel, %{} = raw_tags) do
    tags = Tags.UserstateTags.new(raw_tags)
    args = %Args.UserstateArgs{channel: channel}

    %Message{
      tags: tags,
      cmd: :userstate,
      args: args,
      host: host,
      nick: nick
    }
  end

  defp parse("USERNOTICE", nick, host, raw_args, %{} = raw_tags) do
    tags = Tags.UsernoticeTags.new(raw_tags)
    [channel, message] = String.split(raw_args, " :", parts: 2)
    args = %Args.UsernoticeArgs{channel: channel, message: message}

    %Message{
      tags: tags,
      cmd: :usernotice,
      args: args,
      host: host,
      nick: nick
    }
  end

  defp parse("NOTICE", nick, host, raw_args, %{} = raw_tags) do
    tags = Tags.NoticeTags.new(raw_tags)
    [channel, message] = String.split(raw_args, " :", parts: 2)
    args = %Args.NoticeArgs{channel: channel, message: message}

    %Message{
      tags: tags,
      cmd: :notice,
      args: args,
      host: host,
      nick: nick
    }
  end

  defp parse_host_info(host_info) do
    case String.split(host_info, "!") do
      [host] -> [nil, host]
      [nick, host] -> [nick, host]
    end
  end
end
