#!/usr/bin/env bash

set -e
declare -A IMAGES

CONFIG='
{
	"stable": {
		"debian": "bullseye",
		"version": "6.0.11",
		"tags": "6.0",
		"pkg-commit": "10da6a585eb7d8defe9d273a51df5b133500eb6b",
		"dist-sha512": "02f56f360c6bbed663e712edef961384e6003cfe73307c7ea50f805ac4b4df0d26958179170401a2254a69ab623acc172da42926d82189bfa724a4e8a78597ea"
	},
	"old": {
		"debian": "bullseye",
		"version": "7.1.2",
		"tags": "7.1",
		"pkg-commit": "3ba24a8eee8cc5c082714034145b907402bbdb83",
		"dist-sha512": "e16a4b75ede25f3812dfc4e95545e39a80022835b9155a4e42118f911e41b691cbedd296db48d307ba4a4d0d01df1149306d752de07cabe459ccbf5bcdd49238",
		"varnish-modules-version": "0.20.0",
		"varnish-modules-sha512sum": "e63d6da8f63a5ce56bc7a5a1dd1a908e4ab0f6a36b5bdc5709dca2aa9c0b474bd8a06491ed3dee23636d335241ced4c7ef017b57413b05792ad382f6306a0b36",
		"vmod-dynamic-version": "2.6.0",
		"vmod-dynamic-commit": "025e9918f6cba33135e16e0fb0d86b4c34b6dd5a",
		"vmod-dynamic-sha512sum": "89b7251529c4c63c408b83c59e32b54b94b0f31f83614a34b3ffc4fb96ebdac5b6f8b5fe5b95056d5952a3c0a0217c935c5073c38415f7680af748e58c041816"
	},
	"fresh": {
		"debian": "bullseye",
		"version": "7.2.1",
		"tags": "7.2 latest",
		"pkg-commit": "ffc59a345217b599fd49f7f0442b5f653fbe6fc2",
		"dist-sha512": "7b9b837a8bafdf5798e81bc38163457b3bca16d933a9492800cdd2cde35c9b524a10b7e5ec931217e11d72f32feb05157a7eecfd9cf2c5856e717b634e51d089",
		"varnish-modules-version": "0.21.0",
		"varnish-modules-sha512sum": "a442f58968b471d713c99a94e5b80302c07ea163d3d5022d768eb0b39ab081f18744fd529b04283b0c6ec942f362197935d8ef1aa04f26eff10a81425a63bd35",
		"vmod-dynamic-version": "2.6.0",
		"vmod-dynamic-commit": "9666973952f62110c872d720af3dae0b85b4b597",
		"vmod-dynamic-sha512sum": "e62f1ee801ab2c9e22f5554bbe40c239257e2c46ea3d2ae19b465b1c82edad6f675417be8f7351d4f9eddafc9ad6c0149f88edc44dd0b922ad82e5d75b6b15a5"
	},
	"next": {
		"debian": "bullseye",
		"version": "7.2.1",
		"tags": "7.2 latest",
		"pkg-commit": "ffc59a345217b599fd49f7f0442b5f653fbe6fc2",
		"dist-sha512": "7b9b837a8bafdf5798e81bc38163457b3bca16d933a9492800cdd2cde35c9b524a10b7e5ec931217e11d72f32feb05157a7eecfd9cf2c5856e717b634e51d089",
		"varnish-modules-version": "0.21.0",
		"varnish-modules-sha512sum": "a442f58968b471d713c99a94e5b80302c07ea163d3d5022d768eb0b39ab081f18744fd529b04283b0c6ec942f362197935d8ef1aa04f26eff10a81425a63bd35",
		"vmod-dynamic-version": "2.6.0",
		"vmod-dynamic-commit": "9666973952f62110c872d720af3dae0b85b4b597",
		"vmod-dynamic-sha512sum": "e62f1ee801ab2c9e22f5554bbe40c239257e2c46ea3d2ae19b465b1c82edad6f675417be8f7351d4f9eddafc9ad6c0149f88edc44dd0b922ad82e5d75b6b15a5"

	}

}'

TOOLBOX_COMMIT=96bab07cf58b6e04824ffec608199f1780ff0d04

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
