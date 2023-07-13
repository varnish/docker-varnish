# Building vmods doesn't have to be hard

Varnish vmods can be a bit scary at first:
- they are often written in C
- building requires to fiddle with `make` and `autotools`
- there's often dependency issues making the whole process a trial-and-error enterprise

This directory hopes to fix remedy this by doing two things. The first one is providing examples on how to use the [install-vmod](https://github.com/varnish/toolbox/tree/master/install-vmod) that Varnish images include. The second one is to provide a curated list of vmods, including their dependencies so there's no confusion on how to install them. And to do this we'll regularly test that list to make sure the selected vmods still work with new Varnish versions.

# Types of vmods

Thankfully, there's a relatively small number of types of vmods:
- `C` vmods that just need the `dev` package of Varnish and a few classic dependencies (`make`, `autotools`, etc.)
- same as the first group, but those need access to the source of the exact version of Varnish that we build against
- `rust` vmods

Each type of vmod is represented by the a `Dockerfile.*` you'll find in this here directory. and you can have a look at the `build()` in the [examples.sh](./examples.sh) script to see how to use them.

# Contributing

Your vmod isn't in `example.sh`, but you'd like it to be? Open a PR and we'll include it, just be aware that we'll ping you for new Varnish releases (March 15th and September 15th) to check if there's a new vmod version, or if your code stops compiling against our current Docker image.

# Non-goals

Building a docker image is an intrisically custom business, and trying to cover all cases is a doomed ambition, so the examples only cover the latest `debian` image and don't care about installing multiple vmods at once. However, the issue tracker is open if you need any help, and you are welcome to reach out on the usual [support channels](https://varnish-cache.org/support)
