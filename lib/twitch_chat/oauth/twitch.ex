defmodule TwitchChat.OAuth.Twitch do
  @moduledoc """
  This module is a behaviour to handle Twitch OAuth
  """
  alias TwitchChat.Auth.Credentials
  alias TwitchChat.OAuth.AuthCodeHandler
  alias TwitchChat.OAuth.Credentials

  require Logger

  @behaviour TwitchChat.OAuth

  @impl true
  def get_credentials(client_id, client_secret) do
    case load_from_disk() do
      {:ok, credentials} ->
        Logger.debug("Loaded credentials from disk")
        {:ok, credentials}

      {:error, :no_credentials} ->
        Logger.debug("Get token")
        new_credentials(client_id, client_secret)

      {:expired_token, credentials} ->
        Logger.debug("Refreshing token")
        refresh_token(credentials)
    end
  end

  @impl true
  @spec refresh_token(Credentials.t()) :: {:ok, Credentials.t()}
  def refresh_token(credentials) do
    {:ok, %{status_code: 200, body: body}} =
      HTTPoison.request(%HTTPoison.Request{
        method: :post,
        url: "https://id.twitch.tv/oauth2/token",
        headers: %{
          "Content-Type" => "application/x-www-form-urlencoded"
        },
        params: %{
          "client_id" => credentials.client_id,
          "client_secret" => credentials.client_secret,
          "grant_type" => "refresh_token",
          "refresh_token" => credentials.refresh_token
        }
      })

    new_token =
      body
      |> Jason.decode!()
      |> Enum.filter(fn {key, _} -> key in ["access_token", "refresh_token", "expires_in"] end)
      |> Map.new()

    token_expiration = DateTime.utc_now() |> DateTime.add(new_token["expires_in"], :second)

    new_credential = %Credentials{
      access_token: new_token["access_token"],
      refresh_token: new_token["refresh_token"],
      token_expiration: token_expiration,
      client_id: credentials.client_id,
      client_secret: credentials.client_secret
    }

    save_to_disk(new_credential)

    {:ok, new_credential}
  end

  defp new_credentials(client_id, client_secret) do
    with {:ok, code} <- AuthCodeHandler.get_auth_code(client_id),
         {:ok, tokens} <- fetch_access_token_data(code, client_id, client_secret) do
      token_expiration = DateTime.utc_now() |> DateTime.add(tokens["expires_in"], :second)

      credentials = %Credentials{
        access_token: tokens["access_token"],
        refresh_token: tokens["refresh_token"],
        token_expiration: token_expiration,
        client_id: client_id,
        client_secret: client_secret
      }

      save_to_disk(credentials)

      {:ok, credentials}
    else
      {:error, reason} -> {:error, reason}
    end
  end

  defp fetch_access_token_data(code, client_id, client_secret, auth_server_port \\ 3000) do
    response =
      HTTPoison.request(%HTTPoison.Request{
        method: :post,
        url: "https://id.twitch.tv/oauth2/token",
        params: %{
          "client_id" => client_id,
          "client_secret" => client_secret,
          "code" => code,
          "grant_type" => "authorization_code",
          "redirect_uri" => "http://localhost:" <> Integer.to_string(auth_server_port)
        }
      })

    case response do
      {:ok, %{status_code: 200, body: body}} ->
        response =
          body
          |> Jason.decode!()

        {:ok, response}

      _ ->
        {:error, :fetch_token_error}
    end
  end

  @spec save_to_disk(Credentials.t()) :: {:ok, Credentials.t()} | {:error, term}
  defp save_to_disk(credentials) do
    home = Path.expand("~")
    dirpath = Path.join([home, ".config", "twitch_chat"])
    path = Path.join([dirpath, "credentials.json"])

    with :ok <- File.mkdir_p(dirpath),
         :ok <- File.write(path, Jason.encode!(credentials), [:write]) do
      {:ok, credentials}
    else
      {:error, reason} -> {:error, reason}
    end
  end

  @spec load_from_disk ::
          {:ok, Credentials.t()}
          | {:error, :no_credentials}
          | {:expired_token, Credentials.t()}
  defp load_from_disk do
    path =
      ["~", ".config", "twitch_chat", "credentials.json"]
      |> Path.join()
      |> Path.expand()

    case File.read(path) do
      {:ok, data} ->
        credentials =
          Jason.decode!(data)
          |> then(fn decoded ->
            {:ok, token_expiration, _} = DateTime.from_iso8601(decoded["token_expiration"])

            Map.put(
              decoded,
              "token_expiration",
              token_expiration
            )
          end)
          |> Credentials.from_map()

        if DateTime.compare(credentials.token_expiration, DateTime.utc_now()) == :gt do
          {:ok, credentials}
        else
          {:expired_token, credentials}
        end

      {:error, _} ->
        {:error, :no_credentials}
    end
  end
end
