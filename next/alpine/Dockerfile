FROM alpine:3.14

ARG  PKG_COMMIT=3ba24a8eee8cc5c082714034145b907402bbdb83
ARG  VARNISH_VERSION=7.1.0
ARG  DIST_SHA512=ad9ce0cdc759976fcb7044914d28863edd197167f583fab2d1bc57f4e5b86c224b7c948faf1f7364a2a16bde9c415375d011462bdc43026c5f7a60e65bd21f73
ARG  VARNISH_MODULES_VERSION=0.20.0
ARG  VARNISH_MODULES_SHA512SUM=e63d6da8f63a5ce56bc7a5a1dd1a908e4ab0f6a36b5bdc5709dca2aa9c0b474bd8a06491ed3dee23636d335241ced4c7ef017b57413b05792ad382f6306a0b36
ARG  VMOD_DYNAMIC_VERSION=2.6.0
ARG  VMOD_DYNAMIC_COMMIT=9666973952f62110c872d720af3dae0b85b4b597
ARG  VMOD_DYNAMIC_SHA512SUM=e62f1ee801ab2c9e22f5554bbe40c239257e2c46ea3d2ae19b465b1c82edad6f675417be8f7351d4f9eddafc9ad6c0149f88edc44dd0b922ad82e5d75b6b15a5

ENV VARNISH_SIZE 100M

COPY APKBUILD.vmod-dynamic /vmod-dynamic/alpine/APKBUILD
COPY APKBUILD.varnish-modules /varnish-modules/alpine/APKBUILD

RUN set -e;\
    BASE_PKGS="tar alpine-sdk sudo git"; \
    apk add --virtual varnish-build-deps -q --no-progress --update $BASE_PKGS; \
    git clone https://github.com/varnishcache/pkg-varnish-cache.git; \
    cd pkg-varnish-cache/alpine; \
    git checkout 3ba24a8eee8cc5c082714034145b907402bbdb83; \
    sed -i APKBUILD \
        -e "s/pkgver=@VERSION@/pkgver=7.1.0/" \
	-e 's@^source=.*@source="https://varnish-cache.org/downloads/varnish-$pkgver.tgz"@' \
	-e "s/^sha512sums=.*/sha512sums=\"ad9ce0cdc759976fcb7044914d28863edd197167f583fab2d1bc57f4e5b86c224b7c948faf1f7364a2a16bde9c415375d011462bdc43026c5f7a60e65bd21f73  varnish-\$pkgver.tgz\"/"; \
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
