defmodule ZServer do
  def start(_type, _args) do
    ZServerSupervisor.start_link
  end
end

defmodule ZServer.Router.Homepage do
  import Plug.Conn
  use Maru.Router

  get do
    resp = %{ hello: :world }
  end
end

defmodule ZServer.API do
  use Maru.Router

  mount ZServer.Router.Homepage

  def error(conn, err) do
    "ERROR: #{inspect err}" |> text(500)
  end
end