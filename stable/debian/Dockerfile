FROM debian:stretch-slim

ENV VARNISH_VERSION 6.0.3-1~stretch

RUN set -ex; \
	fetchDeps=" \
		ca-certificates \
		dirmngr \
		gnupg \
	"; \
	apt-get update; \
	apt-get install -y --no-install-recommends apt-transport-https $fetchDeps; \
	key=48D81A24CB0456F5D59431D94CFCFD6BA750EDCD; \
	export GNUPGHOME="$(mktemp -d)"; \
	gpg --batch --keyserver http://ha.pool.sks-keyservers.net/ --recv-keys $key; \
	gpg --batch --export export $key > /etc/apt/trusted.gpg.d/varnish.gpg; \
	gpgconf --kill all; \
	echo deb https://packagecloud.io/varnishcache/varnish60lts/debian/ stretch main > /etc/apt/sources.list.d/varnish.list; \
	apt-get update; \
	apt-get install -y --no-install-recommends varnish=$VARNISH_VERSION; \
	apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false $fetchDeps; \
	rm -rf /var/lib/apt/lists/*

WORKDIR /etc/varnish

COPY docker-varnish-entrypoint /usr/local/bin/
ENTRYPOINT ["docker-varnish-entrypoint"]

EXPOSE 80
CMD ["varnishd", "-F", "-f", "/etc/varnish/default.vcl"]
