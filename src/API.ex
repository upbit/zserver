defmodule ZServer.API do
  use Maru.Router
  require Logger

  plug XSS.Protection

  # Routers
  plug Plug.Static, at: "/static", from: "./priv/static/"

  mount ZServer.Routers.Homepage
  mount ZServer.Routers.UserRouter

  # Error handing
  rescue_from Maru.Exceptions.InvalidFormatter, as: error do
    status 400
    error
  end

  rescue_from Maru.Exceptions.NotFound do
    status 404
    content_type "text/html"
    "<html><center><img src='/static/404.jpg'></center></html>"
  end

  rescue_from :all, as: e do
    status 500
    response = :io_lib.format("~p~n~nStacktrace:~n~s", [e, Exception.format_stacktrace(System.stacktrace())]) |> List.flatten |> to_string
    Logger.error response
    response
  end
end
