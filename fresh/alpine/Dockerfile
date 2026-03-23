FROM alpine:3.23

ARG  PKG_COMMIT=3caf80c
ARG  VARNISH_VERSION=9.0.0
ARG  DIST_SHA512=0c3f7f8df1da0465e76af7986082b4588ac1b1ca7310f354e679be196d8de417bb8812d48b5cd75f1916fb2f5d009f7f9e9798ce81124380e31517f9c2c19fa7
ARG  VARNISH_MODULES_VERSION=0.28.0
ARG  VARNISH_MODULES_SHA512SUM=796f95ea6f8b69f6e4fb3daf327c4a6cccc9b6c927d8daace753aad7e443c1f937020465924e472ad65bb0a10e2e5bf85b6228afe3257dbfba0091750fbf300a
ARG  VMOD_FILESERVER_VERSION=0.0.10
ARG  VMOD_FILESERVER_SHA512SUM=b504f6389d000211a0dd1087c158d6c6e4518fbea36406ad5b321ee32b09330cb8c28d52508263fcae04a328daa0d2fb9f63789310010691ab9812b1a10f8c64
ARG  VMOD_REQWEST_VERSION=0.0.16
ARG  VMOD_REQWEST_SHA512SUM=52f0ae6acf481eea049ed5f88f3b6dbe2d66071db060d925866bb630cd8fa98e9bcce987b428844f75c849944c38a73f22a03df90935bc5795a34d751eed2ec7
ARG  TOOLBOX_COMMIT=da1c5ce23d2ad81032bb45627d10a8dcb2c6f1d9
ENV  VMOD_DEPS="autoconf-archive automake curl libtool make pkgconfig py3-sphinx"

ENV VARNISH_SIZE=100M
ENV VSM_NOPID=1

RUN set -ex;\
    BASE_PKGS="alpine-sdk autoconf automake ca-certificates cargo clang-dev \
                curl jq libtool openssl-dev py3-docutils python3 sudo tar"; \
    \
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
    git clone https://github.com/varnish/all-packager.git; \
    cd all-packager; \
    git checkout $PKG_COMMIT; \
    cd varnish/alpine; \
    ls; \
    sed -i APKBUILD \
        -e "s/pkgver=@VERSION@/pkgver=$VARNISH_VERSION/" \
	-e 's@^source=.*@source="https://github.com/varnish/varnish/releases/download/varnish-$pkgver/varnish-$pkgver.tar.gz"@' \
	-e "s/^sha512sums=.*/sha512sums=\"$DIST_SHA512  varnish-\$pkgver.tar.gz\"/"; \
    \
    # build and install varnish package
    chown builder -R .; \
    su builder -c "abuild -r"; \
    apk add --allow-untrusted ~builder/packages/varnish/*/*.apk; \
    \
    git clone https://github.com/varnish/toolbox.git; \
    cd toolbox; \
    git checkout $TOOLBOX_COMMIT; \
    cp install-vmod/install-vmod /usr/local/bin/; \
    cp vcls/verbose_builtin/verbose_builtin.vcl vcls/hit-miss/hit-miss.vcl /etc/varnish/; \
    \
    # varnish-modules
    install-vmod https://github.com/varnish/varnish-modules/releases/download/$VARNISH_MODULES_VERSION/varnish-modules-$VARNISH_MODULES_VERSION.tar.gz; \
    install-vmod https://github.com/varnish-rs/vmod-fileserver/archive/refs/tags/v$VMOD_FILESERVER_VERSION.tar.gz $VMOD_FILESERVER_SHA512SUM; \
    SKIP_CHECK=1 install-vmod https://github.com/varnish-rs/vmod-reqwest/archive/refs/tags/v$VMOD_REQWEST_VERSION.tar.gz $VMOD_REQWEST_SHA512SUM; \
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
COPY index.html /var/www/html/

ENTRYPOINT ["/usr/local/bin/docker-varnish-entrypoint"]

USER varnish
EXPOSE 80 8443
CMD []
