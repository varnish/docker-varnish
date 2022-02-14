FROM alpine:3.14

ARG  PKG_COMMIT=d3e6a3fad7d4c2ac781ada92dcc246e7eef9d129
ARG  VARNISH_VERSION=7.0.2
ARG  DIST_SHA512=5eb08345c95152639266b7ad241185188477f8fd04e88e4dfda1579719a1a413790a0616f25d70994f6d3b8f7640ea80926ece7c547555dad856fd9f6960c9a3
ARG  VARNISH_MODULES_VERSION=0.19.0
ARG  VARNISH_MODULES_SHA512SUM=fc6f4c1695f80fa3b267c13c772dca9cf577eed38c733207cf0f8e01b5d4ebabbe43e936974ba70338a663a45624254759cfd75f8fbae0202361238ee5f15cef
ARG  VMOD_DYNAMIC_VERSION=2.5.0
ARG  VMOD_DYNAMIC_COMMIT=4d0ca5230d563d9c0e03df0ec6e01f7c174fdfd5
ARG  VMOD_DYNAMIC_SHA512SUM=ea9dceb88fb472faaec5e7ff79f65afdcdbfde9661fb460c629bffdcea4a9f51e3499aab9e5c202d382d3460912f502145af21e54a5e4a8ae25b34051a484b35

ENV VARNISH_SIZE 100M

COPY APKBUILD.vmod-dynamic /vmod-dynamic/alpine/APKBUILD
COPY APKBUILD.varnish-modules /varnish-modules/alpine/APKBUILD

RUN set -e;\
    BASE_PKGS="tar alpine-sdk sudo git"; \
    apk add --virtual varnish-build-deps -q --no-progress --update $BASE_PKGS; \
    git clone https://github.com/varnishcache/pkg-varnish-cache.git; \
    cd pkg-varnish-cache/alpine; \
    git checkout d3e6a3fad7d4c2ac781ada92dcc246e7eef9d129; \
    sed -i APKBUILD \
        -e "s/pkgver=@VERSION@/pkgver=7.0.2/" \
	-e 's@^source=.*@source="https://varnish-cache.org/downloads/varnish-$pkgver.tgz"@' \
	-e "s/^sha512sums=.*/sha512sums=\"5eb08345c95152639266b7ad241185188477f8fd04e88e4dfda1579719a1a413790a0616f25d70994f6d3b8f7640ea80926ece7c547555dad856fd9f6960c9a3  varnish-\$pkgver.tgz\"/"; \
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
    # build and install varnish-modules package
    cd /varnish-modules/alpine; \
    sed -i APKBUILD \
        -e "s/@VARNISH_VERSION\@/$VARNISH_VERSION/" \
        -e "s/@VARNISH_MODULES_VERSION\@/$VARNISH_MODULES_VERSION/" \
        -e "s/@VARNISH_MODULES_SHA512SUM\@/$VARNISH_MODULES_SHA512SUM/"; \
    chown builder -R .; \
    su builder -c "abuild -r";\
    apk add --allow-untrusted ~builder/packages/varnish-modules/*/*.apk; \
    \
    # build and install vmod-dynamic package
    cd /vmod-dynamic/alpine; \
    sed -i APKBUILD \
        -e "s/@VARNISH_VERSION\@/$VARNISH_VERSION/" \
        -e "s/@VMOD_DYNAMIC_VERSION\@/$VMOD_DYNAMIC_VERSION/" \
        -e "s/@VMOD_DYNAMIC_COMMIT\@/$VMOD_DYNAMIC_COMMIT"/ \
        -e "s/@VMOD_DYNAMIC_SHA512SUM\@/$VMOD_DYNAMIC_SHA512SUM/"; \
    chown builder -R .; \
    su builder -c "abuild -r";\
    apk add --allow-untrusted ~builder/packages/vmod-dynamic/*/*.apk; \
    \
    # cleanup
    apk del --no-network varnish-build-deps; \
    rm -rf ~builder /pkg-varnish-cache /varnish-modules /vmod-dynamic /etc/sudoers.d/builder; \
    deluser --remove-home builder; \
    chown varnish /var/lib/varnish;

WORKDIR /etc/varnish

COPY scripts/ /usr/local/bin/
ENTRYPOINT ["/usr/local/bin/docker-varnish-entrypoint"]

USER varnish
EXPOSE 80 8443
CMD []
