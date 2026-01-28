FROM debian:trixie-slim

ARG  REPO_FINGERPRINT=694566269779DFAC975ED9BDD0525EAE838B3344
ARG  PKG_COMMIT=eb692742c1a107cf3f896985271b35b125873bd7
ARG  VARNISH_VERSION_NUMBER=8.0.0-4
ARG  VMOD_DYNAMIC_COMMIT=99f72bc4958dca3555dbfeeb43512f243b004a72
ARG  VMOD_DYNAMIC_SHA512SUM=6f7b635c3fd9b8acfff6130e4bbe88d0bb97dc0ac178918c2288670951dace70742d9c8d7d798fe885ef908707a21ba2e6ca15c1524d531a59c80d4fdc9c5881
ARG  TOOLBOX_COMMIT=da1c5ce23d2ad81032bb45627d10a8dcb2c6f1d9
ENV  VMOD_DEPS="autoconf-archive automake curl libtool make pkg-config python3-sphinx varnish-dev"

ENV VARNISH_SIZE=100M
ENV VSM_NOPID=1

RUN set -ex; \
    . /etc/os-release; \
    VARNISH_VERSION=$VARNISH_VERSION_NUMBER~$VERSION_CODENAME; \
    BASE_PKGS="apt-utils automake git gpg libgetdns-dev libtool make pkg-config python3-docutils"; \
    export DEBIAN_FRONTEND=noninteractive; \
    export DEBCONF_NONINTERACTIVE_SEEN=true; \
    \
    apt-get update; \
    apt-get install -y curl $BASE_PKGS; \
    mkdir -p /etc/apt/keyrings; \
    gpg --batch --keyserver hkps://keys.openpgp.org --recv-keys $REPO_FINGERPRINT; \
    gpg --batch --armor --export "$REPO_FINGERPRINT" > /etc/apt/keyrings/varnish.gpg; \
    echo "deb [signed-by=/etc/apt/keyrings/varnish.gpg] https://packages.varnish-software.com/varnish/$ID $VERSION_CODENAME main" | tee -a /etc/apt/sources.list.d/varnish.list; \
    apt-get update; \
    # create users and groups with fixed IDs
    adduser --uid 1000 --quiet --system --no-create-home --home /nonexistent --group varnish; \
    adduser --uid 1001 --quiet --system --no-create-home --home /nonexistent --ingroup varnish vcache; \
    adduser --uid 1002 --quiet --system --no-create-home --home /nonexistent --ingroup varnish varnishlog; \
    \
    if [ "$(uname -m)" = "x86_64" ]; then \
        EXTRA_VMODS="vmod-cfg=${VARNISH_VERSION}"; \
    else \
        EXTRA_VMODS= ; \
    fi; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
				varnish=${VARNISH_VERSION} \
				varnish-dev=${VARNISH_VERSION} \
				varnish-modules=${VARNISH_VERSION} \
				vmod-cfg=${VARNISH_VERSION} \
				vmod-digest=${VARNISH_VERSION} \
				vmod-fileserver=${VARNISH_VERSION} \
				vmod-geoip2=${VARNISH_VERSION} \
				vmod-jq=${VARNISH_VERSION} \
				vmod-querystring=${VARNISH_VERSION} \
				vmod-redis=${VARNISH_VERSION} \
				vmod-reqwest=${VARNISH_VERSION} \
				vmod-rers=${VARNISH_VERSION} \
				vmod-uuid=${VARNISH_VERSION} \
				${EXTRA_VMODS} \
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
    # clean up the temporary GPG home directory
    rm -rf "$GNUPGHOME"; \
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
