-module(event_handler).

-export([init/3]).
-export([info/3]).
-export([terminate/3]).

-record(state, {
	count::integer()
}).


init(_Type, Req, _Opts) ->
	Headers = [{<<"content-type">>, <<"text/event-stream">>}],
	{ok, Req2} = cowboy_req:chunked_reply(200, Headers, Req),
	erlang:send_after(1000, self(), {message, "Init Tick"}),
	{loop, Req2, #state{count=0}, hibernate}.

info({message, Msg}, Req, State) ->
	ok = cowboy_req:chunk(["id: ", id(), "\ndata: ", Msg, "\n\n"], Req),
	erlang:send_after(1000, self(), {message, lists:flatten(io_lib:format("Tick(~p)~n", [State#state.count]))}),
	{loop, Req, State#state{count = State#state.count + 1}, hibernate}.

terminate(_Reason, _Req, _State) ->
	ok.

id() ->
	{Mega, Sec, Micro} = erlang:now(),
	Id = (Mega * 1000000 + Sec) * 1000000 + Micro,
	integer_to_list(Id, 16).
