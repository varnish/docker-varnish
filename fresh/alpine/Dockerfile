FROM alpine:3.19

ARG  PKG_COMMIT=7d90347be31891b338dededb318594cebb668ba7
ARG  VARNISH_VERSION=7.6.0
ARG  DIST_SHA512=11ca965837ef38aa52487f388555dd56a33faaff61d6662e9df647891cf444309323c665fd353c49c69ba327beeba131730b397d1849b8cff721f0d8257b9f48
ARG  VARNISH_MODULES_VERSION=0.25.0
ARG  VARNISH_MODULES_SHA512SUM=2ad8ebeab165002d1bfba9a2088951fb10ff573f0205d3f04e68921f191441f4026450f3a0b78f2aa96f40c82838a2d4d5f0688141fa7b8241ae7b7a5f507c10
ARG  VMOD_DYNAMIC_VERSION=7.6-master
ARG  VMOD_DYNAMIC_COMMIT=5e01fb2176911d68c82c5bafec1ae8dc53da1e95
ARG  VMOD_DYNAMIC_SHA512SUM=e25ba047dcee58173901c2742afc36e79bc2b501c1bb7210d69297db031d749179bcde322f0bc9b83224688857e594e2cc64d7995aa7b66ab4936ffc70a50182
ARG  TOOLBOX_COMMIT=cfa9ec43a47429ef94f7e04e4abc58c67ad50add
ENV  VMOD_DEPS="autoconf-archive automake curl libtool make pkgconfig py3-sphinx"

ENV VARNISH_SIZE=100M
ENV VSM_NOPID=1

RUN set -ex;\
    BASE_PKGS="tar alpine-sdk sudo py3-docutils python3 autoconf automake libtool"; \
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
    # varnish-modules
    install-vmod https://github.com/varnish/varnish-modules/releases/download/$VARNISH_MODULES_VERSION/varnish-modules-$VARNISH_MODULES_VERSION.tar.gz $VARNISH_MODULES_SHA512SUM; \
    \
    # vmod-dynamic
    SKIP_CHECK=1 install-vmod https://github.com/nigoroll/libvmod-dynamic/archive/$VMOD_DYNAMIC_COMMIT.tar.gz $VMOD_DYNAMIC_SHA512SUM; \
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
