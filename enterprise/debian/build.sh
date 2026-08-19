#!/bin/bash
set -ex

cd "$(dirname "$0")"

PUSH=
if [ -n "$1" ]; then
	if [ "$1" = "push" ]; then
		PUSH=--push
	else
		echo "invalid argument: $1"
	fi
fi

VARNISH_VERSION=$(grep '^ARG VARNISH_PLUS_VERSION=' Dockerfile | cut -d= -f2)

TAGS=latest
while [ -n "$VARNISH_VERSION" ]; do
	TAGS+=" $VARNISH_VERSION"
	[[ "$VARNISH_VERSION" != *[-r.]* ]] && break
	VARNISH_VERSION="${VARNISH_VERSION%[-r.]*}"
done

echo TAGS: $TAGS

TAG_ARGS=""
for t in $TAGS; do
	TAG_ARGS+=" -t varnish/enterprise:$t -t varnish/varnish-enterprise:$t"
done

for t in "regular" "sledge" "all"; do
	case "$t" in
		regular)
			EXTRA=
			ext=
			;;
		sledge)
			EXTRA="--build-arg EXTRA_PKGS=sledge"
			ext=-sledge
			;;
		all)
			EXTRA='--build-arg EXTRA_PKGS=all'
			ext=-sledge-tools
			;;
	esac

	TAG_ARGS=
	for t in $TAGS; do
		TAG_ARGS+=" -t varnish/enterprise$ext:$t -t varnish/varnish-enterprise$ext:$t"
	done

	docker buildx build \
		--platform linux/amd64,linux/arm64 \
		$PUSH \
		$TAG_ARGS \
		$EXTRA \
		.
done
