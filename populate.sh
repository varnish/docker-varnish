#!/usr/bin/env bash

set -e
declare -A IMAGES

CONFIG='
{
	"stable": {
		"debian": "bullseye",
		"version": "6.0.10",
		"tags": "6.0",
		"pkg-commit": "10da6a585eb7d8defe9d273a51df5b133500eb6b",
		"dist-sha512": "b89ac4465aacde2fde963642727d20d7d33d04f89c0764c43d59fe13e70fe729079fef44da28cc0090fa153ec584a0fe9723fd2ce976e8e9021410a5f73eadd2"
	},
       "old": {
               "debian": "bullseye",
               "version": "6.6.2",
               "tags": "6.6",
               "pkg-commit": "d3e6a3fad7d4c2ac781ada92dcc246e7eef9d129",
               "dist-sha512": "8fa163678e2e454fcc959ba24f349de00e6c00357df55f37f12f0d3acbcb2799b2f376385cef2d40c14a4cc44a5eea1b5a3fbf6245961611d4fc3ea30699035d"
       },
	"fresh": {
		"debian": "bullseye",
		"version": "7.0.2",
		"tags": "7.0 latest",
		"pkg-commit": "d3e6a3fad7d4c2ac781ada92dcc246e7eef9d129",
		"dist-sha512": "5eb08345c95152639266b7ad241185188477f8fd04e88e4dfda1579719a1a413790a0616f25d70994f6d3b8f7640ea80926ece7c547555dad856fd9f6960c9a3"
	},
	"next": {
		"debian": "bullseye",
		"version": "7.0.2",
		"tags": "7.0 latest",
		"pkg-commit": "d3e6a3fad7d4c2ac781ada92dcc246e7eef9d129",
		"dist-sha512": "5eb08345c95152639266b7ad241185188477f8fd04e88e4dfda1579719a1a413790a0616f25d70994f6d3b8f7640ea80926ece7c547555dad856fd9f6960c9a3"
	}
}'

update_dockerfiles() {
	DEBIAN=`echo $CONFIG | jq -r ".[\"$1\"][\"debian\"]"`
	VARNISH_VERSION=`echo $CONFIG | jq -r ".[\"$1\"][\"version\"]"`
	DIST_SHA512=`echo $CONFIG | jq -r ".[\"$1\"][\"dist-sha512\"]"`
	PKG_COMMIT=`echo $CONFIG | jq -r ".[\"$1\"][\"pkg-commit\"]"`

	sed $1/$2/Dockerfile.tmpl \
		-e "s/@DEBIAN@/$DEBIAN/" \
		-e "s/@VARNISH_VERSION@/$VARNISH_VERSION/" \
		-e "s/@DIST_SHA512@/$DIST_SHA512/" \
		-e "s/@PKG_COMMIT@/$PKG_COMMIT/" \
		> $1/$2/Dockerfile
}

populate_dockerfiles() {
	for i in `echo $CONFIG | jq -r 'keys | .[]'`; do
		update_dockerfiles $i debian
		[ "$i" != "stable" ] && update_dockerfiles $i alpine
	done
}

update_library(){
	version=`echo $CONFIG | jq -r ".[\"$1\"][\"version\"]"`
	tags=`echo $CONFIG | jq -r ".[\"$1\"][\"tags\"]"`
	tags="$1 $version $tags"

	if [ "$2" != "debian" ]; then
		tags=`echo "$tags" | sed -e "s/\( \|$\)/-$2\1/g" -e "s/latest-$2/$2/"`
	fi

	cat >> library.varnish <<- EOF

		Tags: `echo $tags | sed 's/ \+/, /g'`
		Architectures: amd64, arm32v7, arm64v8, i386, ppc64le, s390x
		Directory: $1/$2
		GitCommit: `git log -n1 --pretty=oneline $1/$2 | cut -f1 -d" "`
	EOF
}

populate_library() {
	cat > library.varnish <<- EOF
		# this file was generated using https://github.com/varnish/docker-varnish/blob/`git rev-parse HEAD`/populate.sh
		Maintainers: Guillaume Quintard <guillaume@varni.sh> (@gquintard)
		GitRepo: https://github.com/varnish/docker-varnish.git
	EOF

	for i in `echo $CONFIG | jq -r 'keys | .[]'`; do
		if [ "$i" = "next" ]; then
			continue
		fi
		update_library $i debian
		if [ "$i" != "stable" ]; then
			update_library $i alpine
		fi
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
