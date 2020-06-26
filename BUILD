load("@bazel_tools//tools/build_defs/pkg:pkg.bzl", "pkg_tar")
load(":docs.bzl", "sphinx_archive")

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

sphinx_archive(
    name = "sphinx",
    srcs = [
        "docs/AvrToolchain.rst",
        "docs/BazelSetup.rst",
        "docs/index.rst",
    ],
    copyright = "2019, Embedded Systems Department University Duisburg Essen",
    doxygen_xml_archive = None,
    master_doc = "docs/index",
    source_suffix = [".rst"],
    version = "v0.6.1",
)
