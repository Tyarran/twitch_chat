defmodule TwitchChat.MessageTest do
  @moduledoc """
      Tests for TwitchChat.Message
  """
  use ExUnit.Case, async: true
  import Hammox

  alias TwitchChat.Message

  @tags "tag1=1;tag2=2"

  describe "Parse ExIRC Message" do
    test "PRIVMSG" do
      exirc_message = %ExIRC.Message{
        server: [],
        nick: [],
        user: [],
        host: [],
        ctcp: false,
        cmd: @tags,
        args: ["example@example.tmi.twitch.tv PRIVMSG #channel :Hello world!"]
      }

      expected = {:privmsg, "#channel", "Hello world!", "example", %{}}

      expect(TwitchChat.MockMessage, :parse, fn message ->
        assert message ==
                 "#{@tags} :example@example.tmi.twitch.tv PRIVMSG #channel :Hello world!"

        {:ok, expected}
      end)

      result = Message.parse(exirc_message)

      assert result == {:ok, expected}
    end
  end

  test "CLEARMSG" do
    irc_message = %ExIRC.Message{
      server: [],
      nick: [],
      user: [],
      host: [],
      ctcp: false,
      cmd: @tags,
      args: ["tmi.twitch.tv CLEARMSG #bar :what a great day"]
    }

    expected = {:clearmsg, "#bar", "what a great day", %{}}

    expect(TwitchChat.MockMessage, :parse, fn message ->
      assert message == "#{@tags} :tmi.twitch.tv CLEARMSG #bar :what a great day"

      {:ok, expected}
    end)

    result = Message.parse(irc_message)

    assert result == {:ok, expected}
  end

  test "CLEARCHAT" do
    irc_message = %ExIRC.Message{
      server: [],
      nick: [],
      user: [],
      host: [],
      ctcp: false,
      cmd: @tags,
      args: ["tmi.twitch.tv CLEARCHAT #dallas :ronni"]
    }

    expected = {:clearchat, "#bar", "ronni", %{}}

    expect(TwitchChat.MockMessage, :parse, fn message ->
      assert message == "#{@tags} :tmi.twitch.tv CLEARCHAT #dallas :ronni"

      {:ok, expected}
    end)

    result = Message.parse(irc_message)

    assert result == {:ok, expected}
  end

  test "CLEARCHAT (ALL)" do
    irc_message = %ExIRC.Message{
      server: [],
      nick: [],
      user: [],
      host: [],
      ctcp: false,
      cmd: @tags,
      args: ["tmi.twitch.tv CLEARCHAT #dallas"]
    }

    expected = {:clearchat, "#bar", %{}}

    expect(TwitchChat.MockMessage, :parse, fn message ->
      assert message == "#{@tags} :tmi.twitch.tv CLEARCHAT #dallas"

      {:ok, expected}
    end)

    result = Message.parse(irc_message)

    assert result == {:ok, expected}
  end

  test "GLOBALUSERSTATE" do
    irc_message = %ExIRC.Message{
      server: [],
      nick: [],
      user: [],
      host: [],
      ctcp: false,
      cmd: @tags,
      args: ["tmi.twitch.tv GLOBALUSERSTATE"]
    }

    expected = {:globaluserstate, %{}}

    expect(TwitchChat.MockMessage, :parse, fn message ->
      assert message == "#{@tags} :tmi.twitch.tv GLOBALUSERSTATE"

      {:ok, expected}
    end)

    result = Message.parse(irc_message)

    assert result == {:ok, expected}
  end

  test "HOSTTARGET" do
    irc_message = %ExIRC.Message{
      server: [],
      nick: [],
      user: [],
      host: [],
      ctcp: false,
      cmd: "",
      args: ["tmi.twitch.tv HOSTTARGET #abc 10"]
    }

    expected = {:hosttarget, "#abc", 10}

    expect(TwitchChat.MockMessage, :parse, fn message ->
      assert message == ":tmi.twitch.tv HOSTTARGET #abc 10"

      {:ok, expected}
    end)

    result = Message.parse(irc_message)

    assert result == {:ok, expected}
  end

  test "HOSTTARGET with hosting-channel" do
    irc_message = %ExIRC.Message{
      server: [],
      nick: [],
      user: [],
      host: [],
      ctcp: false,
      cmd: "",
      args: ["tmi.twitch.tv HOSTTARGET #abc :xyz 10"]
    }

    expected = {:hosttarget, "#abc", "xyz", 10}

    expect(TwitchChat.MockMessage, :parse, fn message ->
      assert message == ":tmi.twitch.tv HOSTTARGET #abc :xyz 10"

      {:ok, expected}
    end)

    result = Message.parse(irc_message)

    assert result == {:ok, expected}
  end

  test "ROOMSTATE" do
    irc_message = %ExIRC.Message{
      server: [],
      nick: [],
      user: [],
      host: [],
      ctcp: false,
      cmd: @tags,
      args: ["tmi.twitch.tv ROOMSTATE #bar"]
    }

    expected = {:roomstate, "#bar", %{}}

    expect(TwitchChat.MockMessage, :parse, fn message ->
      assert message == "#{@tags} :tmi.twitch.tv ROOMSTATE #bar"

      {:ok, expected}
    end)

    result = Message.parse(irc_message)

    assert result == {:ok, expected}
  end

  test "WHISPER" do
    irc_message = %ExIRC.Message{
      server: [],
      nick: [],
      user: [],
      host: [],
      ctcp: false,
      cmd: @tags,
      args: ["petsgomoo!petsgomoo@petsgomoo.tmi.twitch.tv WHISPER foo :hello world!"]
    }

    expected = {:whisper, "foo", "petsgomoo", "hello world!", %{}}

    expect(TwitchChat.MockMessage, :parse, fn message ->
      assert message ==
               "#{@tags} :petsgomoo!petsgomoo@petsgomoo.tmi.twitch.tv WHISPER foo :hello world!"

      {:ok, expected}
    end)

    result = Message.parse(irc_message)

    assert result == {:ok, expected}
  end

  test "USERSTATE" do
    irc_message = %ExIRC.Message{
      server: [],
      nick: [],
      user: [],
      host: [],
      ctcp: false,
      cmd: @tags,
      args: ["tmi.twitch.tv USERSTATE #dallas"]
    }

    expected = {:userstate, "#dallas", %{}}

    expect(TwitchChat.MockMessage, :parse, fn message ->
      assert message == "#{@tags} :tmi.twitch.tv USERSTATE #dallas"

      {:ok, expected}
    end)

    result = Message.parse(irc_message)

    assert result == {:ok, expected}
  end

  test "USERNOTICE" do
    irc_message = %ExIRC.Message{
      server: [],
      nick: [],
      user: [],
      host: [],
      ctcp: false,
      cmd: @tags,
      args: ["tmi.twitch.tv USERNOTICE #dallas :Great stream -- keep it up!"]
    }

    expected = {:usernotice, "#dallas", "Great stream -- keep it up!", %{}}

    expect(TwitchChat.MockMessage, :parse, fn message ->
      assert message == "#{@tags} :tmi.twitch.tv USERNOTICE #dallas :Great stream -- keep it up!"

      {:ok, expected}
    end)

    result = Message.parse(irc_message)

    assert result == {:ok, expected}
  end

  test "NOTICE" do
    irc_message = %ExIRC.Message{
      server: [],
      nick: [],
      user: [],
      host: [],
      ctcp: false,
      cmd: @tags,
      args: ["tmi.twitch.tv NOTICE #bar :The message from foo is now deleted"]
    }

    expected = {:notice, "#bar", "The message from foo is now deleted", %{}}

    expect(TwitchChat.MockMessage, :parse, fn message ->
      assert message == "#{@tags} :tmi.twitch.tv NOTICE #bar :The message from foo is now deleted"

      {:ok, expected}
    end)

    result = Message.parse(irc_message)

    assert result == {:ok, expected}
  end

  test "RECONNECT" do
    irc_message = %ExIRC.Message{
      server: [],
      nick: [],
      user: [],
      host: [],
      ctcp: false,
      cmd: "",
      args: ["tmi.twitch.tv RECONNECT"]
    }

    expected = :reconnect

    expect(TwitchChat.MockMessage, :parse, fn message ->
      assert message ==
               ":tmi.twitch.tv RECONNECT"

      {:ok, expected}
    end)

    result = Message.parse(irc_message)

    assert result == {:ok, expected}
  end
end
