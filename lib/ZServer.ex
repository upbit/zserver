defmodule ZServer do
  def start(_type, _args) do
    ZServerSupervisor.start_link
  end
end

defmodule ZServer.Router.Homepage do
  use Maru.Router

  resources do
    get do
      content_type "text/html"
      "<h1>It Works!</h1>"
    end

    mount UserRouter
  end
end

defmodule ZServer.API do
  use Maru.Router

  plug XSS.Protection

  # routers
  plug Plug.Static, at: "/static", from: "./priv/"

  mount ZServer.Router.Homepage

  rescue_from :all, as: e do
    status 500
    %{ error: e }
  end
end