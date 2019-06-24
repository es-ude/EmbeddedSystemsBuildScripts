load("@bazel_tools//tools/build_defs/pkg:pkg.bzl", "pkg_tar")

pkg_tar(
    name = "pkg",
    srcs = glob(["BUILD*"]),
    extension = "tar.gz",
    mode = "0644",
    deps = [
        "//Unity:pkg",
        "//AvrToolchain:pkg"
    ]
)
