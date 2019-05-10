load("@bazel_tools//tools/build_defs/pkg:pkg.bzl", "pkg_tar", "pkg_deb")

pkg_tar(
	name = "pkgBuilds",
	srcs = glob(["BUILD.*"]),
	extension = "tar.gz",
    mode = "0644"
)

pkg_tar(
	name = "pkgBzl",
	srcs = glob(["*.bzl"]),
	extension = "tar.gz",
    mode = "0644"
)

pkg_tar(
	name = "pkg",
	deps = ["pkgBuilds", "pkgBzl"],
	extension = "tar.gz",
    mode = "0644"
)