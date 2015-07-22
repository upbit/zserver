defmodule ZServer do
  def start(_type, _args) do
    :seafood.start_cache(:my_cache, %{:expiration => 3600})
    ZServerSupervisor.start_link
  end
end

defmodule ZServer.API do
  use Maru.Router

  plug XSS.Protection

  # routers
  plug MaruSwagger, at: "/swagger"
  plug Plug.Static, at: "/static", from: "./priv/static/"

  mount ZServer.Routers.Homepage

  rescue_from Maru.Exceptions.NotFound do
    status 404
    content_type "text/html"
    "<html><center><img src='/static/404.jpg'></center></html>"
  end

  rescue_from :all, as: e do
    status 500
    :io_lib.format("~p~n~nStacktrace:~n~s", [e, Exception.format_stacktrace(System.stacktrace())]) |> List.flatten |> to_string
  end
end