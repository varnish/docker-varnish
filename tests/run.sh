#!/usr/bin/env bash
#
# usage: tests/run.sh IMAGE SUITE [TEST...]
#
# run all the tests in tests/SUITE/ (or only the named ones) against IMAGE,
# each test is an executable tests/SUITE/NAME.sh that gets IMAGE as $1 and
# in its environment, and fails by exiting with a non-zero status

set -Eeuo pipefail

if [ $# -lt 2 ]; then
	echo "usage: $0 IMAGE SUITE [TEST...]" >&2
	exit 2
fi

export IMAGE="$1"
SUITE="$2"
shift 2

dir="$(cd "$(dirname "$0")" && pwd)/$SUITE"
if [ ! -d "$dir" ]; then
	echo "unknown suite: $SUITE" >&2
	exit 2
fi

tests=()
if [ $# -gt 0 ]; then
	for t in "$@"; do
		tests+=("$dir/$t.sh")
	done
else
	for t in "$dir"/*.sh; do
		[ -x "$t" ] && tests+=("$t")
	done
fi

failed=()
for t in "${tests[@]}"; do
	name="$SUITE/$(basename "$t" .sh)"
	[ -n "${GITHUB_ACTIONS:-}" ] && echo "::group::$name"
	if "$t" "$IMAGE"; then
		res=PASS
	else
		res=FAIL
		failed+=("$name")
	fi
	[ -n "${GITHUB_ACTIONS:-}" ] && echo "::endgroup::"
	echo "$res $name"
done

echo "${#tests[@]} test(s), ${#failed[@]} failure(s)"
for f in "${failed[@]}"; do
	[ -n "${GITHUB_ACTIONS:-}" ] && echo "::error::$f failed on $IMAGE"
done
[ ${#failed[@]} -eq 0 ]
