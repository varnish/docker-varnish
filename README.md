[![Docker Pulls](https://img.shields.io/docker/pulls/_/varnish.svg)](https://hub.docker.com/r/_/varnish)
[![GitHub CI build status badge](https://github.com/varnish/docker-varnish/workflows/GitHub%20CI/badge.svg)](https://github.com/varnish/docker-varnish/actions?query=workflow%3A%22GitHub+CI%22)
[![Documentation](https://img.shields.io/badge/image-documentation-blue)](https://hub.docker.com/_/varnish)
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

# Official Varnish Docker image

This is the source repository used to build the official [Varnish Docker image](https://hub.docker.com/_/varnish) and the [Varnish Enterprise image](https://hub.docker.com/r/varnish/varnish-enterprise)

Don't hesitate to open github issues if something is unclear or impractical. You can also join us on [discord](https://discord.com/invite/EuwdvbZR6d).

# Directories

The official Varnish image tracks three different versions using distinct directories:

- `fresh/`: the latest release.
- `old/`: the release before `fresh`.
- `stable/`: an Long-Term Support (LTS) release that will receive bug and security fixes even though it's not the latest one.

New major/minor versions are released on the 15th of March and of September, this is when the `fresh` and `stable` labels are reevaluated.

In addition, if present, the `next/` directory is a copy of `fresh/` with breaking changes that must wait for the the next release to be published. This image **isn't available on the Docker hub**.

For Varnish Enterprise, we only use `enterprise/`.
