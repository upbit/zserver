-module(main_handler).
-behaviour(cowboy_http_handler).

%% cowboy_http_handler callbacks
-export([
	init/3,
	handle/2,
	terminate/3
]).

-record(state, {
}).

%% ===================================================================
%% cowboy_http_handler callbacks
%% ===================================================================

init(_Type, Req, _Opts) ->
	Req2 = cowboy_req:compact(Req),
	{ok, Req2, #state{}}.

handle(Req0, State = #state{}) ->
	Body = jsx:encode(#{
		<<"messages">> => [
			hello, world
		],
		<<"timestamp">> => timestamp()
	}),
	{ok, Req1} = cowboy_req:reply(200, [
		{<<"content-type">>, <<"application/json">>},
		{<<"connection">>, <<"close">>}
	], << Body/binary, <<"\n">>/binary >>, Req0),
	{ok, Req1, State}.

terminate(_Reason, _Req, #state{}) ->
	ok.

%% ===================================================================
%% Internal
%% ===================================================================

timestamp() ->
	{M, S, _} = os:timestamp(),  
	M * 1000000 + S.