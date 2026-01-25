#!/bin/bash

set -ex
cd $(dirname "$0")

build() {
	# usage:
	#   build TYPE NAME URL ["BUILD_DEPS" ["RUN_DEPS" [SKIP_CHECK]]]
	#
	# arguments:
	#   TYPE: "regular", "with-varnish-src" or "rust", correspond to the Dockerfile extension to use
	#   NAME: vmod name, will be used to tag the docker image "varnish:NAME"
	#   URL: a http(s) link to a .tar.gz archive containing the vmod source
	#   BUILD_DEPS (optional): whitespace-separated list of apt packages to install to build the vmod
	#                          the usual building tools (make, gcc, autotools, etc.) are handled automatically
	#                          those packages are purged once installation is done
	#   RUN_DEPS (optional): whitespace-separated list of apt packages to install to use the vmod
	#   SKIP_CHECK (optional): if present and not empty, skip the tests when compiling the vmod
	docker build \
		-f Dockerfile.$1 \
		-t varnish:$2 \
		--build-arg VMOD_URL=$3 \
		--build-arg VMOD_BUILD_DEPS="$4" \
		--build-arg VMOD_RUN_DEPS="$5" \
		--build-arg SKIP_CHECK=$6 \
		.
	# build a dummy vtc to make sure the vmod loads, i.e. it's installed
	# correctly and that the runtime dependencies are right
	echo "vcl 4.1; import $2; backend default none;" > $2.vcl
	# compile once silently, rerun loudly if there's a failure
	cmd="docker run --rm -v `pwd`/$2.vcl:/etc/varnish/default.vcl varnish:$2 varnishd -C -f /etc/varnish/default.vcl"
	$cmd &> /dev/null || $cmd
	rm $2.vcl
}

# C vmods that don't require the Varnish source:
# - all_healthy: https://code.uplex.de/uplex-varnish/libvmod-all_healthy
# - awrest: https://github.com/xcir/libvmod-awsrest
# - cfg: https://github.com/carlosabalde/libvmod-cfg
# - crypto: https://code.uplex.de/uplex-varnish/libvmod-crypto/
# - blobdigest: https://gitlab.com/uplex/varnish/libvmod-blobdigest
# - brotli: https://gitlab.com/uplex/varnish/libvfp-brotli
# - geoip2: https://github.com/varnishcache-friends/libvmod-geoip2
# - jq: https://github.com/varnishcache-friends/libvmod-jq
# - querystring: https://github.com/Dridi/libvmod-querystring
# - uuid: https://github.com/otto-de/libvmod-uuid
# - xcounter: https://github.com/xcir/libvmod-xcounter
build \
	regular \
	all_healthy \
	https://code.uplex.de/uplex-varnish/libvmod-all_healthy/archive/e77f9df24f89ace9996703b2a4ac6b72cf0365db.tar.gz

build \
	regular \
	awsrest \
	https://github.com/xcir/libvmod-awsrest/archive/13fc85c3429dca71d878685a3a8f740de38ba451.tar.gz \
	"libmhash-dev" \
	"libmhash2"

build \
	regular \
	blobdigest \
	https://code.uplex.de/uplex-varnish/libvmod-blobdigest/archive/e3e6c23b46e6cda20ad75c406d847b074ab785ab.tar.gz \
	"" \
	"" \
	true

build \
	regular \
	brotli \
	https://code.uplex.de/uplex-varnish/libvfp-brotli/archive/d5b6ad352ce546a51495d92c64f80f12d672373c.tar.gz \
	"libbrotli-dev" \
	"libbrotli1"

build \
	regular \
	cfg \
	https://github.com/carlosabalde/libvmod-cfg/archive/732bee63b507bbf1112b15eaf67ed2da5bfc19fb.tar.gz \
	"libcurl4-openssl-dev libjemalloc-dev libluajit-5.1-dev vim-common" \
	"libjemalloc2"

build \
	regular \
	crypto \
	https://code.uplex.de/uplex-varnish/libvmod-crypto/archive/d815920b1060ac91bbf6701deca2a3a87f97b898.tar.gz \
	"libssl-dev"

build \
	regular \
	geoip2 \
	https://github.com/varnishcache-friends/libvmod-geoip2/archive/refs/heads/devel.tar.gz \
	"libmaxminddb-dev" \
	"libmaxminddb0" \
	true # the tarball doesn't include the maxmind database used by the tests, so skip them

build \
	regular \
	jq \
	https://github.com/varnishcache-friends/libvmod-jq/archive/refs/heads/devel.tar.gz \
	"libjq-dev" \
	"libjq1"

build \
	regular \
	querystring \
	https://git.sr.ht/~dridi/vmod-querystring/refs/download/vmod-querystring-2.0.4/vmod-querystring-2.0.4.tar.gz

build \
	regular \
	uuid \
	https://github.com/otto-de/libvmod-uuid/archive/ae0ca345b9974092bf139409d2852fc46886c250.tar.gz \
	"libossp-uuid-dev" \
	"libossp-uuid16"

build \
	regular \
	xcounter \
	https://github.com/xcir/libvmod-xcounter/archive/refs/heads/master.tar.gz

# C vmods that needs the compiled varnish source to build
# - pesi: https://code.uplex.de/uplex-varnish/libvdp-pesi
# - slash: https://gitlab.com/uplex/varnish/slash
#build \
#	with-varnish-src \
#	pesi \
#	https://code.uplex.de/uplex-varnish/libvdp-pesi/-/archive/master/libvdp-pesi-master.tar.gz \
#	"zlib1g-dev" \
#	"" \
#	true
#
#build \
#	with-varnish-src \
#	slash \
#	https://gitlab.com/uplex/varnish/slash/-/archive/slash-1.0.0-rc3/slash-slash-1.0.0-rc3.tar.gz \
#	"" \
#	"" \
#	true
#
# C vmod, but we need to build some dependencies from sources, so we use
# a custom Dockerfile
# - redis: https://github.com/carlosabalde/libvmod-redis
build \
	custom.redis \
	redis \
	https://github.com/carlosabalde/libvmod-redis/archive/refs/tags/8.0-22.0.tar.gz \
	"libev-dev libssl-dev unzip"

# rust vmods:
# - fileserver: https://github.com/gquintard/vmod_fileserver
# - reqwest: https://github.com/gquintard/vmod_reqwest
# - rers: https://github.com/gquintard/vmod_rers
build \
	rust \
	fileserver \
	https://github.com/varnish-rs/vmod-fileserver/archive/refs/tags/v0.0.10.tar.gz \
	"" \
	"" \
	true

build \
	rust \
	reqwest \
	https://github.com/varnish-rs/vmod-reqwest/archive/refs/tags/v0.0.16.tar.gz \
	"libssl-dev" \
	"" \
	true

build \
	rust \
	rers \
	https://github.com/varnish-rs/vmod-rers/archive/refs/tags/v0.0.13.tar.gz
