defmodule TwitchChat.Commands do
  defmodule PrivmsgCommand do
    @moduledoc """
      Twitch chat privmsg command
    """
    alias TwitchChat.Tags.PrivmsgTags

    @enforce_keys [:tags, :channel, :message, :nick, :cmd]

    defstruct @enforce_keys

    @type t :: %__MODULE__{
            tags: PrivmsgTags.t(),
            channel: String.t(),
            message: String.t(),
            nick: String.t(),
            cmd: :privmsg
          }
  end

  defmodule ClearchatCommand do
    @moduledoc """
      Twitch chat clearchat command
    """
    alias TwitchChat.Tags.ClearchatTags

    @enforce_keys [:tags, :channel, :user, :cmd]

    defstruct @enforce_keys

    @type t :: %__MODULE__{
            tags: ClearchatTags.t(),
            channel: String.t(),
            user: String.t(),
            cmd: :clearchat
          }
  end

  defmodule ClearmsgCommand do
    @moduledoc """
      Twitch chat clearmsg command
    """
    alias TwitchChat.Tags.ClearmsgTags

    @enforce_keys [:tags, :channel, :message, :cmd]

    defstruct @enforce_keys

    @type t :: %__MODULE__{
            tags: ClearmsgTags.t(),
            channel: String.t(),
            message: String.t(),
            cmd: :clearmsg
          }
  end

  defmodule GlobaluserstateCommand do
    @moduledoc """
      Twitch chat GLOBALUSERSTATE command
    """
    alias TwitchChat.Tags.GlobaluserstateTags

    @enforce_keys [:tags, :cmd]

    defstruct @enforce_keys

    @type t :: %__MODULE__{
            tags: GlobaluserstateTags.t(),
            cmd: :globaluserstate
          }
  end

  defmodule HosttargetCommand do
    @moduledoc """
      Twitch chat HOSTTARGET command
    """
    @enforce_keys [:hosting_channel, :channel, :number_of_viewers, :cmd]

    defstruct @enforce_keys

    @type t :: %__MODULE__{
            hosting_channel: String.t(),
            channel: String.t(),
            number_of_viewers: integer(),
            cmd: :hosttarget
          }
  end

  defmodule NoticeCommand do
    @moduledoc """
      Twitch chat NOTICE command
    """
    @enforce_keys [:tags, :channel, :message, :cmd]

    defstruct @enforce_keys

    @type t :: %__MODULE__{
            tags: TwitchChat.Tags.NoticeTags.t(),
            channel: String.t(),
            message: String.t(),
            cmd: :notice
          }
  end
end
