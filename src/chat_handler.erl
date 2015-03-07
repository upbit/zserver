-module(chat_handler).
-behaviour(cowboy_websocket_handler).

-export([init/3]).
-export([websocket_init/3]).
-export([websocket_handle/3]).
-export([websocket_info/3]).
-export([websocket_terminate/3]).

-record(state, {
	last_index = 0
}).

init(_, _, _) ->
	{upgrade, protocol, cowboy_websocket}.

websocket_init(_, Req, _Opts) ->
	Req2 = cowboy_req:compact(Req),
	{ok, Req2, #state{}}.

websocket_handle({text, <<$G, _/binary>>}, Req, State) ->
	{Index, Reply} = chatroom_server:get(State#state.last_index),
	lager:error(">> get: Index=~p, Reply=~p", [Index, Reply]),
	{reply, {text, binary:list_to_bin(Reply)}, Req, State#state{last_index=Index}};
websocket_handle({text, <<$A, Msg/binary>>}, Req, State) ->
	NewIndex = chatroom_server:add(Msg),
	lager:error(">> add: Index=~p", [NewIndex]),
	{ok, Req, State};
websocket_handle(_Frame, Req, State) ->
	lager:error("Unknown Frame=~p", [_Frame]),
	{ok, Req, State}.

websocket_info(_Info, Req, State) ->
	lager:error("WebSocket info: ~p", [_Info]),
	{ok, Req, State}.

websocket_terminate(_Reason, _Req, _State) ->
	ok.
