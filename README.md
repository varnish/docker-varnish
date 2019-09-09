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

# Image documentation

Please see https://github.com/docker-library/docs/tree/master/varnish
