# monorepo-examples

We have chosen a few combinations of 4 tools to evaluate:

1. [Bazel](https://bazel.build/)
2. [Monobuild](https://github.com/charypar/monobuild)
3. [NX](https://nx.dev/)
4. [Turborepo](https://turborepo.org/)

## Examples

Examples have been created as separate branches in this repo.  The intention is to let them stick around as long-lived branches for reference rather than to merge them.

### Bazel

- [`Bazel_Test`](https://github.com/redbadger/monorepo-examples/tree/Bazel_Test): example of a monorepo built with Bazel

### Monobuild

- [`monobuild`](https://github.com/redbadger/monorepo-examples/tree/monobuild): example of a monorepo built with Monobuild
- [`monobuild_effect`](https://github.com/redbadger/monorepo-examples/tree/monobuild_effect): branch based on `monobuild` with a small change made in order to examine which tasks are executed in CI
  
### Monobuild with Turborepo

- [`turborepo-monobuild`](https://github.com/redbadger/monorepo-examples/tree/turborepo-monobuild): example of a monorepo built with Monobuild primarily, using Turborepo under the hood for js code
- [`turborepo-monobuild_effect`](https://github.com/redbadger/monorepo-examples/tree/turborepo-monobuild_effect): branch based on `turborepo-monobuild` with a small change made in order to examine which tasks are executed in CI

### Nx

- [`nx`](https://github.com/redbadger/monorepo-examples/tree/nx): example of a monorepo built with NX
- [`nx_effect`](https://github.com/redbadger/monorepo-examples/tree/nx_effect): branch based on `nx` with a small change made in order to examine which tasks are executed in CI

### Turborepo

- [`turborepo`](https://github.com/redbadger/monorepo-examples/tree/turborepo): example of a monorepo built with Turborepo

### Turborepo with Rust

- [`turborepo-rust`](https://github.com/redbadger/monorepo-examples/tree/turborepo-rust): example of a monorepo built with Turborepo, including an example Rust lib
