defmodule UsersRouter do
  import Plug.Conn
  use Plug.Router

  plug :match
  plug :dispatch

  get "/new" do
    conn = fetch_params(conn) # populates conn.params
    %{ "uid" => uid, "pass" => pass } = conn.params

    response = %{
      "uid" => "#{uid}",
      "pass" => "#{pass}",
    }
    
    conn
    |> put_resp_header("content-type", "application/json")
    |> send_resp(200, :jsx.encode(response))
  end

  match _ do
    RespHelper.http_404(conn)
  end
end