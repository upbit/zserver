defmodule Zserver do
	@behaviour :application

	def start(_type, _args) do
		dispatch = :cowboy_router.compile([
			{:_, [
				{"/", MainHandler, []}
			]}
		])
		{:ok, _} = :cowboy.start_http(:http, 100, [{:port, 8080}], [{:env, [{:dispatch, dispatch}]}])
		ZserverSupervisor.start_link
	end

	def stop(_state) do
		:ok
	end
end
