defmodule ZServer do
  def start(_type, _args) do
    :seafood.start_cache(:my_cache, %{:expiration => 3600})
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
  end

  resources "/version" do
    get do
      {:ok, client} = :cqerl.new_client({})
      {:ok, result} = :cqerl.run_query(client, "SELECT cql_version FROM system.local LIMIT 1;")
      [row] = :cqerl.all_rows(result)
      version = :proplists.get_value(:cql_version, row)
      :cqerl.close_client(client)
      {:ok, count} = :seafood.get(:my_cache, <<"count">>, 1)
      :seafood.put(:my_cache, <<"count">>, count+1)
      %{ cql_version: version, count: count }
    end
  end

  mount UserRouter
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