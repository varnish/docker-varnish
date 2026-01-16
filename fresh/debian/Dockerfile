FROM debian:trixie-slim

ARG  PKG_COMMIT=eb692742c1a107cf3f896985271b35b125873bd7
ARG  VARNISH_VERSION=8.0.0
ARG  DIST_SHA512=c381928e23deaacb863dcf389a494f30a56d22a4e88fe0c5dc7d4a93828f3dc0595c7ae41837f3549795828aca1a30e08f4456d4a752a6d12c19b61943dd99e9
ARG  VARNISH_MODULES_VERSION=0.27.0
ARG  VARNISH_MODULES_SHA512SUM=bb8a55b3d665fe6de918f784a6f4276b2053f5b1cd0628d6b6c6c78c0042fd678736a2f48375cf356daa47a987175f52569c0b468ccd2b37ab55a32c25255264
ARG  VMOD_DYNAMIC_COMMIT=99f72bc4958dca3555dbfeeb43512f243b004a72
ARG  VMOD_DYNAMIC_SHA512SUM=6f7b635c3fd9b8acfff6130e4bbe88d0bb97dc0ac178918c2288670951dace70742d9c8d7d798fe885ef908707a21ba2e6ca15c1524d531a59c80d4fdc9c5881
ARG  TOOLBOX_COMMIT=da1c5ce23d2ad81032bb45627d10a8dcb2c6f1d9
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
    # sanity check
    source ../pkg.env ; \
    test "$VARNISH_VERSION" = "$varnish_version"; \
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
    SKIP_CHECK=1 install-vmod https://github.com/gquintard/libvmod-dynamic/archive/$VMOD_DYNAMIC_COMMIT.tar.gz $VMOD_DYNAMIC_SHA512SUM; \
    \
    # set IPC_LOCK capability on varnishd to allow mlock() of VSL
    apt-get install -y --no-install-recommends libcap2-bin; \
    setcap cap_ipc_lock+ep /usr/sbin/varnishd; \
    \
    # clean up and ensure varnish package is not removed.
    apt-mark hold varnish; \
    apt-get -y purge --auto-remove varnish-build-deps $BASE_PKGS varnish-dev libcap2-bin; \
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
