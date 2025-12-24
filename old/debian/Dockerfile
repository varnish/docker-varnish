FROM debian:trixie-slim

ARG  PKG_COMMIT=1f0d212dc45065f38bd80ac57fe22773a20a0595
ARG  VARNISH_VERSION=7.7.3
ARG  DIST_SHA512=2de3f19d24e42ec092076226b629dc36d4d3c9961454502e7f9a8ff1d440cf54104198e2b5302361f093fa221f04f836bb8dda441921d1721b1d05c90c0f1661
ARG  VARNISH_MODULES_VERSION=0.26.0
ARG  VARNISH_MODULES_SHA512SUM=2050ec65ae731bddc74743c9aa6246e41ffba8017c404c32e50d45f72f5a02dd3eb2290f8b8e43e25a385a06819836fb19f8540f1cdae394083729ff6b6aed35
ARG  VMOD_DYNAMIC_VERSION=7.7
ARG  VMOD_DYNAMIC_COMMIT=490068ba146c48fd7201c8d19cdb37f6d7d932c7
ARG  VMOD_DYNAMIC_SHA512SUM=3ff84710d4d9c4fd956cc27c41ae8b3d0bed4db7a2ca70d61e3900cd1f77ff293e2be3551d044a644ec76c6678517d788511e61c803dda2fe75bd5c286d5901b
ARG  TOOLBOX_COMMIT=cfa9ec43a47429ef94f7e04e4abc58c67ad50add
ENV  VMOD_DEPS="autoconf-archive automake curl libtool make pkg-config python3-sphinx"

ENV VARNISH_SIZE=100M
ENV VSM_NOPID=1

SHELL ["/bin/bash", "-ec"]
RUN set -ex; \
    BASE_PKGS="curl dpkg-dev debhelper devscripts equivs git pkg-config apt-utils fakeroot libgetdns-dev"; \
    export DEBIAN_FRONTEND=noninteractive; \
    export DEBCONF_NONINTERACTIVE_SEEN=true; \
    mkdir -p /work/varnish /pkgs; \
    apt-get update; \
    apt-get install -y --no-install-recommends $BASE_PKGS adduser libgetdns10t64 netbase; \
    \
    # create users and groups with fixed IDs
    adduser --uid 1000 --quiet --system --no-create-home --home /nonexistent --group varnish; \
    adduser --uid 1001 --quiet --system --no-create-home --home /nonexistent --ingroup varnish vcache; \
    adduser --uid 1002 --quiet --system --no-create-home --home /nonexistent --ingroup varnish varnishlog; \
    \
    # varnish
    cd /work/varnish; \
    git clone https://github.com/varnish/all-packager.git; \
    cd all-packager/varnish-cache; \
    source ../pkg.env ; \
    git checkout $PKG_COMMIT; \
    rm -rf ../.git; \
    curl -L -f https://varnish-cache.org/downloads/varnish-$VARNISH_VERSION.tgz -o $tmpdir/orig.tgz; \
    echo "$DIST_SHA512  $tmpdir/orig.tgz" | sha512sum -c -; \
    tar xavf $tmpdir/orig.tgz --strip 1; \
    source /etc/os-release; \
    sed -i -e "s|@VERSION@|$VARNISH_VERSION-$package_release~$VERSION_CODENAME|"  "debian/changelog"; \
    mk-build-deps --install --tool="apt-get -o Debug::pkgProblemResolver=yes --yes" debian/control; \
    sed -i '' debian/varnish*; \
    dpkg-buildpackage -us -uc -j"$(nproc)"; \
    apt-get -y --no-install-recommends install ../*.deb; \
    mv ../*dev*.deb /pkgs; \
    \
    git clone https://github.com/varnish/toolbox.git; \
    cd toolbox; \
    git checkout $TOOLBOX_COMMIT; \
    cp install-vmod/install-vmod /usr/local/bin/; \
    cp vcls/verbose_builtin/verbose_builtin.vcl vcls/hit-miss/hit-miss.vcl /etc/varnish/; \
    \
    # varnish-modules
    install-vmod https://github.com/varnish/varnish-modules/releases/download/$VARNISH_MODULES_VERSION/varnish-modules-$VARNISH_MODULES_VERSION.tar.gz $VARNISH_MODULES_SHA512SUM; \
    \
    # vmod-dynamic
    SKIP_CHECK=1 install-vmod https://github.com/nigoroll/libvmod-dynamic/archive/$VMOD_DYNAMIC_COMMIT.tar.gz $VMOD_DYNAMIC_SHA512SUM; \
    \
    # clean up and ensure varnish package is not removed.
    apt-mark hold varnish; \
    apt-get -y purge --auto-remove varnish-build-deps $BASE_PKGS varnish-dev; \
    rm -rf /var/lib/apt/lists/* /work/ /usr/lib/varnish/vmods/libvmod_*.la; \
    chown varnish /var/lib/varnish; \
    mkdir -p -m 1777 /var/lib/varnish/varnishd

WORKDIR /etc/varnish

COPY scripts/ /usr/local/bin/
COPY default.vcl /etc/varnish/

ENTRYPOINT ["/usr/local/bin/docker-varnish-entrypoint"]

USER varnish
EXPOSE 80 8443
CMD []
