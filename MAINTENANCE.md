# New release playbook

1. Update the `fresh/`, `old/`,`stable/` as needed (in case of a regular new release, `fresh/` becomes `old/, and a new `fresh/` is created)
2. Commit and push
3. Make sure CI passes
4. Generate a new `library` file using `./populate.sh library`
5. Open a PR for the library file [docker-library/official-images repository](https://github.com/docker-library/official-images/blob/master/library/varnish)
6. Optionally, open a PR to update the documentation in the [docker-library/docs repository](https://github.com/docker-library/docs/tree/master/varnish)

