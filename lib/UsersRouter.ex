defmodule UsersRouter do
  use Plug.Router

  plug :match
  plug :dispatch

  post "/new" do
    {:ok, response} = JSX.encode(%{
      "user" => :toor,
      "pass" => :deadbeef
    })
    
    conn
    |> put_resp_header("content-type", "application/json")
    |> send_resp(200, response)
  end

  match _ do
    RespHelper.http_404(conn)
  end
end