defmodule TwitchChat.OAuth do
  @moduledoc """
  This module is a behaviour to handle OAuth
  """
  alias TwitchChat.OAuth.Twitch

  defmodule Credentials do
    @moduledoc """
    This module is a struct to hold Twitch credentials
    """
    @derive Jason.Encoder
    @enforce_keys [:access_token, :token_expiration, :refresh_token, :client_id, :client_secret]
    defstruct @enforce_keys

    @type t :: %__MODULE__{
            access_token: String.t(),
            refresh_token: String.t(),
            token_expiration: DateTime.t(),
            client_id: String.t(),
            client_secret: String.t()
          }

    def from_map(data) do
      data
      |> Enum.map(fn {key, value} -> {String.to_existing_atom(key), value} end)
      |> then(&struct(Credentials, &1))
    end
  end

  @callback get_credentials(client_id :: String.t(), client_secret :: String.t()) ::
              {:ok, Credentials.t()} | {:error, term()}

  @callback refresh_token(Credentials.t()) :: {:ok, Credentials.t()}

  def get_credentials(client_id, client_secret) do
    Twitch.get_credentials(client_id, client_secret)
  end

  def refresh_token(credentials) do
    Twitch.refresh_token(credentials)
  end
end
