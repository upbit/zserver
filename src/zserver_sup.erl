-module(zserver_sup).
-behaviour(supervisor).

-export([start_link/0]).
-export([init/1]).

%% Helper macro for declaring children of supervisor
-define(CHILD(I, Type), {I, {I, start_link, []}, permanent, 5000, Type, [I]}).

start_link() ->
	supervisor:start_link({local, ?MODULE}, ?MODULE, []).

init([]) ->
	ok = pg2:create(notify_group),
	Procs = [
		?CHILD(chatroom_server, worker),
		?CHILD(chatroom_manager, worker)
	],
	{ok, {{one_for_one, 5, 10}, Procs}}.
