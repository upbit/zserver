defmodule ZServer do
  def start(_type, _args) do
    # {:ok, client} = :cqerl.new_client({'127.0.0.1', 9042})
    # {:ok, result} = :cqerl.run_query(client, "SELECT cql_version FROM system.local LIMIT 1;")
    # [row] = :cqerl.all_rows(result)
    # IO.puts :proplists.get_value(:cql_version, row)
    # :cqerl.close_client(client)
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
  plug MaruSwagger, at: "/swagger"
  plug Plug.Static, at: "/static", from: "./priv/"

  mount ZServer.Router.Homepage

  rescue_from :all, as: e do
    status 500
    %{ error: e }
  end
end