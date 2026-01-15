ARG DEBIAN_VERSION=bookworm

FROM debian:$DEBIAN_VERSION-slim

ARG DEBIAN_VERSION=bookworm
ARG VARNISH_PLUS_VERSION=6.0.16r10-1
ARG VARNISH_OTEL_VERSION=2.1.0-1
ARG TOOLBOX_COMMIT=da1c5ce23d2ad81032bb45627d10a8dcb2c6f1d9

ENV VARNISH_SIZE=
ENV VSM_NOPID=1
ENV VMOD_DEPS="autoconf-archive automake curl libtool make pkg-config python3-sphinx"
ENV MSE4_CONFIG="/etc/varnish/mse4.conf"
ENV VARNISH_STORAGE_BACKEND="malloc"
ENV MSE4_CACHE_FORCE_PRESERVE="0"

COPY varnishplus_60-enterprise-archive-keyring.gpg /etc/apt/keyrings/varnishplus_60-enterprise-archive-keyring.gpg
COPY varnishplus_60-enterprise.list /etc/apt/sources.list.d/varnishplus_60-enterprise.list

RUN set -ex; \
    BASE_PKGS="curl dpkg-dev debhelper devscripts equivs git pkg-config apt-utils fakeroot libgetdns-dev"; \
    export DEBIAN_FRONTEND=noninteractive; \
    export DEBCONF_NONINTERACTIVE_SEEN=true; \
    apt-get update; \
    apt-get install -y ca-certificates git; \
    apt-get update; \
    apt-get install -y varnish-plus=$VARNISH_PLUS_VERSION~$DEBIAN_VERSION varnish-otel=$VARNISH_OTEL_VERSION~$DEBIAN_VERSION; \
    chown varnish /var/lib/varnish; \
    \
    git clone https://github.com/varnish/toolbox.git /tmp/toolbox; \
    cd /tmp/toolbox; \
    git checkout $TOOLBOX_COMMIT; \
    cp install-vmod/install-vmod /usr/local/bin/; \
    cp vcls/verbose_builtin/verbose_builtin.vcl vcls/hit-miss/hit-miss.vcl /etc/varnish/; \
    \
    # clean up and ensure varnish package is not removed.
    apt-mark hold varnish; \
    apt-get purge -y git; \
    rm -rf /var/lib/apt/lists/* /tmp/toolbox

WORKDIR /etc/varnish

COPY scripts/ /usr/local/bin/

ENTRYPOINT ["/usr/local/bin/docker-varnish-entrypoint"]

USER varnish
EXPOSE 80 8443
CMD []
