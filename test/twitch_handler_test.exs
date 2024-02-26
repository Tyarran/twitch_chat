# defmodule TwitchHandlerTest do
#   use ExUnit.Case, async: true
#
#   import ExUnit.CaptureLog
#   import Mox
#
#   alias TwitchChat.Message
#   alias TwitchChat.TwitchHandler
#
#   @client :fake_client
# describe "TwitchHandler.init" do
#     test "initial" do
#       state = %{handler: nil, client: nil, pending_messages: []}
#
#       expect(TwitchChat.MockTwitchClient, :run, fn ->
#         {:ok, @client}
#       end)
#
#       {:ok, result} = TwitchHandler.init(state)
#
#       assert result == %{
#                handler: nil,
#                client: @client,
#                pending_messages: []
#              }
#     end
#   end
#
#   describe "TwitchHandler.handle_cast" do
#     test ":connect successfull" do
#       state = %{client: @client}
#
#       expect(TwitchChat.MockTwitchClient, :connect, fn client, host, port ->
#         assert client == @client
#         assert host == "irc.chat.twitch.tv"
#         assert port == 6667
#
#         :ok
#       end)
#
#       result = TwitchHandler.handle_cast(:connect, state)
#
#       assert result == {:noreply, state}
#     end
#
#     test ":add_handler" do
#       state = %{client: @client, handlers: []}
#
#       result = TwitchHandler.handle_cast({:add_handler, :fake_handler}, state)
#
#       assert result == {:noreply, %{client: @client, handlers: [:fake_handler]}}
#     end
#
#     test ":add_handler with existing handler" do
#       state = %{client: @client, handlers: [:fake_handler]}
#
#       result = TwitchHandler.handle_cast({:add_handler, :fake_handler}, state)
#
#       assert result == {:noreply, %{client: @client, handlers: [:fake_handler]}}
#     end
#
#     test ":join" do
#       state = %{client: @client}
#
#       expect(TwitchChat.MockTwitchClient, :join, fn client, channel ->
#         assert client == @client
#         assert channel == "#channel"
#
#         :ok
#       end)
#
#       result = TwitchHandler.handle_cast({:join, "#channel"}, state)
#
#       assert result == {:noreply, state}
#     end
#
#     test ":join with error" do
#       state = %{client: @client}
#
#       expect(TwitchChat.MockTwitchClient, :join, fn client, channel ->
#         assert client == @client
#         assert channel == "#channel"
#
#         {:error, :an_error_reason}
#       end)
#
#       captured_logs =
#         capture_log(fn ->
#           result = TwitchHandler.handle_cast({:join, "#channel"}, state)
#
#           assert result == {:stop, :an_error_reason, state}
#         end)
#
#       assert captured_logs != ""
#     end
#
#     test ":msg when logged" do
#       state = %{client: @client, pending_messages: []}
#
#       TwitchChat.MockTwitchClient
#       |> expect(:logged_on?, fn client ->
#         assert client == @client
#
#         true
#       end)
#       |> expect(:msg, fn client, cmd, channel, message ->
#         assert client == @client
#         assert cmd == :privmsg
#         assert channel == "#channel"
#         assert message == "message"
#
#         :ok
#       end)
#
#       result = TwitchHandler.handle_cast({:msg, :privmsg, "#channel", "message"}, state)
#
#       assert result == {:noreply, state}
#     end
#
#     test ":msg when logged with error" do
#       state = %{client: @client, pending_messages: []}
#
#       TwitchChat.MockTwitchClient
#       |> expect(:logged_on?, fn client ->
#         assert client == @client
#
#         true
#       end)
#       |> expect(:msg, fn client, cmd, channel, message ->
#         assert client == @client
#         assert cmd == :privmsg
#         assert channel == "#channel"
#         assert message == "message"
#
#         {:error, :an_error_reason}
#       end)
#
#       captured_logs =
#         capture_log(fn ->
#           result = TwitchHandler.handle_cast({:msg, :privmsg, "#channel", "message"}, state)
#
#           assert result == {:noreply, state}
#         end)
#
#       assert captured_logs != ""
#     end
#
#     test ":msg when not logged" do
#       state = %{client: @client, pending_messages: []}
#
#       expect(TwitchChat.MockTwitchClient, :logged_on?, fn client ->
#         assert client == @client
#
#         false
#       end)
#
#       result = TwitchHandler.handle_cast({:msg, :privmsg, "#channel", "message"}, state)
#
#       assert result ==
#                {:noreply, %{state | pending_messages: [{:privmsg, "#channel", "message"}]}}
#     end
#
#     test ":logon" do
#       state = %{client: @client}
#
#       expect(TwitchChat.MockTwitchClient, :logon, fn client, pass, nick ->
#         assert client == @client
#         assert pass == "password"
#         assert nick == "nickname"
#
#         :ok
#       end)
#
#       result = TwitchHandler.handle_cast({:logon, "password", "nickname"}, state)
#
#       assert result == {:noreply, state}
#     end
#
#     test ":logon with error" do
#       state = %{client: @client}
#
#       expect(TwitchChat.MockTwitchClient, :logon, fn client, pass, nick ->
#         assert client == @client
#         assert pass == "password"
#         assert nick == "nickname"
#
#         {:error, :an_error_reason}
#       end)
#
#       captured_logs =
#         capture_log(fn ->
#           result = TwitchHandler.handle_cast({:logon, "password", "nickname"}, state)
#           assert result == {:noreply, state}
#         end)
#
#       assert captured_logs != ""
#     end
#   end
#
#   describe "TwitchHandler.handler_info" do
#     test ":joined without pending_messages" do
#       state = %{client: @client, pending_messages: [], handlers: []}
#
#       expect(TwitchChat.MockTwitchClient, :cmd, fn client, cmd ->
#         assert client == @client
#         assert cmd == "CAP REQ :twitch.tv/commands twitch.tv/tags twitch.tv/membership"
#
#         :ok
#       end)
#
#       result = TwitchHandler.handle_info({:joined, "#channel"}, state)
#
#       assert result == {:noreply, state}
#     end
#
#     test ":joined with pending_messages" do
#       state = %{
#         client: @client,
#         pending_messages: [{:privmsg, "#channel", "message"}],
#         handlers: []
#       }
#
#       TwitchChat.MockTwitchClient
#       |> expect(:cmd, fn client, cmd ->
#         assert client == @client
#         assert cmd == "CAP REQ :twitch.tv/commands twitch.tv/tags twitch.tv/membership"
#
#         :ok
#       end)
#       |> expect(:msg, fn client, cmd, channel, message ->
#         assert client == @client
#         assert cmd == :privmsg
#         assert channel == "#channel"
#         assert message == "message"
#
#         :ok
#       end)
#
#       result = TwitchHandler.handle_info({:joined, "#channel"}, state)
#
#       assert result == {:noreply, state}
#     end
#
#     test "Parse PRIVMSG" do
#       state = %{client: nil}
#
#       cmd =
#         "@badge-info=;badges=broadcaster/1,premium/1;client-nonce=0ee90d941b4964a2fdbcc5f34af0aef8;color=;display-name=tyarran;emotes=;first-msg=0;flags=;id=de217260-60f0-4ce0-86fb-8799c59ccec1;mod=0;returning-chatter=0;room-id=175715982;subscriber=0;tmi-sent-ts=1707758140401;turbo=0;user-id=175715982;user-type="
#
#       exirc_message = %ExIRC.Message{
#         server: nil,
#         nick: nil,
#         user: nil,
#         host: nil,
#         ctcp: false,
#         cmd: cmd,
#         args: ["tyarran!tyarran@tyarran.tmi.twitch.tv PRIVMSG #tyarran :Hello world!"]
#       }
#
#       expect(TwitchChat.MockMessageParser, :parse, fn message ->
#         assert message == exirc_message
#
#         {:ok,
#          %Message{
#            tags: nil,
#            cmd: :privmsg,
#            args: nil,
#            host: "tyarran@tyarran.tmi.twitch.tv",
#            nick: "tyarran"
#          }}
#       end)
#
#       result = TwitchHandler.handle_info({:unrecognized, cmd, exirc_message}, state)
#
#       assert result == {:noreply, state}
#     end
#   end
# end
