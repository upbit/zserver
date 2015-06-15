defmodule ZServer do
  use Application
  use Plug.Router

  use Plug.ErrorHandler

  plug :match
  plug :dispatch

  @spec start(atom, Keyword.t) :: {:ok, pid}
  def start(_types, _args) do
    #:application.start :lager
    Plug.Adapters.Cowboy.http ZServer, [], port: 8080
  end

  # Routing Table
  get "/foo" do
    send_resp(conn, 200, "bar")
  end

  forward "/users", to: UsersRouter

  defp handle_errors(conn, %{kind: kind, reason: reason, stack: stack}) do
    {:ok, body} = JSX.encode(%{
      "kind" => kind,
      "reason" => reason,
      "stack" => stack
    })
    send_resp(conn, conn.status, body)
  end
end
