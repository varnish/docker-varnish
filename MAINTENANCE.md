# New release playbook

1. Update the `fresh/`, `old/`,`stable/` as needed (in case of a regular new release, `fresh/` becomes `old/`, and a new `fresh/` is created)
2. Commit and push
3. Make sure CI passes
4. Run the [`Publish stackbrew library PR` workflow](https://github.com/varnish/docker-varnish/actions/workflows/library-pr.yml) (manual `workflow_dispatch`), or locally: `./populate.sh library && GH_TOKEN=<token> ./open-library-pr.sh`. This generates the `library.varnish` file and opens (or updates) a PR against the [docker-library/official-images repository](https://github.com/docker-library/official-images/blob/master/library/varnish) from the `varnish/official-images` fork. (No access to that fork? Run `./open-library-pr.sh -f <your-user>/official-images` against your own fork instead.)
5. Optionally, open a PR to update the documentation in the [docker-library/docs repository](https://github.com/docker-library/docs/tree/master/varnish)

