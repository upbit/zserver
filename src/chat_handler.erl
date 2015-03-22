-module(chat_handler).
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
			random:seed(erlang:now()),
			Nickname = gen_nickname(),
			Req2 = chunk_start(Req1, Nickname),
			ok = pg2:join(notify_group, self()),
			{loop, Req2, #state{}, hibernate}
	end.

%% only allowed post for REST
allowed_methods(Req, State) ->
	{[<<"POST">>], Req, State}.
content_types_accepted(Req, State) ->
	{[{<<"text/plain">>, handle_post}], Req, State}.		% application/json

%%
info({message, Message}, Req, State) ->
	ok = cowboy_req:chunk(["id: ", gen_timestamp_id(), "\n", "data: [", "Hidden", "] ", Message, "\n\n"], Req),
	{loop, Req, State, hibernate}.

terminate(_Reason, _Req, _State) ->
	ok.

%% POST

handle_post(Req, State) ->
	{ok, Body, Req1} = cowboy_req:body(Req, [{length, 4096}, {read_length, 4096}, {read_timeout, 3000}]),
	%{ok, BodyQs, Req1} = cowboy_req:body_qs(Req, [{length, 4096}, {read_length, 4096}, {read_timeout, 3000}]),
	Data = match_body_qs([
		{type, fun erlang:is_binary/1, <<"message">>},
		data
	], Body),
	lager:error("~p", [Data]),
	{true, Req1, State}.

%%

chunk_start(Req, Nickname) ->
	Headers = [
		{<<"content-type">>, <<"text/event-stream">>},
		{<<"connection">>, <<"keep-alive">>}
	],
	{ok, Req2} = cowboy_req:chunked_reply(200, Headers, Req),
	Response = [
		"event: nickname\n",
		"id: ", gen_timestamp_id(), "\n",
		"data: ", Nickname, "\n",
		"\n"
	],
	ok = cowboy_req:chunk(Response, Req2),
	Req2.


nickname(Req, Nickname, UserToken) ->
	ok = cowboy_req:chunk(["event: nickname\n", "id: ", gen_timestamp_id(), "\n", "data: ", Nickname, "; ", UserToken, "\n\n"], Req).

notify_all(Message) ->
	lists:foreach(
		fun(Listener) ->
			lager:debug("notify ~p: ~p", [Listener, Message]),
			Listener ! {message, Message}
		end, pg2:get_members(notify_group)).

gen_timestamp_id() ->
	{M, S, U} = erlang:now(),  
	lists:concat([M * 1000000 + S, ".", U]).

gen_nickname() ->
	get_random_string(2, "ABCDEFGHIJKLMNOPQRSTUVWXYZ") ++ "-0" ++ get_random_string(2, "0123456789").

get_random_string(Length, AllowedChars) ->
	lists:foldl(fun(_, Acc) ->
		[lists:nth(random:uniform(length(AllowedChars)), AllowedChars)] ++ Acc
	end, [], lists:seq(1, Length)).


% export from https://github.com/ninenines/cowboy/blob/master/src/cowboy_req.erl
-spec match_body_qs(cowboy:fields(), binary()) -> map().
match_body_qs(Fields, Body) ->
	cowboy_req:filter(Fields, cowboy_req:kvlist_to_map(Fields, cow_qs:parse_qs(Body))).
