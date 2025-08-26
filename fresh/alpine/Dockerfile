FROM alpine:3.22

ARG  PKG_COMMIT=7d90347be31891b338dededb318594cebb668ba7
ARG  VARNISH_VERSION=7.7.3
ARG  DIST_SHA512=2de3f19d24e42ec092076226b629dc36d4d3c9961454502e7f9a8ff1d440cf54104198e2b5302361f093fa221f04f836bb8dda441921d1721b1d05c90c0f1661
ARG  VARNISH_MODULES_VERSION=0.26.0
ARG  VARNISH_MODULES_SHA512SUM=2050ec65ae731bddc74743c9aa6246e41ffba8017c404c32e50d45f72f5a02dd3eb2290f8b8e43e25a385a06819836fb19f8540f1cdae394083729ff6b6aed35
ARG  VMOD_DYNAMIC_VERSION=7.7
ARG  VMOD_DYNAMIC_COMMIT=490068ba146c48fd7201c8d19cdb37f6d7d932c7
ARG  VMOD_DYNAMIC_SHA512SUM=3ff84710d4d9c4fd956cc27c41ae8b3d0bed4db7a2ca70d61e3900cd1f77ff293e2be3551d044a644ec76c6678517d788511e61c803dda2fe75bd5c286d5901b
ARG  TOOLBOX_COMMIT=cfa9ec43a47429ef94f7e04e4abc58c67ad50add
ENV  VMOD_DEPS="autoconf-archive automake curl libtool make pkgconfig py3-sphinx"

ENV VARNISH_SIZE=100M
ENV VSM_NOPID=1

RUN set -ex;\
    BASE_PKGS="tar alpine-sdk curl sudo py3-docutils python3 autoconf automake libtool"; \
    apk add --virtual varnish-build-deps -q --no-progress --update $BASE_PKGS; \
    \
    # create users and groups with fixed IDs
    addgroup -g 1000 -S varnish; \
    adduser -u 1000 -S -D -H -s /sbin/nologin -G varnish -g varnish varnish; \
    adduser -u 1001 -S -D -H -s /sbin/nologin -G varnish -g varnish vcache; \
    adduser -u 1002 -S -D -H -s /sbin/nologin -G varnish -g varnish varnishlog; \
    \
    adduser -D builder; \
    echo "builder ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/builder; \
    addgroup builder abuild; \
    su builder -c "abuild-keygen -nai"; \
    \
    # varnish tarball and packaging
    git clone https://github.com/varnishcache/pkg-varnish-cache.git; \
    cd pkg-varnish-cache/alpine; \
    git checkout $PKG_COMMIT; \
    sed -i APKBUILD \
        -e "s/pkgver=@VERSION@/pkgver=$VARNISH_VERSION/" \
	-e 's@^source=.*@source="http://varnish-cache.org/_downloads/varnish-$pkgver.tgz"@' \
	-e "s/^sha512sums=.*/sha512sums=\"$DIST_SHA512  varnish-\$pkgver.tgz\"/"; \
    \
    # build and install varnish package
    chown builder -R .; \
    su builder -c "abuild -r"; \
    apk add --allow-untrusted ~builder/packages/pkg-varnish-cache/*/*.apk; \
    echo -e 'vcl 4.1;\nbackend default none;' > /etc/varnish/default.vcl; \
    \
    git clone https://github.com/varnish/toolbox.git; \
    cd toolbox; \
    git checkout $TOOLBOX_COMMIT; \
    cp install-vmod/install-vmod /usr/local/bin/; \
    cp vcls/verbose_builtin/verbose_builtin.vcl vcls/hit-miss/hit-miss.vcl /etc/varnish/; \
    \
    varnishd -V; \
    # varnish-modules
    install-vmod https://github.com/varnish/varnish-modules/releases/download/$VARNISH_MODULES_VERSION/varnish-modules-$VARNISH_MODULES_VERSION.tar.gz $VARNISH_MODULES_SHA512SUM; \
    \
    # vmod-dynamic
    install-vmod https://github.com/nigoroll/libvmod-dynamic/archive/$VMOD_DYNAMIC_COMMIT.tar.gz $VMOD_DYNAMIC_SHA512SUM; \
    \
    # cleanup
    apk del --no-network varnish-build-deps; \
    rm -rf ~builder /pkg-varnish-cache /varnish-modules /vmod-dynamic /etc/sudoers.d/builder; \
    deluser --remove-home builder; \
    chown varnish /var/lib/varnish; \
    mkdir -p -m 1777 /var/lib/varnish/varnishd

WORKDIR /etc/varnish

COPY scripts/ /usr/local/bin/
COPY default.vcl /etc/varnish/

ENTRYPOINT ["/usr/local/bin/docker-varnish-entrypoint"]

USER varnish
EXPOSE 80 8443
CMD []
