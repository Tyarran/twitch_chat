defmodule TwitchChat do
  @moduledoc """
      TwitchChat
  """

  defmodule BadgeInfo do
    @moduledoc """
      Twitch chat badge info
    """
    @enforce_keys [
      :badge_info,
      :badges,
      :bits,
      :color,
      :display_name,
      :emotes,
      :id,
      :mod,
      :pinned_chat_paid_amount,
      :pinned_chat_paid_currency,
      :pinned_chat_paid_exponent,
      :pinned_chat_paid_level,
      :pinned_chat_paid_is_system_messsage,
      :reply_parent_msg_id,
      :reply_parent_user_id,
      :reply_parent_display_name,
      :reply_parent_msg_body,
      :reply_thread_parent_msg_id,
      :reply_thread_parent_user_login,
      :room_id,
      :subscriber,
      :tmi_sent_ts,
      :turbo,
      :user_id,
      :user_type,
      :vip
    ]
    defstruct @enforce_keys

    @type t :: %__MODULE__{
            badge_info: String.t() | nil,
            badges: String.t() | nil,
            bits: String.t() | nil,
            color: String.t() | nil,
            display_name: String.t() | nil,
            emotes: String.t() | nil,
            id: String.t() | nil,
            mod: String.t() | nil,
            pinned_chat_paid_amount: String.t() | nil,
            pinned_chat_paid_currency: String.t() | nil,
            pinned_chat_paid_exponent: String.t() | nil,
            pinned_chat_paid_level: String.t() | nil,
            pinned_chat_paid_is_system_messsage: String.t() | nil,
            reply_parent_msg_id: String.t() | nil,
            reply_parent_user_id: String.t() | nil,
            reply_parent_display_name: String.t() | nil,
            reply_parent_msg_body: String.t() | nil,
            reply_thread_parent_msg_id: String.t() | nil,
            reply_thread_parent_user_login: String.t() | nil,
            room_id: String.t() | nil,
            subscriber: String.t() | nil,
            tmi_sent_ts: String.t() | nil,
            turbo: String.t() | nil,
            user_id: String.t() | nil,
            user_type: String.t() | nil,
            vip: String.t()
          }

    def from_map(data) do
      %__MODULE__{
        badge_info: data["badge-info"],
        badges: data["badges"],
        bits: data["bits"],
        color: data["color"],
        display_name: data["display-name"],
        emotes: data["emotes"],
        id: data["id"],
        mod: data["mod"],
        pinned_chat_paid_amount: data["pinned-chat-paid-amount"],
        pinned_chat_paid_currency: data["pinned-chat-paid-currency"],
        pinned_chat_paid_exponent: data["pinned-chat-paid-exponent"],
        pinned_chat_paid_level: data["pinned-chat-paid-level"],
        pinned_chat_paid_is_system_messsage: data["pinned-chat-paid-is-system-messsage"],
        reply_parent_msg_id: data["reply-parent-msg-id"],
        reply_parent_user_id: data["reply-parent-user-id"],
        reply_parent_display_name: data["reply-parent-display-name"],
        reply_parent_msg_body: data["reply-parent-msg-body"],
        reply_thread_parent_msg_id: data["reply-thread-parent-msg-id"],
        reply_thread_parent_user_login: data["reply-thread-parent-user-login"],
        room_id: data["room-id"],
        subscriber: data["subscriber"],
        tmi_sent_ts: data["tmi-sent-ts"],
        turbo: data["turbo"],
        user_id: data["user-id"],
        user_type: data["user-type"],
        vip: data["vip"]
      }
    end
  end

  defmodule Message do
    @moduledoc """
      Twitch chat message
    """
    @enforce_keys [:badge_info, :channel, :message, :nick, :cmd]

    defstruct @enforce_keys

    @type t :: %__MODULE__{
            badge_info: BadgeInfo.t(),
            channel: String.t(),
            message: String.t(),
            nick: String.t(),
            cmd: String.t()
          }
  end
end
