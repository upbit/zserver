-module(ws_handler).
-behaviour(cowboy_websocket_handler).

-export([init/3]).
-export([websocket_init/3]).
-export([websocket_handle/3]).
-export([websocket_info/3]).
-export([websocket_terminate/3]).

-record(state, {
	message_position = 0
}).

init(_, _, _) ->
	{upgrade, protocol, cowboy_websocket}.

websocket_init(_, Req, _Opts) ->
	Req2 = cowboy_req:compact(Req),
	{ok, Req2, #state{}}.

websocket_handle({text, RawData}, Req, State) ->
	Data = re:replace(RawData, "(^\\s+)|(\\s+$)", "", [{return, list}]),
	parse_message(Data, Req, State);
websocket_handle(_Frame, Req, State) ->
	{ok, Req, State}.

websocket_info({timeout, _Ref, Msg}, Req, State) ->
	erlang:start_timer(1000, self(), <<"How are you doing?">>),
	{reply, {text, Msg}, Req, State};
websocket_info(_Info, Req, State) ->
	{ok, Req, State}.

websocket_terminate(_Reason, _Req, _State) ->
	ok.

parse_message("help", Req, State) ->
	Body = {text, <<">>> WebSocket help:\n"
					"  WebSocket is a protocol providing full-duplex "
					"communications channels over a single TCP connection."
					"The WebSocket protocol was standardized by the IETF as RFC 6455 in 2011, "
					"and the WebSocket API in Web IDL is being standardized by the W3C.\n">>},
	{reply, Body, Req, State};
parse_message("exit", Req, State) ->
	{shutdown, Req, State};
parse_message(Command, Req, State) ->
	Body = {text, binary:list_to_bin(["WS> ", Command, "\n"])},
	{reply, Body, Req, State}.
