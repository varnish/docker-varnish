#!/usr/bin/env bash
#
# the varnishd command line built by the entrypoint is part of the image API:
# users rely on the environment variables, and sometimes on word splitting to
# sneak extra arguments in, so any change here must be deliberate

. "$(dirname "$0")/../lib.sh"

run() {
	echo "## $1"
	shift
	run_entrypoint "$@"
}

actual="$(
	run "defaults" --
	run "extra flags are appended" -- -p default_ttl=10 -n /tmp/foo
	run "non-flag command runs as-is" -- echo hello world
	run "variables" \
		-e VARNISH_VCL_FILE=/etc/varnish/other.vcl \
		-e VARNISH_HTTP_PORT=8080 \
		-e VARNISH_PROXY_PORT=8081 \
		-e VARNISH_SIZE=2G --
	run "empty VARNISH_SIZE means unlimited malloc" -e VARNISH_SIZE= --
	run "no word splitting in VARNISH_SIZE" -e 'VARNISH_SIZE=1G -p default_ttl=5' --
	run "no word splitting in other variables" \
		-e 'VARNISH_VCL_FILE=/etc/varnish/a.vcl -p vcc_allow_inline_c=on' \
		-e 'VARNISH_HTTP_PORT=80 -a :6081' \
		-e 'VARNISH_PROXY_PORT=8443 -a :6082' --
	run "no globbing" -e 'VARNISH_VCL_FILE=/etc/*' --
	run "VARNISH_STORAGE_BACKEND=malloc" -e VARNISH_STORAGE_BACKEND=malloc -e VARNISH_SIZE=1G --
	run "empty VARNISH_STORAGE_BACKEND defaults to malloc" -e VARNISH_STORAGE_BACKEND= --
	run "invalid VARNISH_STORAGE_BACKEND" -e VARNISH_STORAGE_BACKEND=mse4 --
)"

assert_file_eq "$(dirname "$0")/entrypoint.expected" "$actual"
