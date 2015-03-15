-module(zserver_app).
-behaviour(application).

-export([start/2]).
-export([stop/1]).

start(_Type, _Args) ->
	Dispatch = cowboy_router:compile([
		{'_', [
			{"/main", main_handler, []},
			{"/chat_eventsource", chat_handler, []},

			%% static handlers
			{"/", cowboy_static, {priv_file, zserver, "index.html"}},
			{"/chat", cowboy_static, {priv_file, zserver, "chat.html"}},
			{"/static/[...]", cowboy_static, {priv_dir, zserver, "static"}}
		]}
	]),
	CowboyOptions = [
		{env, [{dispatch, Dispatch}]},
		{compress, true},
		{max_connections, infinity},
		{onresponse, fun http_response_hook/4}
	],
	cowboy:start_http(http_listener, 100, [{port, 8080}], CowboyOptions),
	zserver_sup:start_link().

stop(_State) ->
	ok.

%% ===================================================================
%% http_response_hook/4
%% ===================================================================

%% HTTP 404
http_response_hook(404, Headers, <<>>, Req) ->
	{Path, _} = cowboy_req:path(Req),
	Body = ["404 Not Found: ", Path, "\n"],
	reply_with_new_body(404, Headers, Body, Req);
%% others
http_response_hook(Status, Headers, <<>>, Req) when is_integer(Status), Status >= 400 ->
	Body = ["HTTP Error ", integer_to_list(Status), $\n],
	reply_with_new_body(Status, Headers, Body, Req);

http_response_hook(_Status, _Headers, _Body, Req) ->
	%{ok, Req2} = cowboy_req:reply(Status, [{cowboy_bstr:capitalize_token(N), V} || {N, V} <- Headers], Body, Req),
	Req.

reply_with_new_body(Status, Headers, NewBody, Req) ->
	Headers2 = lists:keyreplace(<<"content-length">>, 1, Headers,
		{<<"content-length">>, integer_to_list(iolist_size(NewBody))}),
	cowboy_req:reply(Status, Headers2, NewBody, Req).
