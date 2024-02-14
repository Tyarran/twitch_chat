defmodule TwitchChat.Tags do
  defmodule PrivmsgTags do
    @moduledoc """
      Twitch chat PRIVMSG tags
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

    def build(%{} = data) do
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

  defmodule ClearchatTags do
    @moduledoc """
      Twitch chat CLEARCHAT tags
    """
    @enforce_keys [:ban_duration, :room_id, :target_user_id, :tmi_sent_ts]
    defstruct @enforce_keys

    @type t :: %__MODULE__{
            ban_duration: String.t() | nil,
            room_id: String.t() | nil,
            target_user_id: String.t() | nil,
            tmi_sent_ts: String.t() | nil
          }

    def build(%{} = data) do
      %__MODULE__{
        ban_duration: data["ban-duration"],
        room_id: data["room-id"],
        target_user_id: data["target-user-id"],
        tmi_sent_ts: data["tmi-sent-ts"]
      }
    end
  end

  defmodule ClearmsgTags do
    @moduledoc """
      Twitch chat CLEARMSG tags
    """
    @enforce_keys [:login, :room_id, :target_msg_id, :tmi_sent_ts]
    defstruct @enforce_keys

    @type t :: %__MODULE__{
            login: String.t() | nil,
            room_id: String.t() | nil,
            target_msg_id: String.t() | nil,
            tmi_sent_ts: String.t() | nil
          }
    def build(%{} = data) do
      %__MODULE__{
        login: data["login"],
        room_id: data["room-id"],
        target_msg_id: data["target-msg-id"],
        tmi_sent_ts: data["tmi-sent-ts"]
      }
    end
  end

  defmodule GlobaluserstateTags do
    @moduledoc """
      Twitch chat GLOBALUSERSTATE tags
    """
    @enforce_keys [
      :badge_info,
      :badges,
      :color,
      :display_name,
      :emote_sets,
      :turbo,
      :user_id,
      :user_type
    ]
    defstruct @enforce_keys

    @type t :: %__MODULE__{
            badge_info: String.t() | nil,
            badges: String.t() | nil,
            color: String.t() | nil,
            display_name: String.t() | nil,
            emote_sets: String.t() | nil,
            turbo: String.t() | nil,
            user_id: String.t() | nil,
            user_type: String.t() | nil
          }
    def build(%{} = data) do
      %__MODULE__{
        badge_info: data["badge-info"],
        badges: data["badges"],
        color: data["color"],
        display_name: data["display-name"],
        emote_sets: data["emote-sets"],
        turbo: data["turbo"],
        user_id: data["user-id"],
        user_type: data["user-type"]
      }
    end
  end

  defmodule NoticeTags do
    @moduledoc """
      Twitch chat NOTICE tags
    """
    @enforce_keys [:msg_id, :target_user_id]
    defstruct @enforce_keys

    @type t :: %__MODULE__{
            msg_id: String.t(),
            target_user_id: String.t() | nil
          }

    def build(%{} = data) do
      %__MODULE__{
        msg_id: data["msg-id"],
        target_user_id: data["target-user-id"]
      }
    end
  end

  defmodule RoomstateTags do
    @moduledoc """
      Twitch chat ROOMSTATE tags
    """
    @enforce_keys [:emote_only, :followers_only, :r9k, :room_id, :slow, :subs_only]
    defstruct @enforce_keys

    @type t :: %__MODULE__{
            emote_only: String.t() | nil,
            followers_only: String.t() | nil,
            r9k: String.t() | nil,
            room_id: String.t() | nil,
            slow: String.t() | nil,
            subs_only: String.t() | nil
          }

    def build(%{} = data) do
      %__MODULE__{
        emote_only: data["emote-only"],
        followers_only: data["followers-only"],
        r9k: data["r9k"],
        room_id: data["room-id"],
        slow: data["slow"],
        subs_only: data["subs-only"]
      }
    end
  end

  defmodule UsernoticeTags do
    @moduledoc """
      Twitch chat ROOMSTATE tags
    """
    @enforce_keys [
      :badge_info,
      :badges,
      :color,
      :display_name,
      :emotes,
      :id,
      :login,
      :mod,
      :msg_id,
      :msg_param_cumulative_months,
      :msg_param_streak_months,
      :msg_param_should_share_streak,
      :msg_param_sub_plan,
      :msg_param_sub_plan_name,
      :room_id,
      :subscriber,
      :system_msg,
      :tmi_sent_ts,
      :turbo,
      :user_id,
      :user_type
    ]
    defstruct @enforce_keys

    @type t :: %__MODULE__{
            badge_info: String.t() | nil,
            badges: String.t() | nil,
            color: String.t() | nil,
            display_name: String.t() | nil,
            emotes: String.t() | nil,
            id: String.t() | nil,
            login: String.t() | nil,
            mod: String.t() | nil,
            msg_id: String.t() | nil,
            msg_param_cumulative_months: String.t() | nil,
            msg_param_streak_months: String.t() | nil,
            msg_param_should_share_streak: String.t() | nil,
            msg_param_sub_plan: String.t() | nil,
            msg_param_sub_plan_name: String.t() | nil,
            room_id: String.t() | nil,
            subscriber: String.t() | nil,
            system_msg: String.t() | nil,
            tmi_sent_ts: String.t() | nil,
            turbo: String.t() | nil,
            user_id: String.t() | nil,
            user_type: String.t() | nil
          }

    def build(%{} = data) do
      %__MODULE__{
        badge_info: data["badge-info"],
        badges: data["badges"],
        color: data["color"],
        display_name: data["display-name"],
        emotes: data["emotes"],
        id: data["id"],
        login: data["login"],
        mod: data["mod"],
        msg_id: data["msg-id"],
        msg_param_cumulative_months: data["msg-param-cumulative-months"],
        msg_param_streak_months: data["msg-param-streak-months"],
        msg_param_should_share_streak: data["msg-param-should-share-streak"],
        msg_param_sub_plan: data["msg-param-sub-plan"],
        msg_param_sub_plan_name: data["msg-param-sub-plan-name"],
        room_id: data["room-id"],
        subscriber: data["subscriber"],
        system_msg: data["system-msg"],
        tmi_sent_ts: data["tmi-sent-ts"],
        turbo: data["turbo"],
        user_id: data["user-id"],
        user_type: data["user-type"]
      }
    end
  end
end
