[![Build Status](https://travis-ci.org/_/varnish.svg?branch=master)](https://travis-ci.org/_/varnish)
[![Docker Pulls](https://img.shields.io/docker/pulls/_/varnish.svg)](https://hub.docker.com/r/_/varnish)
[![Docker Stars](https://img.shields.io/docker/stars/_/varnish.svg)](https://hub.docker.com/r/_/varnish)
[![GitHub CI build status badge](https://github.com/varnish/docker-varnish/workflows/GitHub%20CI/badge.svg)](https://github.com/varnish/docker-varnish/actions?query=workflow%3A%22GitHub+CI%22)
<!--[![update.sh build status badge](https://img.shields.io/jenkins/s/https/doi-janky.infosiftr.net/job/update.sh/job/varnish.svg?label=Automated%20update.sh)](https://doi-janky.infosiftr.net/job/update.sh/job/varnish/)
[![amd64 build status badge](https://img.shields.io/jenkins/s/https/doi-janky.infosiftr.net/job/multiarch/job/amd64/job/varnish.svg?label=amd64)](https://doi-janky.infosiftr.net/job/multiarch/job/amd64/job/varnish)
[![arm32v5 build status badge](https://img.shields.io/jenkins/s/https/doi-janky.infosiftr.net/job/multiarch/job/arm32v5/job/varnish.svg?label=arm32v5)](https://doi-janky.infosiftr.net/job/multiarch/job/arm32v5/job/varnish)
[![arm32v6 build status badge](https://img.shields.io/jenkins/s/https/doi-janky.infosiftr.net/job/multiarch/job/arm32v6/job/varnish.svg?label=arm32v6)](https://doi-janky.infosiftr.net/job/multiarch/job/arm32v6/job/varnish)
[![arm32v7 build status badge](https://img.shields.io/jenkins/s/https/doi-janky.infosiftr.net/job/multiarch/job/arm32v7/job/varnish.svg?label=arm32v7)](https://doi-janky.infosiftr.net/job/multiarch/job/arm32v7/job/varnish)
[![arm64v8 build status badge](https://img.shields.io/jenkins/s/https/doi-janky.infosiftr.net/job/multiarch/job/arm64v8/job/varnish.svg?label=arm64v8)](https://doi-janky.infosiftr.net/job/multiarch/job/arm64v8/job/varnish)
[![i386 build status badge](https://img.shields.io/jenkins/s/https/doi-janky.infosiftr.net/job/multiarch/job/i386/job/varnish.svg?label=i386)](https://doi-janky.infosiftr.net/job/multiarch/job/i386/job/varnish)
[![mips64le build status badge](https://img.shields.io/jenkins/s/https/doi-janky.infosiftr.net/job/multiarch/job/mips64le/job/varnish.svg?label=mips64le)](https://doi-janky.infosiftr.net/job/multiarch/job/mips64le/job/varnish)
[![ppc64le build status badge](https://img.shields.io/jenkins/s/https/doi-janky.infosiftr.net/job/multiarch/job/ppc64le/job/varnish.svg?label=ppc64le)](https://doi-janky.infosiftr.net/job/multiarch/job/ppc64le/job/varnish)
[![s390x build status badge](https://img.shields.io/jenkins/s/https/doi-janky.infosiftr.net/job/multiarch/job/s390x/job/varnish.svg?label=s390x)](https://doi-janky.infosiftr.net/job/multiarch/job/s390x/job/varnish)-->

This is the source repository use to build the official [Varnish Docker image](https://hub.docker.com/_/varnish).

# Versions

This repository tracks two Varnish versions:

- `fresh`: the latest release.
- `stable`: an Long-Term Support (LTS) release that will receive bug and security fixes even though it's not the latest one.

New major/minor versions are release on the 15th of March and of September, this is when the `fresh` and `stable` labels are reevaluated.

# Building

The docker build directories are under `fresh/` and `stable/`. Dockerfiles are generated all at once using:

```
# don't forget to commit there afterward
./populate.sh dockerfiles
```

Edit `./populate.sh` first if you want to modify the labels and installed versions.

To generate the file that will become https://github.com/docker-library/official-images/blob/master/library/varnish, use:

```
# commit your changes first!
./populate.sh library
```
# Running

When running the Varnish image, a `varnishd` process will be started that listens on the following ports:

* port `80` for *plain HTTP*
* port `8443` for the *PROXY protocol*

> See [TLS section](#tls) for more information about the primary *PROXY protocol* use case.

Varnish will run with a default memory storage size of `100M`. The `VARNISH_SIZE` *environment variable* can be used to extend the size.

# TLS

If you want to connect to Varnish via *HTTPS*, you'll need to terminate the *TLS* connection elsewhere. *TLS termination* can be done on some loadbalancers or proxy servers, but the Varnish ecosystem also provides *a purpose-built TLS terminator* called [Hitch](https://hitch-tls.org/). 

Hitch supports the [PROXY protocol](https://www.haproxy.org/download/1.8/doc/proxy-protocol.txt) and is transparent to Varnish. The *PROXY protocol* has the ability to keep track of *the original client IP address*.

> Hitch, or any other TLS terminator that supports the *PROXY protocol* will connect to Varnish on port `8443`.

# Image documentation

Please see https://github.com/docker-library/docs/tree/master/varnish
