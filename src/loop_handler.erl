-module(loop_handler).
-behaviour(cowboy_loop_handler).

%% cowboy handler callbacks
-export([
		init/3,
		allowed_methods/2,
		content_types_accepted/2,
		info/3,
		terminate/3
	]).

-export([handle_post/2]).

-record(state, {}).

init(_Type, Req, _Opts) ->
	case cowboy_req:method(Req) of
		{<<"POST">>, _} ->
			{upgrade, protocol, cowboy_rest};
		{<<"GET">>, Req1} ->
			Req2 = chunk_start(Req1),
			ok = pg2:join(notify_group, self()),
			{loop, Req2, #state{}, hibernate}
	end.

%% only allowed post for REST
allowed_methods(Req, State) ->
	{[<<"POST">>], Req, State}.

content_types_accepted(Req, State) ->
	{[{<<"application/json">>, handle_post}], Req, State}.

%%
info({message, Msg}, Req, State) ->
	Data = jsx:encode(#{
		<<"messages">> => Msg,
		<<"timestamp">> => timestamp()
	}),
	ok = cowboy_req:chunk(["data: ", Data, "\n\n"], Req),
	{loop, Req, State, hibernate}.

terminate(_Reason, _Req, _State) ->
	ok.

%% POST

handle_post(Req, State) ->
	{ok, Body, Req1} = cowboy_req:body(Req),
	case jsx:decode(Body) of
		Data ->
			notify_all(Data),
			{true, Req1, State}
	end.

%%

chunk_start(Req) ->
	Headers = [
		{<<"content-type">>, <<"text/event-stream">>},
		{<<"connection">>, <<"keep-alive">>}
	],
	{ok, Req2} = cowboy_req:chunked_reply(200, Headers, Req),
	Data = jsx:encode(#{
		<<"messages">> => <<"connected">>,
		<<"timestamp">> => timestamp()
	}),
	ok = cowboy_req:chunk(["data: ", Data, "\n\n"], Req2),
	Req2.

notify_all(Msg) ->
	lists:foreach(
		fun(Listener) ->
			lager:info("notify ~p: ~p", [Listener, Msg]),
			Listener ! {message, Msg}
		end, pg2:get_members(notify_group)).

timestamp() ->
	{M, S, _} = os:timestamp(),  
	M * 1000000 + S.
