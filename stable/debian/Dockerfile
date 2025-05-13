FROM debian:bookworm-slim

ARG PKG_COMMIT=10da6a585eb7d8defe9d273a51df5b133500eb6b
ARG VARNISH_VERSION=6.0.14
ARG DIST_SHA512=60c51ef71f8da11cdc862c257b6ce3970501af3ffc20199a6230f93f092657e2a5ddc37994acc25acc4ce2e50e1f4c69606aa0c92cb5d546e4f4244cfc473e91

ENV VARNISH_SIZE 100M

RUN set -e; \
    BASE_PKGS="curl dpkg-dev debhelper devscripts equivs git pkg-config apt-utils fakeroot"; \
    export DEBIAN_FRONTEND=noninteractive; \
    export DEBCONF_NONINTERACTIVE_SEEN=true; \
    tmpdir="$(mktemp -d)"; \
    cd "$tmpdir"; \
    apt-get update; \
    apt-get install -y --no-install-recommends $BASE_PKGS; \
    git clone https://github.com/varnishcache/pkg-varnish-cache.git; \
    cd pkg-varnish-cache; \
    git checkout "$PKG_COMMIT"; \
    rm -rf .git; \
    curl -f "https://varnish-cache.org/downloads/varnish-$VARNISH_VERSION.tgz" -o $tmpdir/orig.tgz; \
    echo "$DIST_SHA512  $tmpdir/orig.tgz" | sha512sum -c -; \
    tar xavf $tmpdir/orig.tgz --strip 1; \
    sed -i -e "s|@VERSION@|$VARNISH_VERSION|"  "debian/changelog"; \
    mk-build-deps --install --tool="apt-get -o Debug::pkgProblemResolver=yes --yes" debian/control; \
    sed -i '' debian/varnish*; \
    dpkg-buildpackage -us -uc -j"$(nproc)"; \
    apt-get -y --no-install-recommends install ../*.deb; \
    apt-get -y purge --auto-remove varnish-build-deps $BASE_PKGS; \
    mkdir /pkgs; \
    mv ../*dev*.deb /pkgs; \
    rm -rf /var/lib/apt/lists/* "$tmpdir";

WORKDIR /etc/varnish

COPY scripts/ /usr/local/bin/
ENTRYPOINT ["/usr/local/bin/docker-varnish-entrypoint"]

EXPOSE 80 8443
CMD []
