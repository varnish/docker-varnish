#!/usr/bin/env bash

set -e
declare -A IMAGES

CONFIG='
{
	"6.0": {
		"dist": "buster",
		"workdir": "stable/debian",
		"repo": "60lts",
		"pkg": "6.0.7-1~buster",
		"tags": "6.0.7-1 6.0.7 stable",
		"key": "48D81A24CB0456F5D59431D94CFCFD6BA750EDCD"
	},
	"6.6": {
		"dist": "buster",
		"workdir": "fresh/debian",
		"repo": "66",
		"pkg": "6.6.0-1~buster",
		"tags": "6.6.0-1 6.6.0 6 latest fresh",
		"key": "A0378A38E4EACA3660789E570BAC19E3F6C90CD5"
	}
}'

update_dockerfiles() {
	key=`echo $CONFIG | jq -r ".[\"$1\"][\"key\"]"`
	workdir=`echo $CONFIG | jq -r ".[\"$1\"][\"workdir\"]"`
	repo=`echo $CONFIG | jq -r ".[\"$1\"][\"repo\"]"`
	package=`echo $CONFIG | jq -r ".[\"$1\"][\"pkg\"]"`
	dist=`echo $CONFIG | jq -r ".[\"$1\"][\"dist\"]"`

	mkdir -p $workdir

	cp docker-varnish-entrypoint $workdir

	curl -fL https://packagecloud.io/varnishcache/varnish$repo/gpgkey -o $workdir/gpgkey

	cat > $workdir/Dockerfile << EOF
FROM debian:$dist-slim

ENV VARNISH_VERSION $package
ENV VARNISH_SIZE 100M

RUN set -ex; \\
	fetchDeps=" \\
		dirmngr \\
		gnupg \\
	"; \\
	apt-get update; \\
	apt-get install -y --no-install-recommends apt-transport-https ca-certificates \$fetchDeps; \\
	key=$key; \\
	export GNUPGHOME="\$(mktemp -d)"; \\
	gpg --batch --keyserver ha.pool.sks-keyservers.net --recv-keys \$key; \\
	gpg --batch --export export \$key > /etc/apt/trusted.gpg.d/varnish.gpg; \\
	gpgconf --kill all; \\
	rm -rf \$GNUPGHOME; \\
	echo deb https://packagecloud.io/varnishcache/varnish$repo/debian/ $dist main > /etc/apt/sources.list.d/varnish.list; \\
	apt-get update; \\
	apt-get install -y --no-install-recommends varnish=\$VARNISH_VERSION; \\
	apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false \$fetchDeps; \\
	rm -rf /var/lib/apt/lists/*

WORKDIR /etc/varnish

COPY docker-varnish-entrypoint /usr/local/bin/
ENTRYPOINT ["docker-varnish-entrypoint"]

EXPOSE 80 8443
CMD []
EOF
}

populate_dockerfiles() {
	for i in `echo $CONFIG | jq -r 'keys | .[]'`; do
		update_dockerfiles $i
	done
}

update_library(){
	name=$1
	workdir=`echo $CONFIG | jq -r ".[\"$1\"][\"workdir\"]"`
	tags=`echo $CONFIG | jq -r ".[\"$1\"][\"tags\"]"`

	cat >> library.varnish <<- EOF

		Tags: `echo $name $tags | sed 's/ \+/, /g'`
		Architectures: amd64
		Directory: $workdir
		GitCommit: `git log -n1 --pretty=oneline $workdir | cut -f1 -d" "`
	EOF
}

populate_library() {
	cat > library.varnish <<- EOF
		# this file was generated using https://github.com/varnish/docker-varnish/blob/`git rev-parse HEAD`/populate.sh
		Maintainers: Guillaume Quintard <guillaume@varni.sh> (@gquintard)
		GitRepo: https://github.com/varnish/docker-varnish.git
	EOF

	for i in `echo $CONFIG | jq -r 'keys | .[]'`; do
		update_library $i
	done
}

case "$1" in
	dockerfiles)
		populate_dockerfiles
		;;
	library)
		populate_library
		;;
	*)
		echo invalid choice
		exit 1
		;;
esac
