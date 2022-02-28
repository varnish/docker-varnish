FROM debian:bullseye-slim

ARG  PKG_COMMIT=d3e6a3fad7d4c2ac781ada92dcc246e7eef9d129
ARG  VARNISH_VERSION=7.0.2
ARG  DIST_SHA512=5eb08345c95152639266b7ad241185188477f8fd04e88e4dfda1579719a1a413790a0616f25d70994f6d3b8f7640ea80926ece7c547555dad856fd9f6960c9a3
ARG  VARNISH_MODULES_VERSION=0.19.0
ARG  VARNISH_MODULES_SHA512SUM=fc6f4c1695f80fa3b267c13c772dca9cf577eed38c733207cf0f8e01b5d4ebabbe43e936974ba70338a663a45624254759cfd75f8fbae0202361238ee5f15cef
ARG  VMOD_DYNAMIC_VERSION=2.5.0
ARG  VMOD_DYNAMIC_COMMIT=4d0ca5230d563d9c0e03df0ec6e01f7c174fdfd5
ARG  VMOD_DYNAMIC_SHA512SUM=ea9dceb88fb472faaec5e7ff79f65afdcdbfde9661fb460c629bffdcea4a9f51e3499aab9e5c202d382d3460912f502145af21e54a5e4a8ae25b34051a484b35

ENV VARNISH_SIZE 100M

COPY debian.varnish-modules /work/varnish-modules/debian
COPY debian.vmod-dynamic /work/vmod-dynamic/debian

RUN set -e; \
    BASE_PKGS="curl dpkg-dev debhelper devscripts equivs git pkg-config apt-utils fakeroot sbuild libgetdns-dev"; \
    export DEBIAN_FRONTEND=noninteractive; \
    export DEBCONF_NONINTERACTIVE_SEEN=true; \
    mkdir -p /work/varnish /pkgs; \
    apt-get update; \
    apt-get install -y $BASE_PKGS; \
    # varnish
    cd /work/varnish; \
    git clone https://github.com/varnishcache/pkg-varnish-cache.git; \
    cd pkg-varnish-cache; \
    git checkout d3e6a3fad7d4c2ac781ada92dcc246e7eef9d129; \
    rm -rf .git; \
    curl -f https://varnish-cache.org/downloads/varnish-7.0.2.tgz -o $tmpdir/orig.tgz; \
    echo "5eb08345c95152639266b7ad241185188477f8fd04e88e4dfda1579719a1a413790a0616f25d70994f6d3b8f7640ea80926ece7c547555dad856fd9f6960c9a3  $tmpdir/orig.tgz" | sha512sum -c -; \
    tar xavf $tmpdir/orig.tgz --strip 1; \
    sed -i -e "s|@VERSION@|$VARNISH_VERSION|"  "debian/changelog"; \
    mk-build-deps --install --tool="apt-get -o Debug::pkgProblemResolver=yes --yes" debian/control; \
    sed -i '' debian/varnish*; \
    dpkg-buildpackage -us -uc -j"$(nproc)"; \
    apt-get -y install ../*.deb; \
    mv ../*dev*.deb /pkgs; \
    # varnish-modules
    cd /work/varnish-modules; \
    curl -fLo src.tar.gz https://github.com/varnish/varnish-modules/releases/download/$VARNISH_MODULES_VERSION/varnish-modules-$VARNISH_MODULES_VERSION.tar.gz; \
    echo "$VARNISH_MODULES_SHA512SUM  src.tar.gz" | sha512sum -c -; \
    tar xavf src.tar.gz --strip 1; \
    dch -u low --package "varnish-modules" --create -v "$VARNISH_MODULES_VERSION" -D stable "release"; \
    sed -i "s/DPGK_VERSION/7.0.2/g" debian/control; \
    dpkg-buildpackage -us -uc -j"$(nproc)"; \
    apt-get -y install ../*.deb; \
    # vmod-dynamic
    cd /work/vmod-dynamic; \
    curl -fLo src.tar.gz https://github.com/nigoroll/libvmod-dynamic/archive/$VMOD_DYNAMIC_COMMIT.tar.gz; \
    echo "$VMOD_DYNAMIC_SHA512SUM  src.tar.gz" | sha512sum -c -; \
    tar xavf src.tar.gz --strip 1; \
    dch -u low --package "libvmod-dynamic" --create -v "2.5.0" -D stable "release"; \
    sed -i "s/DPGK_VERSION/7.0.2/g" debian/control; \
    dpkg-buildpackage -us -uc -j"$(nproc)"; \
    apt-get -y install ../*.deb; \
    # clean up
    apt-get -y purge --auto-remove varnish-build-deps $BASE_PKGS; \
    rm -rf /var/lib/apt/lists/* /work/; \
    chown varnish /var/lib/varnish;

WORKDIR /etc/varnish

COPY scripts/ /usr/local/bin/
ENTRYPOINT ["/usr/local/bin/docker-varnish-entrypoint"]

USER varnish
EXPOSE 80 8443
CMD []
