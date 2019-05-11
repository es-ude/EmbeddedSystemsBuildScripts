load("@bazel_tools//tools/build_defs/pkg:pkg.bzl", "pkg_tar")

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
	name = "pkgTpl",
	srcs = glob(["*.tpl"]),
	extension = "tar.gz",
    mode = "0644"
)

pkg_tar(
	name = "pkgExtraTemplates",
	srcs = glob(["**/*.tpl"]),
	extension = "tar.gz",
    mode = "0644",
	strip_prefix = "."
)

pkg_tar(
    name = "pkgBuild",
    srcs = ["BUILD.tpl"],
    extension = "tar.gz",
    mode = "0644",
    remap_paths = {
        "BUILD.tpl": "BUILD",
    },
)

pkg_tar(
	name = "pkg",
	deps = ["pkgBuilds", "pkgBzl", "pkgBuild", "pkgTpl", "pkgExtraTemplates"],
	extension = "tar.gz",
    mode = "0644"
)