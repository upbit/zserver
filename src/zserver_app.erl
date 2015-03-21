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
		{max_connections, infinity}
	],
	cowboy:start_http(http_listener, 100, [{port, 8080}], CowboyOptions),
	zserver_sup:start_link().

stop(_State) ->
	ok.
