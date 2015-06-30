defmodule ZServer do
  def start(_type, _args) do
    ZServerSupervisor.start_link
  end
end

defmodule ZServer.Router.Homepage do
  use Maru.Router

  resources do
    get do
      #"Hello World!" |> text
      #%{ foo: :bar } |> json
      "<h1>It Works!</h1>" |> html
    end

    mount UsersRouter
  end
end

defmodule ZServer.API do
  use Maru.Router

  plug Plug.Static, at: "/static", from: "./priv/"

  mount ZServer.Router.Homepage

  # def error(conn, _e) do
  #   %{ error: _e } |> json
  # end
    rescue_from :all do
      status 500
      "match error"
    end
end