PROJECT = zserver
DEPS = cowboy lager jsx sync
include erlang.mk

ERLC_OPTS = +debug_info +'{parse_transform, lager_transform}' \
			+warn_unused_vars +warn_export_all +warn_shadow_vars +warn_unused_import \
			+warn_bif_clash +warn_unused_record +warn_deprecated_function \
			+warn_obsolete_guard +strict_validation +report +warn_export_vars +warn_exported_vars \
			+warn_unused_function +warn_untyped_record #+warn_missing_spec
ERL_LIBS = _rel/zserver_release/lib
BOOT_PATH = _rel/zserver_release/releases/1/zserver_release

RELX_EXPORTS = start foreground stop restart reboot ping console console_clean attach escript
$(RELX_EXPORTS)::
	./_rel/$(PROJECT)_release/bin/$(PROJECT)_release $@
tail::
	tail -n 120 $(shell ls -1 ./_rel/$(PROJECT)_release/log/erlang.log* | tail -n 1)

run::
	erl -name zserver@127.0.0.1 -setcookie zserver -pa deps/*/ebin -pa deps/*/deps/*/ebin -pa ebin/ \
		-heart +K true +A 64 +P 10240000 -smp enable \
		+pc unicode -s lager -boot ${BOOT_PATH}
