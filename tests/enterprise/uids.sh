#!/usr/bin/env bash
#
# uids/gids must never change between releases, otherwise files owned by the
# varnish users on mounted volumes become unreadable after an upgrade

. "$(dirname "$0")/../lib.sh"

actual="$(in_image '
	for u in varnish vcache varnishlog vbcast; do
		getent passwd $u | cut -d: -f1,3,4 | sed "s/^/passwd:/"
	done
	for g in varnish vbcast; do
		getent group $g | cut -d: -f1,3 | sed "s/^/group:/"
	done
')"

assert_file_eq "$(dirname "$0")/uids.expected" "$actual"
