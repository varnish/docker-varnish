#!/bin/bash
set -ex

DEBIAN_VERSION=bookworm
IMAGE_VERSION=6.0.16r4
TAGS="latest 6 6.0 6.0.16 6.0.16r4"
VARNISH_PLUS_VERSION="$IMAGE_VERSION-1~$DEBIAN_VERSION"
VARNISH_OTEL_VERSION="1.2.1-1~$DEBIAN_VERSION"

docker build . $(echo "$TAGS" | sed -E 's@(^|\s)+@ -t varnish/enterprise:@g')
docker push    $(echo "$TAGS" | sed -E 's@(^|\s)+@    varnish/enterprise:@g')
