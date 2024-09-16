FROM alpine:3.19

ARG  PKG_COMMIT=cfa8cb3724e4ca6398f60b09157715bcb99d189d
ARG  VARNISH_VERSION=7.5.0
ARG  DIST_SHA512=ca77abcb21299942b2bfd433e5f964d2e974cdae92d6a8889217fcd81933a3b7bc1e70ba87d7e842a4f90b59d7948242155380054d67ad49aab8dcea343055a2
ARG  VARNISH_MODULES_VERSION=0.24.0
ARG  VARNISH_MODULES_SHA512SUM=fd1b1b7ff61654e568df208229eb1af0086c98726592d1269ca5e13b24ce292a4ec6aeea52a5469f465ca426019629ef5db5a54dfed7f1fd2f0a4b50c92503a6
ARG  VMOD_DYNAMIC_VERSION=2.8.0-1
ARG  VMOD_DYNAMIC_COMMIT=5dc09f52cd8eeed77d879b0313bd8ad9a749477f
ARG  VMOD_DYNAMIC_SHA512SUM=0f57c1ca2d85acb4dce86f241a709486fc14dae03af4c6f9a4c59471e4ed2fe776c6a07ed24b898624025b52ed08a051340bc89ce539f25844a0b3650d14c292
ARG  TOOLBOX_COMMIT=cfa9ec43a47429ef94f7e04e4abc58c67ad50add
ENV  VMOD_DEPS="autoconf-archive automake curl libtool make pkgconfig py3-sphinx"

ENV VARNISH_SIZE 100M

RUN set -e;\
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
