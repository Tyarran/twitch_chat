defmodule TwitchChat.TwitchHandler do
  @moduledoc """
    ExIRC client handler for Twitch chat
  """

  use GenServer

  alias TwitchChat.Registry, as: TCRegistry

  def start_link(nick) do
    GenServer.start_link(
      __MODULE__,
      %{client: nil, pending_messages: [], nick: nick},
      name: __MODULE__
    )
  end

  def init(state) do
    client_id = Application.fetch_env!(:twitch_chat, :client_id)
    client_secret = Application.fetch_env!(:twitch_chat, :client_secret)
    host = Application.fetch_env!(:twitch_chat, :host)
    port = Application.fetch_env!(:twitch_chat, :port)

    # OAuth
    {:ok, credentials} = TwitchChat.OAuth.get_credentials(client_id, client_secret)
    pass = "oauth:#{credentials.access_token}"
    TCRegistry.register(:pass, pass)

    # Connection
    {:ok, client} = ExIRC.start_link!()
    ExIRC.Client.add_handler(client, self())
    :ok = ExIRC.Client.connect_ssl!(client, host, port)
    {:ok, %{state | :client => client}}
  end

  def msg(cmd, channel, message) do
    GenServer.cast(__MODULE__, {:msg, cmd, channel, message})
  end

  def handle_cast({:msg, cmd, channel, message}, state) do
    if ExIRC.Client.is_logged_on?(state.client) do
      ExIRC.Client.msg(state.client, cmd, channel, message)
      {:noreply, state}
    else
      new_state = [{cmd, channel, message} | state.pending_messages]

      {:noreply, %{state | :pending_messages => new_state}}
    end
  end

  def handle_cast({:received, %{command: :privmsg} = _msg}, state) do
    debug("Received PRIVMSG")
    {:noreply, state}
  end

  def handle_info({:connected, server, port}, state) do
    debug("Connected to #{server}:#{port}")
    pass = TCRegistry.get(:pass)
    ExIRC.Client.logon(state.client, pass, state.nick, state.nick, state.nick)
    {:noreply, state}
  end

  def handle_info(:logged_in, state) do
    debug("Logged in to server")
    ExIRC.Client.join(state.client, "#tyarran")
    {:noreply, state}
  end

  def handle_info({:login_failed, :nick_in_use}, state) do
    debug("Login failed, nickname in use")
    {:noreply, state}
  end

  def handle_info(:disconnected, state) do
    debug("Disconnected from server")
    {:noreply, state}
  end

  def handle_info({:joined, channel}, state) do
    debug("Joined channel #{channel}")

    ExIRC.Client.cmd(
      state.client,
      "CAP REQ :twitch.tv/commands twitch.tv/tags twitch.tv/membership"
    )

    # Process.sleep(1000)

    state.pending_messages
    |> Enum.reverse()
    |> Enum.each(fn {cmd, channel, message} ->
      ExIRC.Client.msg(state.client, cmd, channel, message)
    end)

    {:noreply, state}
  end

  def handle_info({:joined, channel, user}, state) do
    debug("#{user.nick} joined #{channel}")
    {:noreply, state}
  end

  def handle_info({:topic_changed, channel, topic}, state) do
    debug("#{channel} topic changed to #{topic}")
    {:noreply, state}
  end

  def handle_info({:nick_changed, nick}, state) do
    debug("We changed our nick to #{nick}")
    {:noreply, state}
  end

  def handle_info({:nick_changed, old_nick, new_nick}, state) do
    debug("#{old_nick} changed their nick to #{new_nick}")
    {:noreply, state}
  end

  def handle_info({:parted, channel}, state) do
    debug("We left #{channel}")
    {:noreply, state}
  end

  def handle_info({:parted, channel, sender}, state) do
    nick = sender.nick
    debug("#{nick} left #{channel}")
    {:noreply, state}
  end

  def handle_info({:invited, sender, channel}, state) do
    by = sender.nick
    debug("#{by} invited us to #{channel}")
    {:noreply, state}
  end

  def handle_info({:kicked, sender, channel}, state) do
    by = sender.nick
    debug("We were kicked from #{channel} by #{by}")
    {:noreply, state}
  end

  def handle_info({:kicked, nick, sender, channel}, state) do
    by = sender.nick
    debug("#{nick} was kicked from #{channel} by #{by}")
    {:noreply, state}
  end

  def handle_info({:received, message, sender}, state) do
    from = sender.nick
    debug("#{from} sent us a private message: #{message}")
    {:noreply, state}
  end

  def handle_info({:received, message, sender, channel}, state) do
    from = sender.nick
    debug("#{from} sent a message to #{channel}: #{message}")

    {:noreply, state}
  end

  def handle_info({:mentioned, message, sender, channel}, state) do
    from = sender.nick
    debug("#{from} mentioned us in #{channel}: #{message}")
    {:noreply, state}
  end

  def handle_info({:me, message, sender, channel}, state) do
    from = sender.nick
    debug("* #{from} #{message} in #{channel}")
    {:noreply, state}
  end

  # This is an example of how you can manually catch commands if ExIRC.Client doesn't send a specific message for it
  def handle_info(%ExIRC.Message{nick: from, cmd: "PRIVMSG", args: ["testnick", msg]}, state) do
    debug("Received a private message from #{from}: #{msg}")
    {:noreply, state}
  end

  def handle_info(%ExIRC.Message{nick: from, cmd: "PRIVMSG", args: [to, msg]}, state) do
    debug("Received a message in #{to} from #{from}: #{msg}")
    {:noreply, state}
  end

  # Catch-all for messages you don't care about
  def handle_info(
        {:unrecognized, "@badge-info=" <> _rest = _badge_infos,
         %ExIRC.Message{cmd: _cmd, args: [arg]} = _message},
        state
      ) do
    [user, command, channel, msg] = String.split(arg)

    msg =
      %{
        user: parse_user(user),
        command: parse_command(command),
        channel: channel,
        msg: parse_message(msg)
      }

    GenServer.cast(__MODULE__, {:received, msg})

    # debug("Received ExIRC.Message:")
    #
    #
    # cmd
    # |> String.split(";")
    # |> Enum.map(fn item ->
    #   item
    #   |> String.split("=")
    #   |> List.to_tuple()
    # end)
    # |> Map.new()
    # |> BadgeInfo.from_map()
    #
    {:noreply, state}
  end

  def handle_info(_msg, state) do
    # dbg(msg)
    debug("Received ExIRC.Message: ")
    {:noreply, state}
  end

  # def parse_message() do
  # end

  defp parse_command("PRIVMSG"), do: :privmsg

  defp parse_message(":" <> msg), do: msg

  defp parse_user(raw_user) do
    raw_user
    |> String.split("!")
    |> List.first()
  end

  defp debug(msg) do
    IO.puts(IO.ANSI.yellow() <> msg <> IO.ANSI.reset())
  end
end
