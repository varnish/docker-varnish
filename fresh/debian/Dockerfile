FROM debian:stretch-slim

ENV VARNISH_VERSION 6.2.0-1~stretch

RUN set -ex; \
	fetchDeps=" \
		ca-certificates \
		dirmngr \
		gnupg \
	"; \
	apt-get update; \
	apt-get install -y --no-install-recommends apt-transport-https $fetchDeps; \
	key=B54813B54CA95257D3590B3F1B0096460868C7A9; \
	export GNUPGHOME="$(mktemp -d)"; \
	gpg --batch --keyserver http://ha.pool.sks-keyservers.net/ --recv-keys $key; \
	gpg --batch --export export $key > /etc/apt/trusted.gpg.d/varnish.gpg; \
	gpgconf --kill all; \
	echo deb https://packagecloud.io/varnishcache/varnish62/debian/ stretch main > /etc/apt/sources.list.d/varnish.list; \
	apt-get update; \
	apt-get install -y --no-install-recommends varnish=$VARNISH_VERSION; \
	apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false $fetchDeps; \
	rm -rf /var/lib/apt/lists/*

WORKDIR /etc/varnish

COPY docker-varnish-entrypoint /usr/local/bin/
ENTRYPOINT ["docker-varnish-entrypoint"]

EXPOSE 80
CMD ["varnishd", "-F", "-f", "/etc/varnish/default.vcl"]
