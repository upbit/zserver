defmodule ZServer do
  def start(_type, _args) do
    ZServerSupervisor.start_link
  end
end

defmodule ZServer.Router.Homepage do
  use Maru.Router

  resources do
    get do
      %{ user: :abc } |> json
    end

    #mount Router.User
  end
end

defmodule ZServer.API do
  use Maru.Router

  plug Plug.Static, at: "/static", from: "./priv/"

  mount ZServer.Router.Homepage

  def error(conn, _e) do
    %{ error: _e } |> json
  end
end