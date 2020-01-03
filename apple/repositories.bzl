# Copyright 2020-present The Material Foundation Authors. All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

"""Definitions for handling Bazel repositories used by the Apple rules."""

load("@bazel_tools//tools/build_defs/repo:git.bzl", "git_repository")
load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive", "http_file")


def _maybe(repo_rule, name, **kwargs):
    """Executes the given repository rule if it hasn't been executed already.
    Args:
      repo_rule: The repository rule to be executed (e.g.,
          `http_archive`.)
      name: The name of the repository to be defined by the rule.
      **kwargs: Additional arguments passed directly to the repository rule.
    """
    if not native.existing_rule(name):
        repo_rule(name = name, **kwargs)


# Note: originally sourced and simplified from https://github.com/bazelbuild/rules_swift/blob/46d309a56e638830a9844e65d5531262a8afab99/swift/internal/swift_autoconfiguration.bzl#L171-L249
# We can't use the rules_swift _swift_configuration_impl here because doing so would require having
# already loaded the rules_swift repo and we can't run load statements from within the
# apple_workspace_dependencies.
# Only macOS support is included here because we do not currently need to support linux Swift
# builds in any manner.
def _swift_configuration_impl(repository_ctx):
    path_to_swiftc = repository_ctx.which("swiftc")

    repository_ctx.file(
        "BUILD",
        """
load(
    "@build_bazel_rules_swift//swift/internal:xcode_swift_toolchain.bzl",
    "xcode_swift_toolchain",
)
package(default_visibility = ["//visibility:public"])
xcode_swift_toolchain(
    name = "toolchain",
)
""",
    )


def apple_workspace_dependencies():
    """Fetches repositories that are dependencies of the `bazel_workspace_apple` workspace.
    Users should call this macro in their `WORKSPACE` to ensure that all of the
    dependencies of the Apple rules are downloaded and that they are isolated from
    changes to those dependencies.
    """
    _maybe(
        git_repository,
        name = "build_bazel_rules_apple",
        remote = "https://github.com/bazelbuild/rules_apple.git",
        commit = "96212456d3cd7be9760fe28c077673bb85d46500",  # Dec 18, 2019
        shallow_since = "1576719323 -0800",  # Recommended by bazel.
    )

    _maybe(
        git_repository,
        name = "build_bazel_rules_swift",
        remote = "https://github.com/bazelbuild/rules_swift.git",
        commit = "d7757c5ee9724df9454edefa3b4455a401a2ae22",  # Dec 19, 2019
        shallow_since = "1576775454 -0800",  # Recommended by bazel.
    )

    _maybe(
        git_repository,
        name = "build_bazel_apple_support",
        remote = "https://github.com/bazelbuild/apple_support.git",
        commit = "9605c3da1c5bcdddc20d1704b52415a6f3a5f422",  # Oct 11, 2019
        shallow_since = "1570831694 -0700",  # Recommended by bazel.
    )

    _maybe(
        http_archive,
        name = "bazel_skylib",
        urls = [
          "https://mirror.bazel.build/github.com/bazelbuild/bazel-skylib/releases/download/1.0.2/bazel-skylib-1.0.2.tar.gz",
          "https://github.com/bazelbuild/bazel-skylib/releases/download/1.0.2/bazel-skylib-1.0.2.tar.gz",
        ],
        sha256 = "97e70364e9249702246c0e9444bccdc4b847bed1eb03c5a3ece4f83dfe6abc44",
    )

    # TODO(https://github.com/material-foundation/bazel-workspace-apple/issues/2): Point to google/xctestrunner
    _maybe(
        http_file,
        name = "xctestrunner",
        executable = 1,
        urls = [
            "https://github.com/jverkoey/xctestrunner/releases/download/0.2.11/ios_test_runner.par",
        ],
        sha256 = "a0a8be06b14f787f6017474b1ed33068c616b5b1154cf16e2e7ac3e7f047fd8c",
    )

    _maybe(
        git_repository,
        name = "bazel_ios_warnings",
        remote = "https://github.com/material-foundation/bazel_ios_warnings.git",
        commit = "c3f720c0838af1ee53299aa6efda87cf729146b4",  # v3.0.0
        shallow_since = "1545400728 -0500",  # Recommended by bazel.
    )

    _maybe(
        git_repository,
        name = "bazel_test_host_apple",
        remote = "https://github.com/material-foundation/bazel-test-host-apple.git",
        commit = "eb3a82f16bd308713ff71748717f3486143e7768",
        shallow_since = "1577990930 -0500"  # Recommended by bazel.
    )

    _maybe(
        git_repository,
        name = "bazel_apple_framework_relative_headers",
        remote = "https://github.com/material-foundation/bazel-apple-framework-relative-headers.git",
        commit = "10d47c5cddcdddddb8d64e2c9141d8052cea9d4a",
        shallow_since = "1578061035 -0500",  # Recommended by bazel.
    )

    _maybe(
        http_archive,
        name = "com_github_nlohmann_json",
        urls = [
            "https://github.com/nlohmann/json/releases/download/v3.7.3/include.zip",
        ],
        sha256 = "87b5884741427220d3a33df1363ae0e8b898099fbc59f1c451113f6732891014",
        type = "zip",
        build_file = "@build_bazel_rules_swift//third_party:com_github_nlohmann_json/BUILD.overlay",
    )

    _maybe(
        http_archive,
        name = "com_google_protobuf",
        # v3.11.2, latest as of 2019-12-19
        urls = [
            "https://github.com/protocolbuffers/protobuf/archive/v3.11.2.zip",
        ],
        sha256 = "e4f8bedb19a93d0dccc359a126f51158282e0b24d92e0cad9c76a9699698268d",
        strip_prefix = "protobuf-3.11.2",
        type = "zip",
    )

    # This override of the zlib package resolves the following error:
    # "no such package '@zlib//': The repository '@zlib' could not be resolved"
    # Additional context available at: https://github.com/bazelbuild/bazel/issues/10270
    _maybe(
        http_archive,
        name = "zlib",
        build_file = "@com_google_protobuf//:third_party/zlib.BUILD",
        sha256 = "c3e5e9fdd5004dcb542feda5ee4f0ff0744628baf8ed2dd5d66f8ca1197cb1a1",
        strip_prefix = "zlib-1.2.11",
        urls = [
            "https://mirror.bazel.build/zlib.net/zlib-1.2.11.tar.gz",
            "https://zlib.net/zlib-1.2.11.tar.gz",
        ],
    )

    # This override resolves the following error:
    # "error loading package '@com_google_protobuf//': Unable to find package for @rules_python//python:defs.bzl: The repository '@rules_python' could not be resolved"
    _maybe(
        http_archive,
        name = "rules_python",
        sha256 = "c911dc70f62f507f3a361cbc21d6e0d502b91254382255309bc60b7a0f48de28",
        strip_prefix = "rules_python-38f86fb55b698c51e8510c807489c9f4e047480e",
        urls = ["https://github.com/bazelbuild/rules_python/archive/38f86fb55b698c51e8510c807489c9f4e047480e.tar.gz"],
    )

    swift_configuration = repository_rule(
        environ = ["CC", "PATH"],
        implementation = _swift_configuration_impl,
    )

    swift_configuration(name = "build_bazel_rules_swift_local_config")
