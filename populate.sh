#!/bin/sh

set -e
declare -A IMAGES
declare -A KEYS

IMAGES[6.2]="fresh/debian	62	6.2.0-1~stretch	6.2.0-1 6.2.0 6 latest fresh"
IMAGES[6.0]="stable/debian	60lts	6.0.3-1~stretch	6.0.3-1 6.0.3 stable"

KEYS[6.2]=0D42823DD1135F8E
KEYS[6.0]=3AEAFFBB82FBBA5F

update_dockerfiles() {
	key=$1
	workdir=$2
	repo=$3
	package=$4

	mkdir -p $workdir

	cp docker-varnish-entrypoint $workdir

	curl -fL https://packagecloud.io/varnishcache/varnish$repo/gpgkey -o $workdir/gpgkey

	cat > $workdir/Dockerfile << EOF
FROM debian:stretch-slim

ENV VARNISH_VERSION $package

RUN set -ex; \\
	fetchDeps=" \\
		apt-transport-https \\
		ca-certificates \\
		dirmngr \\
		gnupg \\
	"; \\
	apt-get update; \\
	apt-get install -y --no-install-recommends \$fetchDeps; \\
	key=$key; \\
	export GNUPGHOME="\$(mktemp -d)"; \\
	gpg --batch --recv-keys \$key; \\
	gpg --batch --export export \$key > /etc/apt/trusted.gpg.d/varnish.gpg; \\
	gpgconf --kill all; \\
	echo deb https://packagecloud.io/varnishcache/varnish$repo/debian/ stretch main > /etc/apt/sources.list.d/varnish.list; \\
	apt-get update; \\
	apt-get install -y --no-install-recommends varnish=\$VARNISH_VERSION; \\
	apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false \$fetchDeps; \\
	rm -rf /var/lib/apt/lists/*

WORKDIR /etc/varnish

COPY docker-varnish-entrypoint /usr/local/bin/
ENTRYPOINT ["docker-varnish-entrypoint"]

EXPOSE 80
CMD ["varnishd", "-F", "-f", "/etc/varnish/default.vcl"]
EOF
}

populate_dockerfiles() {
	for i in ${!IMAGES[@]}; do
		update_dockerfiles ${KEYS[$i]} ${IMAGES[$i]}
	done
}

update_library(){
	name=$1
	workdir=$2
	shift 4
	tags="$@"

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

	for i in ${!IMAGES[@]}; do
		update_library $i ${IMAGES[$i]}
	done
}

update_travis() {
	echo "  - NAME=$1 WORKDIR=$2" >> .travis.yml
}

populate_travis(){
	cat > .travis.yml << EOF
language: bash
services: docker

env:
EOF

	for i in ${!IMAGES[@]}; do
		update_travis $i ${IMAGES[$i]}
	done

	cat >> .travis.yml << EOF
install:
  - git clone https://github.com/docker-library/official-images.git ~/official-images

before_script:
  - env | sort
  - cd "\${WORKDIR}"
  - image="varnish:\${NAME}"

script:
  - travis_retry docker build -t "\$image" .
  - ~/official-images/test/run.sh "\$image"

after_script:
  - docker images
EOF
}

case "$1" in
	dockerfiles)
		populate_dockerfiles
		populate_travis
		;;
	library)
		populate_library
		;;
	*)
		echo invalid choice
		exit 1
		;;
esac
