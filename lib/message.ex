defmodule TwitchChat.Message do
  @moduledoc """
    TwitchChat.Message
  """

  alias TwitchChat.Tags

  defmodule Sender do
    @moduledoc """
      TwitchChat.Message.Sender
    """

    @enforce_keys [:name, :host, :nick]
    defstruct @enforce_keys

    @type t :: %__MODULE__{
            name: String.t(),
            host: String.t(),
            nick: String.t()
          }
  end

  @type tags ::
          Tags.NoticeTags.t()
          | Tags.PrivmsgTags.t()
          | Tags.UserstateTags.t()
          | Tags.ClearchatTags.t()
          | Tags.NoticeTags.t()
          | Tags.RoomstateTags.t()
          | Tags.UsernoticeTags.t()
          | Tags.WhisperTags.t()

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

  @enforce_keys [:tags, :cmd, :args, :sender]
  defstruct @enforce_keys

  @type t :: %__MODULE__{
          tags: tags(),
          cmd: command(),
          args: list(String.t()),
          sender: Sender.t()
        }
end
