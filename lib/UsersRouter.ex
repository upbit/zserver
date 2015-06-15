defmodule UsersRouter do
  use Plug.Router

  plug :match
  plug :dispatch

  get "/users/new" do
    send_resp(conn, 200, "new user")
  end

end