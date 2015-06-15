defmodule ZServer do
  use Application
  use Plug.Router
  use Plug.ErrorHandler

  plug :match
  plug :dispatch

  @spec start(atom, Keyword.t) :: {:ok, pid}
  def start(_types, _args) do
    Plug.Adapters.Cowboy.http ZServer, [], port: 8080
  end

  # Routing Table
  get "/" do
    send_resp(conn, 200, "It Works!")
  end

  forward "/users", to: UsersRouter

  match _ do
    RespHelper.http_404(conn)
  end

  defp handle_errors(conn, %{kind: _kind, reason: _reason, stack: _stack}) do
    send_resp(conn, conn.status, "Oops!")
  end
end
