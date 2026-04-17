FROM debian:bookworm-slim

ARG  REPO_FINGERPRINT=694566269779DFAC975ED9BDD0525EAE838B3344
ARG  VARNISH_VERSION_NUMBER=6.0.17-1

ENV VARNISH_SIZE=100M

RUN set -ex; \
    . /etc/os-release; \
    VARNISH_VERSION=$VARNISH_VERSION_NUMBER~$VERSION_CODENAME; \
    BASE_PKGS="curl gpg"; \
    export DEBIAN_FRONTEND=noninteractive; \
    export DEBCONF_NONINTERACTIVE_SEEN=true; \
    \
    apt-get update; \
    apt-get install -y curl $BASE_PKGS; \
    mkdir -p /etc/apt/keyrings; \
    gpg --batch --keyserver hkps://keys.openpgp.org --recv-keys $REPO_FINGERPRINT; \
    gpg --batch --export "$REPO_FINGERPRINT" > /etc/apt/keyrings/varnish.gpg; \
    echo "deb [signed-by=/etc/apt/keyrings/varnish.gpg] https://packages.varnish-software.com/varnish/$ID $VERSION_CODENAME main" | tee -a /etc/apt/sources.list.d/varnish.list; \
    apt-get update; \
    # create users and groups with fixed IDs
    adduser --uid 1000 --quiet --system --no-create-home --home /nonexistent --group varnish; \
    adduser --uid 1001 --quiet --system --no-create-home --home /nonexistent --ingroup varnish vcache; \
    adduser --uid 1002 --quiet --system --no-create-home --home /nonexistent --ingroup varnish varnishlog; \
    \
    apt-get update; \
    apt-get install -y --no-install-recommends \
				varnish=${VARNISH_VERSION}; \
    # clean up the temporary GPG home directory
    rm -rf ~/.gnupg; \
    chown varnish /var/lib/varnish; \
    mkdir -p -m 1777 /var/lib/varnish/varnishd

WORKDIR /etc/varnish

COPY scripts/ /usr/local/bin/
ENTRYPOINT ["/usr/local/bin/docker-varnish-entrypoint"]

EXPOSE 80 8443
CMD []
