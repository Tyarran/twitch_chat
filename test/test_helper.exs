ExUnit.start()

# Hammox.defmock(TwitchChat.MockMessageParser, for: TwitchChat.MessageParser)
# Hammox.defmock(TwitchChat.MockBackend, for: TwitchChat.Backend)
Hammox.defmock(TwitchChat.MockMessage, for: TwitchChat.Message)

# Application.put_env(TwitchChat.MessageParser, :parse, TwitchChat.MockMessageParser)
# Application.put_env(:twitch_chat, :twitch_backend, TwitchChat.MockBackend)
Application.put_env(:twitch_chat, :twitch_message, TwitchChat.MockMessage)

defmodule TestUtils do
  def test_directory do
    Path.join([Path.dirname(__DIR__), "test"])
  end

  def load_test_data(filename) do
    path = Path.join([test_directory(), "data", filename])

    with {:ok, content} <- File.read(path),
         {:ok, data} <- Jason.decode(content) do
      data
    else
      {:error, reason} -> raise "Failed to load test data: #{reason}"
    end
  end
end
