#!/bin/bash
set -ex

cd "$(dirname "$0")"

VARNISH_VERSION=$(grep '^ARG VARNISH_PLUS_VERSION=' Dockerfile | cut -d= -f2)

TAGS=latest
while [ -n "$VARNISH_VERSION" ]; do
	TAGS+=" $VARNISH_VERSION"

	VARNISH_VERSION=$(echo $VARNISH_VERSION | sed -E 's/.?[^.]*$//')
done

echo TAGS: $TAGS

TAG_ARGS=""
for t in $TAGS; do
	TAG_ARGS+=" -t varnish/enterprise:$t -t varnish/varnish-enterprise:$t"
done

docker buildx build \
	--platform linux/amd64,linux/arm64 \
	--push \
	$TAG_ARGS \
	.
