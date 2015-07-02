defmodule XSS.Protection do
  # https://www.owasp.org/index.php/List_of_useful_HTTP_headers
  use Maru.Middleware
  import Plug.Conn

  def call(conn, _opts) do
    conn
    |> put_resp_header("X-Frame-Options", "deny")
    |> put_resp_header("X-XSS-Protection", "1; mode=block")
    |> put_resp_header("X-Content-Type-Options", "nosniff")
  end
end