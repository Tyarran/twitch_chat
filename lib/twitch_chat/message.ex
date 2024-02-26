defmodule TwitchChat.Message do
  @moduledoc """
    TwitchChat.Message
  """

  alias TwitchChat.Args
  alias TwitchChat.Tags

  @type tags ::
          Tags.NoticeTags.t()
          | Tags.PrivmsgTags.t()
          | Tags.UserstateTags.t()
          | Tags.ClearchatTags.t()
          | Tags.NoticeTags.t()
          | Tags.RoomstateTags.t()
          | Tags.UsernoticeTags.t()
          | Tags.WhisperTags.t()

  @type args ::
          Args.NoticeArgs.t()
          | Args.PrivmsgArgs.t()
          | Args.UserstateArgs.t()
          | Args.ClearchatArgs.t()
          | Args.NoticeArgs.t()
          | Args.RoomstateArgs.t()
          | Args.UsernoticeArgs.t()
          | Args.WhisperArgs.t()

  @type command ::
          :clearchat
          | :clearmsg
          | :globaluserstate
          | :hosttarget
          | :notice
          | :privmsg
          | :reconnect
          | :roomstate
          | :usernotice
          | :userstate
          | :whisper

  @enforce_keys [:tags, :cmd, :args, :host, :nick]
  defstruct @enforce_keys

  @type t :: %__MODULE__{
          args: args(),
          cmd: command(),
          host: String.t(),
          nick: String.t(),
          tags: tags() | nil
        }
end
