#! /bin/sh

set -e
declare -A IMAGES

IMAGES[6.2]="fresh/debian	62	6.2.0-1~stretch	6.2.0-1 6.2.0 6.2 6 latest fresh"
IMAGES[6.0]="stable/debian	60lts	6.0.3-1~stretch	6.0.3-1 6.0.3 6.0 stable"

update_dockerfiles() {
	workdir=$1
	repo=$2
	package=$3

	mkdir -p $workdir

	cp docker-varnish-entrypoint $workdir

	curl -L https://packagecloud.io/varnishcache/varnish$repo/gpgkey -o $workdir/gpgkey

	cat > $workdir/Dockerfile << EOF
FROM debian:stretch-slim

COPY gpgkey /tmp

RUN apt-get update && \\
    apt-get install -y \\
	curl \\
	gnupg \\
	apt-transport-https && \\
    apt-key add /tmp/gpgkey && \\
    echo deb https://packagecloud.io/varnishcache/varnish$repo/debian/ stretch main > /etc/apt/sources.list.d/varnish.list && \\
    apt-get update && \\
    apt-get install -y varnish=$package && \\
    apt-get remove -y \\
	curl \\
	gnupg \\
	apt-transport-https && \\
    apt-get clean -y && \\
    apt-get autoremove -y && \\
    rm -rf /var/lib/apt/lists/* /tmp/gpgkey

WORKDIR /etc/varnish

COPY docker-varnish-entrypoint /usr/local/bin/
ENTRYPOINT ["docker-varnish-entrypoint"]

EXPOSE 80
CMD ["varnishd", "-F", "-f", "/etc/varnish/default.vcl"]
EOF
}

populate_dockerfiles() {
	for i in ${!IMAGES[@]}; do
		update_dockerfiles ${IMAGES[$i]}
	done
}

update_library(){
	workdir=$1
	shift 3
	tags="$@"

	cat >> library.varnish <<- EOF

		Tags: `echo $tags | sed 's/ +/, /g'`
		Architectures: amd64
		Directory: $workdir
		GitCommit: `git log -n1 --pretty=oneline $workdir | cut -f1 -d" "`
	EOF
}

populate_library() {
	cat > library.varnish <<- EOF
		Maintainers: Guillaume Quintard <guillaume@varni.sh> (@gquintard)
		GitRepo: https://github.com/varnish/docker-varnish.git
	EOF

	for i in ${!IMAGES[@]}; do
		update_library ${IMAGES[$i]}
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
