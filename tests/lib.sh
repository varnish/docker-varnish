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
