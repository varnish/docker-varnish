#!/usr/bin/env bash

set -e
declare -A IMAGES

CONFIG='
{
	"stable": {
		"debian": "bullseye",
		"version": "6.0.12",
		"tags": "6.0",
		"pkg-commit": "10da6a585eb7d8defe9d273a51df5b133500eb6b",
		"dist-sha512": "d80abb42380e85bc4be02278b3620b0a66d182465945146eecb2cdc022e77945ad815e897a5ed0bec2f458471617f647a80c743c0f72e73334ad92d3ac298af4"
	},
	"old": {
		"debian": "bullseye",
		"version": "7.3.1",
		"tags": "7.3",
		"pkg-commit": "712667312304cbb1798f131caa0a98b7697a2cd9",
		"dist-sha512": "57de14ff47038752a151b704d7f629438bba74e258e7d88c6ca58e8a10bfc89368f36b7f32d5525ff032033d941f3e48dde5ae090e44ca928110d2eeb1db589d",
		"varnish-modules-version": "0.22.0",
		"varnish-modules-sha512sum": "597ac1161224a25c11183fbaaf25412c8f8e0af3bf58fa76161328d8ae97aa7c485cfa6ed50e9f24ce73eca9ddeeb87ee4998427382c0fce633bf43eaf08068a",
		"vmod-dynamic-version": "2.8.0",
		"vmod-dynamic-commit": "af9c51cb53982b42eed6116960015c09171838b0",
		"vmod-dynamic-sha512sum": "4a91de4a1fc3e6eb925ac5e8c9d56d9786c368fbbb3b957285bd0edf4e955ee19ad1ee6b4b3c4754cf5885be6593c269419c19fea36760513397d92085e105de"
	},
	"fresh": {
		"debian": "bookworm",
		"version": "7.4.2",
		"tags": "7.4 latest",
		"pkg-commit": "cfa8cb3724e4ca6398f60b09157715bcb99d189d",
		"dist-sha512": "acd61a852ac7d66b268ab831d3a771d7a063a6a257b5e7c25c5a2ec9bccefa845279b9bd5fc85dd0b4f1d56da59164a13149355d1e6187e71ad76463687f7971",
		"varnish-modules-version": "0.22.0",
		"varnish-modules-sha512sum": "597ac1161224a25c11183fbaaf25412c8f8e0af3bf58fa76161328d8ae97aa7c485cfa6ed50e9f24ce73eca9ddeeb87ee4998427382c0fce633bf43eaf08068a",
		"vmod-dynamic-version": "2.8.0-1",
		"vmod-dynamic-commit": "15e32fb8cf96752c90d895b0ca31451bd05d92d9",
		"vmod-dynamic-sha512sum": "d62d7af87770ef370c2e78e5b464f4f7712ebb50281728ca157ff38303f5455f1afdc0f8efaf0040febdf2d0aedbfa4c3369fe0f9d634ed34f185b54876cb4d1"
	}
}'

TOOLBOX_COMMIT=01ff3ec18a955f93880afe18167f17d0bc36cd55

resolve_json() {
	echo $CONFIG | jq -r ".[\"$1\"][\"$2\"]"
}

update_dockerfiles() {
	sed $1/$2/Dockerfile.tmpl \
		-e "s/@DEBIAN@/$(resolve_json "$1" debian)/" \
		-e "s/@VARNISH_VERSION@/$(resolve_json "$1" version)/" \
		-e "s/@DIST_SHA512@/$(resolve_json "$1" dist-sha512)/" \
		-e "s/@PKG_COMMIT@/$(resolve_json "$1" pkg-commit)/" \
		-e "s/@VARNISH_MODULES_VERSION@/$(resolve_json "$1" varnish-modules-version)/" \
		-e "s/@VARNISH_MODULES_SHA512SUM@/$(resolve_json "$1" varnish-modules-sha512sum)/" \
		-e "s/@VMOD_DYNAMIC_VERSION@/$(resolve_json "$1" vmod-dynamic-version)/" \
		-e "s/@VMOD_DYNAMIC_COMMIT@/$(resolve_json "$1" vmod-dynamic-commit)/" \
		-e "s/@VMOD_DYNAMIC_SHA512SUM@/$(resolve_json "$1" vmod-dynamic-sha512sum)/" \
		-e "s/@TOOLBOX_COMMIT@/$TOOLBOX_COMMIT/" \
		> $1/$2/Dockerfile
}

populate_dockerfiles() {
	for i in `echo $CONFIG | jq -r 'keys | .[]'`; do
		update_dockerfiles $i debian
		if [ "$i" != "stable" ]; then
			update_dockerfiles $i alpine
		fi
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
		Maintainers: Guillaume Quintard <guillaume.quintard@gmail.com> (@gquintard)
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
