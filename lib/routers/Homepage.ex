defmodule ZServer.Routers.Homepage do
  use Maru.Router

  resources do
    get do
      content_type "text/html"
      "<h1>It Works!</h1>"
    end
  end

  # resources "/version" do
  #   get do
  #     {:ok, client} = :cqerl.new_client({})
  #     {:ok, result} = :cqerl.run_query(client, "SELECT cql_version FROM system.local LIMIT 1;")
  #     [row] = :cqerl.all_rows(result)
  #     version = :proplists.get_value(:cql_version, row)
  #     :cqerl.close_client(client)
  #     {:ok, count} = :seafood.get(:my_cache, <<"count">>, 1)
  #     :seafood.put(:my_cache, <<"count">>, count+1)
  #     %{ cql_version: version, count: count }
  #   end
  # end

  mount Routers.UserRouter
end
