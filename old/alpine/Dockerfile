FROM alpine:3.15

ARG  PKG_COMMIT=ffc59a345217b599fd49f7f0442b5f653fbe6fc2
ARG  VARNISH_VERSION=7.2.1
ARG  DIST_SHA512=7b9b837a8bafdf5798e81bc38163457b3bca16d933a9492800cdd2cde35c9b524a10b7e5ec931217e11d72f32feb05157a7eecfd9cf2c5856e717b634e51d089
ARG  VARNISH_MODULES_VERSION=0.21.0
ARG  VARNISH_MODULES_SHA512SUM=a442f58968b471d713c99a94e5b80302c07ea163d3d5022d768eb0b39ab081f18744fd529b04283b0c6ec942f362197935d8ef1aa04f26eff10a81425a63bd35
ARG  VMOD_DYNAMIC_VERSION=2.8.0
ARG  VMOD_DYNAMIC_COMMIT=5c702fa6c3a88882a2678f75161692762e7d6c47
ARG  VMOD_DYNAMIC_SHA512SUM=3503ae09bae731213d5a6823af9fb758bcbcaf06678a2a0efc0b35d9f1b18ab46e02f02b75db8a4858bb2b623e76ea253e65ef2ae3ab076558b52b414996d33a
ARG  TOOLBOX_COMMIT=721c66e07e64d48de93978cfc4aa1051ef10df7b
ENV  VMOD_DEPS="automake curl libtool make pkgconfig py3-sphinx"

ENV VARNISH_SIZE 100M

RUN set -e;\
    BASE_PKGS="tar alpine-sdk sudo py3-docutils python3 autoconf automake libtool"; \
    apk add --virtual varnish-build-deps -q --no-progress --update $BASE_PKGS; \
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
    \
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
    chown varnish /var/lib/varnish;

WORKDIR /etc/varnish

COPY scripts/ /usr/local/bin/

ENTRYPOINT ["/usr/local/bin/docker-varnish-entrypoint"]

USER varnish
EXPOSE 80 8443
CMD []
