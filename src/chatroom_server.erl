-module(chatroom_server).
-behaviour(gen_server).

%% API
-export([start_link/0,
         add/1,
         get/1,
         tab2list/0,
         stop/0]).

%% gen_server callbacks
-export([init/1,
         handle_call/3,
         handle_cast/2,
         handle_info/2,
         terminate/2,
         code_change/3]).

-define(DEFAULT_CHATROOM, global).
-define(MAX_CACHE_CHATS, 10).
-define(MAX_MESSAGE_LEN, 256).

-record(state, {
			init = true,
			room = ?DEFAULT_CHATROOM,
			table_id::ets:tid()
		}).

%% @doc Add Msg in room, return Msg index
-spec add(binary()) -> integer().
add(Msg) ->
	gen_server:call(?MODULE, {add, Msg}).
%% @doc Get Msgs from room, return Msgs List
-spec get(non_neg_integer()) -> [ binary() ].
get(Index) ->
	gen_server:call(?MODULE, {get, Index}).

tab2list() ->
	gen_server:call(?MODULE, tab2list).
stop() ->
	gen_server:cast(?MODULE, stop).

%% gen_server functions

start_link() ->
	gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).

init([]) ->
	{ok, #state{}}.

handle_call({add, Msg}, _From, State) when is_binary(Msg), size(Msg) =< ?MAX_MESSAGE_LEN ->
	{reply, add_message(State#state.table_id, State#state.room, Msg), State};
handle_call({add, Msg}, _From, State) when is_list(Msg), length(Msg) =< ?MAX_MESSAGE_LEN ->
	{reply, add_message(State#state.table_id, State#state.room, binary:list_to_bin(Msg)), State};
handle_call({get, Index}, _From, State) when is_integer(Index), Index >= 0 ->
	{reply, get_messages(State#state.table_id, State#state.room, Index), State};
handle_call(tab2list, _From, State) ->
	{reply, ets:tab2list(State#state.table_id), State}.

handle_cast(stop, State) ->
	{stop, {stopped,manually}, State}.

handle_info({'ETS-TRANSFER', TableId, Pid, _Data}, State) ->
	lager:warning("Manager(~p) -> Server(~p) getting TableId: ~p~n", [Pid, self(), TableId]),
	{noreply, State#state{table_id=TableId}};
handle_info(_Info, State) ->
	{noreply, State}.

terminate(_Reason, _State) ->
	ok.

code_change(_OldVsn, State, _Extra) ->
	{ok, State}.

%% Internal functions

add_message(Table, Room, Msg) ->
	Chats = get_room_chats(Table, Room),
	{Index, _} = hd(Chats),
	NewChats = lists:sublist([{Index+1,Msg}|Chats], 1, ?MAX_CACHE_CHATS),
	true = ets:insert(Table, {Room, NewChats}),
	Index+1.

get_messages(Table, Room, FromIndex) ->
	Chats = get_room_chats(Table, Room),
	{NewestIndex, _} = hd(Chats),
	ReverseChats = lists:reverse(Chats),
	{OldestIndex, _} = hd(ReverseChats),
	Result = case OldestIndex =< (FromIndex+1) of
		true ->
			%% get data from Head to FromIndex
			SubChats = lists:takewhile(fun({Idx,_Msg})-> Idx > FromIndex end, Chats),
			{_, Data} = lists:unzip(SubChats),
			lists:reverse(Data);
		false ->
			%% insert lost message number
			{_, Data} = lists:unzip(ReverseChats),
			[list_to_binary(io_lib:format("> Omit ~p message...\n", [OldestIndex-(FromIndex+1)])) | Data]
	end,
	{NewestIndex, Result}.

get_room_chats(Table, Room) ->
	case ets:lookup(Table, Room) of
		[{Room, Chats}] -> Chats;
		[] -> [{1, list_to_binary(io_lib:format("> Welcome to '~p'\n", [Room]))}]
	end.
