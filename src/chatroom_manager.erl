-module(chatroom_manager).
-behaviour(gen_server).

%% API
-export([start_link/0]).

%% gen_server callbacks
-export([init/1,
         handle_call/3,
         handle_cast/2,
         handle_info/2,
         terminate/2,
         code_change/3]).

-define(SERVER, ?MODULE).
-define(ETS_SERVER, chatroom_server).

-record(state, {
			init = true,
			table_id::ets:tid()
		}).

%% gen_server functions

start_link() ->
	gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).

init([]) ->
	process_flag(trap_exit, true),
	%% create ets and give_away to server
	Server = whereis(?ETS_SERVER),
	link(Server),
	TableId = ets:new(?MODULE, [private, {heir, self(), []}]),
	ets:give_away(TableId, Server, []),
	{ok, #state{table_id=TableId}}.

handle_call(_Msg, _From, State) ->
	{reply, ok, State}.

handle_cast(_Msg, State) ->
	{noreply, State}.

handle_info({'EXIT',Pid,Reason}, State) ->
	lager:warning("Server(~p) !! dead: ~p, farewell TableId: ~p~n", [Pid, Reason, State#state.table_id]),
	{noreply, State};
handle_info({'ETS-TRANSFER', TableId, Pid, Data}, State) ->
	Server = wait_for_server(),
	lager:warning("Warning TableId: ~p OwnerPid: ~p is dying~n"
				"Server(~p) => Manager(~p) handing TableId: ~p~n", [TableId, Pid, Pid, self(), TableId]),
	link(Server),
	ets:give_away(TableId, Server, Data),
	{noreply, State#state{table_id=TableId}}.

terminate(_Reason, _State) ->
	ok.

code_change(_OldVsn, State, _Extra) ->
	{ok, State}.


%% Internal functions

wait_for_server() -> 
	case whereis(?ETS_SERVER) of
		undefined -> 
			timer:sleep(1),
			wait_for_server();
		Pid -> Pid
	end.
