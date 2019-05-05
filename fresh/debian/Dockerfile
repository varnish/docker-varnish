FROM debian:stretch-slim

COPY gpgkey /tmp

RUN apt-get update && \
    apt-get install -y \
	curl \
	gnupg \
	apt-transport-https && \
    apt-key add /tmp/gpgkey && \
    echo deb https://packagecloud.io/varnishcache/varnish62/debian/ stretch main > /etc/apt/sources.list.d/varnish.list && \
    apt-get update && \
    apt-get install -y varnish=6.2.0-1~stretch && \
    apt-get remove -y \
	curl \
	gnupg \
	apt-transport-https && \
    apt-get clean -y && \
    apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/* /tmp/gpgkey

WORKDIR /etc/varnish

COPY docker-varnish-entrypoint /usr/local/bin/
ENTRYPOINT ["docker-varnish-entrypoint"]

EXPOSE 80
CMD ["varnishd", "-F", "-f", "/etc/varnish/default.vcl"]
