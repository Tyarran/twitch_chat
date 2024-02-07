defmodule TwitchChat.OAuth.AuthCodeHandler do
  use GenServer

  defmodule AuthCodePlug do
    import Plug.Conn
    alias TwitchChat.OAuth.AuthCodeHandler

    def init(options), do: options

    def call(conn, _opts) do
      query_params = Plug.Conn.Query.decode(conn.query_string)
      AuthCodeHandler.set_auth_code(query_params["code"])

      conn
      |> put_resp_content_type("text/html")
      |> send_resp(
        200,
        "<html><head><script language=\"javascript\">window.close();</script></head>"
      )
    end
  end

  def start_link() do
    GenServer.start_link(__MODULE__, %{client: nil}, name: __MODULE__)
  end

  # Client
  @spec get_auth_code(String.t(), pos_integer()) :: {:ok, String.t()} | {:error, term()}
  def get_auth_code(client_id, auth_server_port \\ 3000) do
    start_http_server(auth_server_port)

    GenServer.call(
      __MODULE__,
      {:get_auth_code, client_id, auth_server_port},
      60_000
    )
  end

  def set_auth_code(code) do
    GenServer.cast(__MODULE__, {:set_auth_code, code})
  end

  # Server
  @impl true
  def init(state) do
    {:ok, state}
  end

  @impl true
  def handle_call({:get_auth_code, client_id, auth_server_port}, from, state) do
    fetch_auth_code(client_id, auth_server_port)
    {:noreply, %{state | client: from}}
  end

  @impl true
  def handle_cast({:set_auth_code, code}, state) do
    stop_http_server()
    GenServer.reply(state.client, {:ok, code})
    {:noreply, %{state | client: nil}}
  end

  @impl true
  def terminate(_reason, state) do
    stop_http_server()
    {:ok, state}
  end

  defp start_http_server(port) do
    {:ok, pid} = Bandit.start_link(plug: AuthCodePlug, port: port)
    Process.register(pid, :http_server)
  end

  defp stop_http_server() do
    pid = Process.whereis(:http_server)

    if pid do
      Process.unregister(:http_server)
      GenServer.stop(pid, :normal)
    end
  end

  defp fetch_auth_code(client_id, port) do
    System.cmd("xdg-open", [
      "https://id.twitch.tv/oauth2/authorize?client_id=#{client_id}&redirect_uri=http://localhost:3000&response_type=code&scope=chat:read chat:edit&grant_type=client_credentials"
    ])

    HTTPoison.request(%HTTPoison.Request{
      method: :get,
      url: "https://id.twitch.tv/oauth2/authorize",
      params: %{
        "client_id" => client_id,
        "redirect_uri" => "http://localhost:" <> Integer.to_string(port),
        "response_type" => "code",
        "scope" => "chat:read chat:edit"
      },
      options: [follow_redirect: true]
    })

    :ok
  end
end
