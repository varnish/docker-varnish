#!/usr/bin/env bash

set -e

update_library(){
	tags="$1"
	varnish_version=$(sed -n 's/ARG *VARNISH_VERSION_NUMBER=//p' "$1/$2/Dockerfile")
	while [ -n "$varnish_version" ]; do
		tags+=" $varnish_version"

		varnish_version=$(echo $varnish_version | sed -E 's/.?[^-.]*$//')
	done

	echo $tags
	if [ "$2" != "debian" ]; then
		tags=`echo "$tags" | sed -e "s/\( \|$\)/-$2\1/g"`
	fi

	cat >> library.varnish <<- EOF

		Tags: `echo $tags | sed 's/ \+/, /g'`
		Architectures: amd64, arm64v8
		Directory: $1/$2
		GitCommit: `git log -n1 --pretty=oneline $1/$2 | cut -f1 -d" "`
		GitFetch: refs/heads/main
	EOF
}

populate_library() {
	cat > library.varnish <<- EOF
		# this file was generated using https://github.com/varnish/docker-varnish/blob/`git rev-parse HEAD`/populate.sh
		Maintainers: Guillaume Quintard <guillaume.quintard@gmail.com> (@gquintard)
		GitRepo: https://github.com/varnish/docker-varnish.git
	EOF

	update_library fresh debian
	update_library old debian
	update_library old alpine
	update_library stable debian
}

case "$1" in
	library)
		populate_library
		;;
	*)
		echo invalid choice
		exit 1
		;;
esac
