# Bazel workspace for Apple targets

This repo contains the [Bazel](http://bazel.build/) dependencies used by the Material iOS team for
all repositories they own that support Bazel for Apple builds. The purpose of this library is to
enable `WORKSPACE` files in Material iOS libraries to be consistent with one another. This repo is,
in effect, the single source of truth of common `WORKSPACE` dependencies for the Material iOS team.

The provided `apple_workspace_dependencies` method will add all common dependencies used for Apple
development, including (but not necessarily limited to):

- https://github.com/bazelbuild/rules_apple.git
- https://github.com/bazelbuild/rules_swift.git
- https://github.com/bazelbuild/apple_support.git
- https://github.com/bazelbuild/bazel-skylib
- https://github.com/google/xctestrunner
- https://github.com/material-foundation/bazel_ios_warnings
- https://github.com/material-foundation/bazel-test-host-apple

All dependencies of these libraries are included as well so that only
`apple_workspace_dependencies()` needs to be loaded and invoked in each repo's `WORKSPACE`.

## Usage

```
load("@bazel_tools//tools/build_defs/repo:git.bzl", "git_repository")

git_repository(
    name = "bazel_workspace_apple",
    remote = "https://github.com/material-foundation/bazel-workspace-apple.git",
    commit = "<# a SHA from this repo #>",
)

load("@bazel_workspace_apple//apple:repositories.bzl", "apple_workspace_dependencies")
apple_workspace_dependencies()
```

## License

Licensed under the Apache 2.0 license. See LICENSE for details.
