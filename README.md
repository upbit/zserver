zserver
--------------------
My first server written in Erlang

# HowTo

## build release

~~~sh
make deps
make
~~~

## run

~~~sh
make start
~~~

## other

~~~sh
# stop
make stop

# restart
make restart

# attach erlang shell
make attach

# tail lastest log
make tail
~~~

# Apps

~~~erlang
%% @doc Show auto sync files
%%  syntax_tools, compiler, sync
sync_scaner:info().

%% @doc Start observer server
%%  observer, runtime_tools, wx
observer:start().
~~~
