PROJECT = zserver
DEPS = cowboy lager jsx sync
include erlang.mk

ERLC_OPTS = +debug_info +'{parse_transform,lager_transform}'

RELX_EXPORTS = start foreground stop restart reboot ping console console_clean attach escript
$(RELX_EXPORTS)::
	./_rel/$(PROJECT)_release/bin/$(PROJECT)_release $@
tail::
	tail -n 120 $(shell ls -1 ./_rel/$(PROJECT)_release/log/erlang.log* | tail -n 1)
