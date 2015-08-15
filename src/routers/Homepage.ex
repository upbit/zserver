defmodule ZServer.Routers.Homepage do
  use Maru.Router

  resources do
    get do
      content_type "text/html"
      "<h1>It Works!</h1>"
    end
  end
end
