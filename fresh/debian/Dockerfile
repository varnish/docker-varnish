FROM debian:trixie-slim

ARG  REPO_FINGERPRINT=694566269779DFAC975ED9BDD0525EAE838B3344
ARG  PKG_COMMIT=eb692742c1a107cf3f896985271b35b125873bd7
ARG  VARNISH_VERSION=8.0.0-3~trixie
ARG  DIST_SHA512=c381928e23deaacb863dcf389a494f30a56d22a4e88fe0c5dc7d4a93828f3dc0595c7ae41837f3549795828aca1a30e08f4456d4a752a6d12c19b61943dd99e9
ARG  VARNISH_MODULES_VERSION=0.27.0
ARG  VARNISH_MODULES_SHA512SUM=bb8a55b3d665fe6de918f784a6f4276b2053f5b1cd0628d6b6c6c78c0042fd678736a2f48375cf356daa47a987175f52569c0b468ccd2b37ab55a32c25255264
ARG  VMOD_DYNAMIC_COMMIT=99f72bc4958dca3555dbfeeb43512f243b004a72
ARG  VMOD_DYNAMIC_SHA512SUM=6f7b635c3fd9b8acfff6130e4bbe88d0bb97dc0ac178918c2288670951dace70742d9c8d7d798fe885ef908707a21ba2e6ca15c1524d531a59c80d4fdc9c5881
ARG  TOOLBOX_COMMIT=da1c5ce23d2ad81032bb45627d10a8dcb2c6f1d9
ENV  VMOD_DEPS="autoconf-archive automake curl libtool make pkg-config python3-sphinx varnish-dev"

ENV VARNISH_SIZE=100M
ENV VSM_NOPID=1

RUN set -ex; \
    BASE_PKGS="apt-utils automake git gpg libgetdns-dev libtool make pkg-config python3-docutils"; \
    export DEBIAN_FRONTEND=noninteractive; \
    export DEBCONF_NONINTERACTIVE_SEEN=true; \
    \
    . /etc/os-release; \
    apt-get update; \
    apt-get install -y apt-transport-https curl $BASE_PKGS; \
    mkdir -p /etc/apt/keyrings; \
    gpg --batch --keyserver hkps://keyserver.ubuntu.com --recv-keys $REPO_FINGERPRINT; \
    gpg --batch --armor --export "$REPO_FINGERPRINT" > /etc/apt/keyrings/varnish.gpg; \
    echo "deb [signed-by=/etc/apt/keyrings/varnish.gpg] https://packages.varnish-software.com/varnish/$ID $VERSION_CODENAME main" | tee -a /etc/apt/sources.list.d/varnish.list; \
    apt-get update; \
    # create users and groups with fixed IDs
    adduser --uid 1000 --quiet --system --no-create-home --home /nonexistent --group varnish; \
    adduser --uid 1001 --quiet --system --no-create-home --home /nonexistent --ingroup varnish vcache; \
    adduser --uid 1002 --quiet --system --no-create-home --home /nonexistent --ingroup varnish varnishlog; \
    \
    apt-get update; \
    apt-get install -y --no-install-recommends \
				varnish=${VARNISH_VERSION} \
				varnish-dev=${VARNISH_VERSION} \
				varnish-modules=${VARNISH_VERSION} \
				vmod-fileserver=${VARNISH_VERSION} \
				vmod-reqwest=${VARNISH_VERSION} \
				vmod-rers=${VARNISH_VERSION} \
				libgetdns10t64 \
				netbase; \
    \
    git clone https://github.com/varnish/toolbox.git; \
    cd toolbox; \
    git checkout $TOOLBOX_COMMIT; \
    cp install-vmod/install-vmod /usr/local/bin/; \
    cp vcls/verbose_builtin/verbose_builtin.vcl vcls/hit-miss/hit-miss.vcl /etc/varnish/; \
    \
    # vmod-dynamic
    SKIP_CHECK=1 install-vmod https://github.com/gquintard/libvmod-dynamic/archive/$VMOD_DYNAMIC_COMMIT.tar.gz $VMOD_DYNAMIC_SHA512SUM; \
    \
    # clean up and ensure varnish package is not removed.
    apt-mark hold varnish; \
    apt-get -y purge --auto-remove $BASE_PKGS varnish-dev; \
    rm -rf /var/lib/apt/lists/* /usr/lib/varnish/vmods/libvmod_*.la; \
    chown varnish /var/lib/varnish; \
    mkdir -p -m 1777 /var/lib/varnish/varnishd

WORKDIR /etc/varnish

COPY scripts/ /usr/local/bin/
COPY default.vcl /etc/varnish/
COPY index.html /etc/varnish/

ENTRYPOINT ["/usr/local/bin/docker-varnish-entrypoint"]

USER varnish
EXPOSE 80 8443
CMD []
