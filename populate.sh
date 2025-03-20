#!/usr/bin/env bash

set -e

CONFIG='
{
	"stable": {
		"version": "6.0.13",
		"tags": "6.0"
	},
	"old": {
		"version": "7.6.1",
		"tags": "7.6"
	},
	"fresh": {
		"version": "7.7.0",
		"tags": "7 7.7 latest"
	}
}'

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
	library)
		populate_library
		;;
	check)
		echo 'checking fresh/*/Dockerfile'
		diff <(grep '^ARG' fresh/alpine/Dockerfile) <(grep '^ARG' fresh/debian/Dockerfile)
		echo 'checking old/*/Dockerfile'
		diff <(grep '^ARG' old/alpine/Dockerfile) <(grep '^ARG' old/debian/Dockerfile)
		echo OK
		;;
	*)
		echo invalid choice
		exit 1
		;;
esac
