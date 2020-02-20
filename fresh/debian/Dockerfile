FROM debian:stretch-slim

ENV VARNISH_VERSION 6.3.2-1~stretch
ENV SIZE 100M

RUN set -ex; \
	fetchDeps=" \
		dirmngr \
		gnupg \
	"; \
	apt-get update; \
	apt-get install -y --no-install-recommends apt-transport-https ca-certificates $fetchDeps; \
	key=920A8A7AA7120A8604BCCD294A42CD6EB810E55D; \
	export GNUPGHOME="$(mktemp -d)"; \
	gpg --batch --keyserver http://ha.pool.sks-keyservers.net/ --recv-keys $key; \
	gpg --batch --export export $key > /etc/apt/trusted.gpg.d/varnish.gpg; \
	gpgconf --kill all; \
	rm -rf $GNUPGHOME; \
	echo deb https://packagecloud.io/varnishcache/varnish63/debian/ stretch main > /etc/apt/sources.list.d/varnish.list; \
	apt-get update; \
	apt-get install -y --no-install-recommends varnish=$VARNISH_VERSION; \
	apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false $fetchDeps; \
	rm -rf /var/lib/apt/lists/*

WORKDIR /etc/varnish

COPY docker-varnish-entrypoint /usr/local/bin/
ENTRYPOINT ["docker-varnish-entrypoint"]

EXPOSE 80 8443
CMD varnishd -F -f /etc/varnish/default.vcl -a http=:80,HTTP -a proxy=:8443,PROXY -s malloc,$SIZE
