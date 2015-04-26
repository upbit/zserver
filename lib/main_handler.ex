defmodule MainHandler do

	def init(request, state) do
		{:ok, body} = JSX.encode(%{
			"messages" => [:hello, :world]
		})

		reply = :cowboy_req.reply(200, [
			{"content-type", "application/json"}
		], body, request)

		{:ok, reply, state}
	end

end
