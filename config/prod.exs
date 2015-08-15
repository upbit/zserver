use Mix.Config

config :maru, ZServer.API,
  http: [port: 80]

# config :cqerl,
#   cassandra_nodes: [{'127.0.0.1', 9042}],
#   keyspace: "zserver"

config :logger, :console,
  format: "\n$time [$level]$levelpad$message\n",
  level: :info
