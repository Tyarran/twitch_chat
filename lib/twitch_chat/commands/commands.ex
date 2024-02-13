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
            cmd: String.t()
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
            cmd: String.t()
          }
  end
end
