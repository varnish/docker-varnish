#!/bin/bash
set -ex

cd "$(dirname "$0")"
docker build . -t varnish/enterprise:latest

VARNISH_VERSION=$(docker run --rm varnish/enterprise:latest varnishd -V 2>&1 | sed -En 's/^varnishd \(varnish-plus-(.*) revision .*/\1/p')

TAGS=latest
while [ -n "$VARNISH_VERSION" ]; do
	TAGS+=" $VARNISH_VERSION"

	VARNISH_VERSION=$(echo $VARNISH_VERSION | sed -E 's/.?[^.]*$//')
done

echo TAGS: $TAGS

for t in $TAGS; do
	docker tag varnish/enterprise varnish/enterprise:$t
done
docker push varnish/enterprise --all-tags
