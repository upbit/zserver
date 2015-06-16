defmodule UsersRouter do
  use Plug.Router

  plug :match
  plug :dispatch

  post "/new" do
    response = %{
      "user" => :toor,
      "pass" => :deadbeef
    }
    
    conn
    |> put_resp_header("content-type", "application/json")
    |> send_resp(200, :jsx.encode(response))
  end

  match _ do
    RespHelper.http_404(conn)
  end
end