-module(main_handler).

-export([init/2]).

init(Req, Opts) ->
	Body = jsx:encode(#{
		<<"messages">> => [
			hello, world
		],
		<<"timestamp">> => timestamp()
	}),
	Req1 = cowboy_req:reply(200, [
		{<<"content-type">>, <<"application/json">>},
		{<<"connection">>, <<"close">>}
	], << Body/binary, <<"\n">>/binary >>, Req),
	{ok, Req1, Opts}.

%% ===================================================================
%% Internal
%% ===================================================================

timestamp() ->
	{M, S, _} = os:timestamp(),  
	M * 1000000 + S.