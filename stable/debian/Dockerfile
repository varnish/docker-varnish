FROM debian:buster-slim

ENV VARNISH_SIZE 100M

RUN set -e; \
    BASE_PKGS="curl dpkg-dev debhelper devscripts equivs git pkg-config apt-utils fakeroot"; \
    export DEBIAN_FRONTEND=noninteractive; \
    export DEBCONF_NONINTERACTIVE_SEEN=true; \
    apt-get update; \
    apt-get install -y $BASE_PKGS; \
    git clone https://github.com/varnishcache/pkg-varnish-cache.git; \
    cd pkg-varnish-cache; \
    git checkout 6890e35e3fd95fe2db068f8899dfff0855c354be; \
    rm -rf .git; \
    curl http://varnish-cache.org/_downloads/varnish-6.0.8.tgz -o /tmp/orig.tgz; \
    echo "73ed2f465ba3b11680b20a70633fc78da9b3eac68395f927b7ff02f4106b6cc92a2b395db2813a0605da2771530e5c4fc594eaf5a9a32bf2e42181b6dd90cf3f  /tmp/orig.tgz" | sha512sum -c -; \
    tar xavf /tmp/orig.tgz --strip 1; \
    sed -i -e "s|@VERSION@|6.0.8|"  "debian/changelog"; \
    yes | mk-build-deps --install debian/control || true; \
    tar cvzf debian.tar.gz debian --dereference; tar xavf debian.tar.gz; \
    sed -i '' debian/varnish*; \
    dpkg-buildpackage -us -uc -j16; \
    apt-get install -y ../*.deb; \
    apt remove -y varnish-build-deps $BASE_PKGS; \
    rm -rf /var/lib/apt/lists/*

WORKDIR /etc/varnish

COPY scripts/ /usr/local/bin/
ENTRYPOINT ["/usr/local/bin/docker-varnish-entrypoint"]

EXPOSE 80 8443
CMD []
