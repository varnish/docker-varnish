FROM alpine:3.14

ENV VARNISH_SIZE 100M

RUN set -e;\
    BASE_PKGS="tar alpine-sdk sudo git"; \
    apk add --virtual varnish-build-deps -q --no-progress --update $BASE_PKGS; \
    git clone https://github.com/varnishcache/pkg-varnish-cache.git; \
    cd pkg-varnish-cache/alpine; \
    git checkout d3e6a3fad7d4c2ac781ada92dcc246e7eef9d129; \
    sed -i APKBUILD \
        -e "s/pkgver=@VERSION@/pkgver=7.0.1/" \
	-e 's@^source=.*@source="http://varnish-cache.org/_downloads/varnish-$pkgver.tgz"@' \
	-e "s/^sha512sums=.*/sha512sums=\"7541d50b03a113f0a13660d459cc4c2eb45d57fb19380ab56a5413a4e5d702f9c0856585f09aeea6084a239ad8c69017af3805a864540b4697e0eac29f00b408  varnish-\$pkgver.tgz\"/"; \
    adduser -D builder; \
    echo "builder ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers; \
    addgroup builder abuild; \
    su builder -c "abuild-keygen -nai"; \
    chown builder -R .; \
    su builder -c "abuild -r";\
    apk add --allow-untrusted ~builder/packages/pkg-varnish-cache/*/*.apk; \
    echo -e 'vcl 4.1;\nbackend default none;' > /etc/varnish/default.vcl; \
    apk del --no-network varnish-build-deps; \
    rm -rf ~builder /pkg-varnish-cache; \
    sed -i '/^builder/d' /etc/sudoers; \
    deluser --remove-home builder; \
    chown varnish /var/lib/varnish

WORKDIR /etc/varnish

COPY scripts/ /usr/local/bin/
ENTRYPOINT ["/usr/local/bin/docker-varnish-entrypoint"]

USER varnish
EXPOSE 80 8443
CMD []
