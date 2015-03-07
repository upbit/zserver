-module(rest_handler).

-export([init/3]).
-export([content_types_provided/2]).
-export([get_html/2]).
-export([get_json/2]).

init(_, _Req, _Opts) ->
	{upgrade, protocol, cowboy_rest}.

content_types_provided(Req, State) ->
	{[
		{<<"text/html">>, get_html},
		{<<"application/json">>, get_json}
	], Req, State}.

get_html(Req, State) ->
	{<<"<html><body>This is REST!</body></html>">>, Req, State}.

get_json(Req, State) ->
	Body = jsx:encode(#{
		<<"body">> => <<"This is REST!">>
	}),
	{Body, Req, State}.