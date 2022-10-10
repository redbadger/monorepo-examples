# Monobuild with turborepo

This repo was created following the official [pnpm turborepo Quickstart instructions](https://turborepo.org/docs/getting-started/create-new), and was adapted to bring in turborepo for multi-language support and more fine-grained control over distributed task execution in CI.

## What's inside?

This repo uses [pnpm](https://pnpm.io) as a package manager. It includes the following packages/apps:

### Apps and Packages

- `docs`: a [Next.js](https://nextjs.org) app
- `hello-world-api`: a [Rust](https://www.rust-lang.org/) service depended upon by `docs`
- `web`: another [Next.js](https://nextjs.org) app
- `ui`: a stub React component library shared by both `web` and `docs` applications
- `eslint-config-custom`: `eslint` configurations (includes `eslint-config-next` and `eslint-config-prettier`)
- `tsconfig`: `tsconfig.json`s used throughout the monorepo

Each package/app is 100% [TypeScript](https://www.typescriptlang.org/) with the exception of the `hello-world-api`, which is written in [Rust](https://www.rust-lang.org/) as a proof of concept for multi-language support using [monobuild](https://github.com/charypar/monobuild) alongside `turborepo`.

## Combining `monobuild` & `turborepo`

While turborepo is able to intelligently execute tasks for all JS packages and their dependencies given the pipeline defined in `turbo.json`, it does nothing to help with non-JS code.  And while `monobuild` is entirely language agnostic, it doesn't actually _do_ anything in the realm of what `turborepo` does, like start up all of the dependent services given an app entrypoint, despite the fact that it gives us a build schedule to do with as we please.

### Declaring dependencies

While `turborepo`'s source of truth for building a dependency tree is the `package.json` file, `monobuild`'s source of truth is the `Dependencies` file.  This introduces 2 separate files to reason about (and keep in sync in most cases) when it comes to declaring dependencies in the monorepo.  This is probably not a massive overhead.

### Entrypoints & running tasks

With `monobuild`, we tend to use the `Makefile` to execute tasks (though we can use anything we want to), whereas with `turborepo`, you must use scripts declared in `package.json` files, and the task execution schedule is built intelligently based on the pipeline defined in the root `turbo.json`.  It becomes confusing to know when to use which.

In this repo, the `Makefile`s contain commands to facilitate launching apps and services in a more ad-hoc manner, which is to say that there is not a tool implemented in this POC that builds a dependency tree and executes all matching targets in a `Makefile` the way that turborepo runs all matching scripts in a `package.json`. This may or may not be a problem.

It is worth mentioning that while it might be fairly simple to build a small abstraction using `monobuild` to provide a common, language-agnostic interface for developers while continuing to benefit from the features `turborepo` provides by delegating any JS tasks to it (which is how we've enabled the CI workflow in this POC), there does seem to be contention between `monobuild` and `turborepo` in that they both solve similar problems in different ways. While it is possible to generate a build schedule using `monobuild`, and to use that schedule to execute individual `turborepo` tasks, that is being accomplished by running "filtered" `turbo` commands from the root of the monorepo. Ideally, in the future, we could either:

- Use turborepo to generate its own build schedule instead of combining it with `monobuild`. There will be a `--plan` flag in the future to facilitate this, and it's probably possible to do now using the `--dry=json` argument, but it doesn't answer the question of how to handle non-JS code.  See [`turborepo-rust`](https://github.com/redbadger/monorepo-examples/tree/turborepo-rust) for a potential answer to that question.

OR

- Use `monobuild` as the primary build system/task execution entrypoint, and use `turbo` commands from the individual packages instead of from the monorepo root. We would then benefit from a subset of `turborepo` features, namely caching & remote caching. See [`--single-package`](https://github.com/vercel/turborepo/pull/1979/files#diff-8629b7d4e5a1b19b824344affef5a0c00c31beb6fef842f5a0799100ee439197) flag which has been added recently (this may or may not help).

### Control over distributed task execution

At the time of writing, `turborepo` support parallelizing task executing in a single process, ut does not yet support distributing tasks across many nodes, which would be useful in CI both to speed us task runs and to make task logs easier to debug when a something fails.

In this POC, we use `monobuild` to generate a build schedule which we then put into a [matrix](https://docs.github.com/en/actions/using-jobs/using-a-matrix-for-your-jobs) so that each app or package gets its own build job as per the image below:

![GitHub actions matrix screenshot](https://file%2B.vscode-resource.vscode-cdn.net/Users/jennifersharps/code/monorepo-examples/docs/github-actions-matrix.png?version%3D1665413554522)

In the above example, you can tell at a glance that the there is a problem with the `apps/hello-world-api`.

Without using the matrix, the build would look like the below image:

![GitHub actions without matrix](https://file%2B.vscode-resource.vscode-cdn.net/var/folders/q8/zqvhsjcx2gd_48hhrk848jgc0000gn/T/TemporaryItems/NSIRD_screencaptureui_xgqfMm/Screenshot%202022-10-10%20at%2015.55.46.png?version%3D1665413763893)

There's no easy way to understand what failed at a glance; we'd have to click through to the logs in order to know what actually went wrong.  This is not ideal.

## Turborepo-specific features

### Build

To build all js apps and packages using turborepo, run the following command:

```bash
pnpm run build
```

This accounts for JS dependencies only.  You will still have to build any non-JS services that your JS apps depend on from the monorepo.

### Develop

To develop all js apps and packages, run the following command:

```bash
pnpm run dev
```

This accounts for JS dependencies only.  You will still have to start any non-JS services that your JS apps depend on from the monorepo.

### Utilities

This repo has some additional tools from the JS ecosystem already setup for you:

- [TypeScript](https://www.typescriptlang.org/) for static type checking
- [ESLint](https://eslint.org/) for code linting
- [Prettier](https://prettier.io) for code formatting

### Remote Caching

Turborepo can use a technique known as [Remote Caching](https://turborepo.org/docs/core-concepts/remote-caching) to share cache artifacts across machines, enabling you to share build caches with your team and CI/CD pipelines.

By default, Turborepo will cache locally. Remote Caching has been enabled with Vercel for this POC. If you don't have an account you can [create one](https://vercel.com/signup), then enter the following commands to set things up locally:

```bash
pnpm dlx turbo login
```

This will authenticate the Turborepo CLI with your [Vercel account](https://vercel.com/docs/concepts/personal-accounts/overview).

Next, you can link your Turborepo to your Remote Cache by running the following command from the root of your turborepo:

```bash
pnpm dlx turbo link
```

## Useful Links

Learn more about the power of Turborepo:

- [Pipelines](https://turborepo.org/docs/core-concepts/pipelines)
- [Caching](https://turborepo.org/docs/core-concepts/caching)
- [Remote Caching](https://turborepo.org/docs/core-concepts/remote-caching)
- [Scoped Tasks](https://turborepo.org/docs/core-concepts/scopes)
- [Configuration Options](https://turborepo.org/docs/reference/configuration)
- [CLI Usage](https://turborepo.org/docs/reference/command-line-reference)
