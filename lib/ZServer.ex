defmodule ZServer do
  def start(_type, _args) do
    ZServer.Supervisor.start_link
  end
end
