-module(chat_handler).

-export([init/2, allowed_methods/2, content_types_accepted/2, info/3]).
-export([handle_post/2]).

init(Req, Opts) ->
	case cowboy_req:method(Req) of
		<<"POST">> ->
			{cowboy_rest, Req, Opts};
		<<"GET">> ->
			random:seed(erlang:now()),

			%% start chunk reply
			Req1 = chunk_start(Req),
			ok = send_event(Req1, info, <<"(´・ω・`) I am ready."/utf8>>),

			%% join pg2 notify group
			ok = pg2:create(chat_notify_group),
			ok = pg2:join(chat_notify_group, self()),
			{cowboy_loop, Req1, Opts, hibernate}
	end.

%% only allowed post for REST
allowed_methods(Req, State) ->
	{[<<"POST">>], Req, State}.
content_types_accepted(Req, State) ->
	{[{<<"application/x-www-form-urlencoded">>, handle_post}], Req, State}.

%%
info({message, Message}, Req, State) ->
	ok = send_message(Req, Message),
	{ok, Req, State, hibernate}.

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


%% Internal functions - chunk

%% @doc Send event-stream header to client
chunk_start(Req) ->
	Headers = [
		{<<"content-type">>, <<"text/event-stream">>},
		{<<"connection">>, <<"keep-alive">>}
	],
	cowboy_req:chunked_reply(200, Headers, Req).

send_message(Req, Data) ->
	send_event(Req, message, Data).

-spec send_event(term(), atom() | list(), binary()) -> ok.
send_event(Req, Event, Data) when is_atom(Event) ->
	send_event(Req, atom_to_list(Event), Data);
send_event(Req, Event, Data) when is_list(Event), is_binary(Data) ->
	EventBinary = binary:list_to_bin(["event: ", Event, "\n"]),
	IdBinary = binary:list_to_bin(["id: ", gen_timestamp_id(), "\n"]),
	Response = <<
		EventBinary/binary, IdBinary/binary,
		<<"data: ">>/binary, Data/binary, <<"\n\n">>/binary
	>>,
	cowboy_req:chunk(Response, Req).


%% Internal functions - utils


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
