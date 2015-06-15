defmodule RespHelper do
  import Plug.Conn

  def default_headers(conn) do
    # https://www.owasp.org/index.php/List_of_useful_HTTP_headers
  	conn
    |> put_resp_header("x-frame-options", "deny")
    |> put_resp_header("x-xss-protection", "1; mode=block")
    |> put_resp_header("x-content-type-options", "nosniff")
  end

  def http_404(conn) do
    conn
    |> default_headers
    |> put_resp_content_type("text/html")
    |> send_resp(404, "<h1>Not Found</h1>")
  end

end
