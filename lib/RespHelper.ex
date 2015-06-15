defmodule RespHelper do
  import Plug.Conn

  def http_404(conn) do
    conn
    |> put_resp_content_type("text/html")
    |> send_resp(404, "<h1>Not Found</h1>")
  end

end
