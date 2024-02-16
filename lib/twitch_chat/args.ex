defmodule TwitchChat.Args do
  @moduledoc """
    Privmsg arguments
  """
  defmodule PrivmsgArgs do
    @moduledoc """
      PRIVMSG arguments
    """

    @enforce_keys [:message, :channel]
    defstruct @enforce_keys

    @type t :: %__MODULE__{
            message: String.t(),
            channel: String.t()
          }
  end

  defmodule ClearchatArgs do
    @moduledoc """
      CLEARCHAT arguments
    """

    @enforce_keys [:channel, :user]
    defstruct @enforce_keys

    @type t :: %__MODULE__{
            channel: String.t(),
            user: String.t() | nil
          }
  end

  defmodule ClearmsgArgs do
    @moduledoc """
      ClearmsgTags arguments
    """

    @enforce_keys [:message, :channel]
    defstruct @enforce_keys

    @type t :: %__MODULE__{
            message: String.t(),
            channel: String.t()
          }
  end

  defmodule HosttargetArgs do
    @moduledoc """
      HOSTTARGET arguments
    """

    @enforce_keys [:hosting_channel, :channel, :number_of_viewers]
    defstruct @enforce_keys

    @type t :: %__MODULE__{
            hosting_channel: String.t(),
            channel: String.t(),
            number_of_viewers: String.t()
          }
  end

  defmodule RoomstateArgs do
    @moduledoc """
      ROOMSTATE arguments
    """

    @enforce_keys [:channel]
    defstruct @enforce_keys

    @type t :: %__MODULE__{
            channel: String.t()
          }
  end

  defmodule WhisperArgs do
    @moduledoc """
      WHISPER arguments
    """

    @enforce_keys [:from_user, :to_user, :message]
    defstruct @enforce_keys

    @type t :: %__MODULE__{
            from_user: String.t(),
            to_user: String.t(),
            message: String.t()
          }
  end

  defmodule UserstateArgs do
    @moduledoc """
      USERSTATE arguments
    """

    @enforce_keys [:channel]
    defstruct @enforce_keys

    @type t :: %__MODULE__{
            channel: String.t()
          }
  end

  defmodule UsernoticeArgs do
    @moduledoc """
      USERNOTICE arguments
    """

    @enforce_keys [:channel, :message]
    defstruct @enforce_keys

    @type t :: %__MODULE__{
            channel: String.t(),
            message: String.t()
          }
  end

  defmodule NoticeArgs do
    @moduledoc """
      NOTICE arguments
    """

    @enforce_keys [:channel, :message]
    defstruct @enforce_keys

    @type t :: %__MODULE__{
            channel: String.t(),
            message: String.t()
          }
  end
end
