# helpers sourced by every test, IMAGE is set by run.sh

set -Eeuo pipefail

fail() {
	echo "FAIL: $*" >&2
	exit 1
}

# run a shell snippet inside the image under test
in_image() {
	docker run --rm --entrypoint sh "$IMAGE" -c "$*"
}

# usage: assert_file_eq EXPECTED_FILE ACTUAL_STRING
assert_file_eq() {
	if ! diff -u --label expected --label actual "$1" <(printf '%s\n' "$2"); then
		fail "output doesn't match $1"
	fi
}

# run the image entrypoint with varnishd and mkfs.mse4 replaced by stubs that
# print their arguments instead of doing anything, so tests can check the
# command line the entrypoint builds
# usage: run_entrypoint [DOCKER_RUN_OPTS...] -- [ARGS...]
# set ENTRYPOINT to a local script to test it against IMAGE without rebuilding
run_entrypoint() {
	local opts=()
	while [ $# -gt 0 ] && [ "$1" != "--" ]; do
		opts+=("$1")
		shift
	done
	[ $# -gt 0 ] && shift

	if [ -z "${STUBS:-}" ]; then
		STUBS="$(mktemp -d)"
		trap 'rm -rf "$STUBS"' EXIT
		for bin in varnishd mkfs.mse4; do
			cat > "$STUBS/$bin" <<- STUB
				#!/bin/sh
				printf '$bin'
				printf ' [%s]' "\$@"
				echo
			STUB
		done
		chmod 755 "$STUBS" "$STUBS"/*
	fi
	if [ -n "${ENTRYPOINT:-}" ]; then
		opts+=(-v "$(realpath "$ENTRYPOINT"):/usr/local/bin/docker-varnish-entrypoint:ro")
	fi

	docker run --rm \
		-v "$STUBS:/stubs:ro" \
		-e PATH=/stubs:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin \
		"${opts[@]}" \
		"$IMAGE" "$@" 2>&1 || echo "exit status: $?"
}
