defmodule TwitchChat.TwitchClient.ExIRCClient do
  @moduledoc """
    ExIRC client handler for TwitchClient
  """
  @behaviour TwitchChat.TwitchClient

  def run do
    ExIRC.Client.start_link()
  end

  def add_handler(client, handler) do
    ExIRC.Client.add_handler(client, handler)
  end

  def connect(client, host, port) do
    ExIRC.Client.connect_ssl!(client, host, port)
  end

  def join(client, channel) do
    ExIRC.Client.join(client, channel)
  end

  def cmd(client, cmd) do
    ExIRC.Client.cmd(client, cmd)
  end

  def msg(client, cmd, channel, message) do
    ExIRC.Client.msg(client, cmd, channel, message)
  end

  def logon(client, pass, nick) do
    ExIRC.Client.logon(client, pass, nick, nick, nick)
  end

  def logged_on?(client) do
    ExIRC.Client.is_logged_on?(client)
  end
end
