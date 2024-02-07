defmodule TwitchChatTest do
  use ExUnit.Case
  doctest TwitchChat

  test "greets the world" do
    assert TwitchChat.hello() == :world
  end
end
