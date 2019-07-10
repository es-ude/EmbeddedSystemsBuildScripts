load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")
load("@io_tweag_rules_nixpkgs//nixpkgs:nixpkgs.bzl", "nixpkgs_cc_configure", "nixpkgs_git_repository", "nixpkgs_package")

def external_dependencies():
    unity_version = "1100c5d8f0af9f3a68df37e592564535c5de72c6"

    http_archive(
        name = "Unity",
        build_file = "@EmbeddedSystemsBuildScripts//:BUILD.Unity",
        strip_prefix = "Unity-{}".format(unity_version),
        urls = ["https://github.com/ThrowTheSwitch/Unity/archive/{}.tar.gz".format(unity_version)],
    )

    cexception_version = "master"

    http_archive(
        name = "CException",
        build_file = "@EmbeddedSystemsBuildScripts//:BUILD.CException",
        strip_prefix = "CException-{}".format(cexception_version),
        urls = ["https://github.com/ThrowTheSwitch/CException/archive/{}.tar.gz".format(cexception_version)],
    )

    nixpkgs_git_repository(
        name = "nixpkgs",
        revision = "19.03",  # Any tag or commit hash
    )

    nixpkgs_package(
        name = "ruby",
        repositories = {"nixpkgs": "@nixpkgs//:default.nix"},
    )

    nixpkgs_cc_configure(
        repository = "@nixpkgs//:default.nix",
    )

    nixpkgs_package(
        name = "avr-libc",
        attribute_path = "pkgsCross.avr.libcCross",
        build_file_content = """

package(default_visibility = ["//visibility:public"])

filegroup(
    name = "include",
    srcs = glob(["avr/include/**"]),
    visibility = ["//visibility:public"],
)

filegroup(
    name = "lib",
    srcs = glob(["avr/lib/**"]),
    visibility = ["//visibility:public"],
)
        """,
        repository = "@nixpkgs//:default.nix",
    )

    nixpkgs_package(
        name = "avr-binutils",
        attribute_path = "pkgsCross.avr.buildPackages.binutils-unwrapped",
        build_file_content = """
package(default_visibility = ["//visibility:public"])

filegroup(
    name = "include",
    srcs = glob(["avr/include/**"]),
    visibility = ["//visibility:public"],
)

filegroup(
    name = "bin",
    srcs = glob(["avr/bin/**", "bin/**"]),
    visibility = ["//visibility:public"],
)
        """,
        repository = "@nixpkgs//:default.nix",
    )

    nixpkgs_package(
        name = "avr-gcc-unwrapped",
        attribute_path = "pkgsCross.avr.buildPackages.gcc-unwrapped",
        build_file_content = """
package(default_visibility = ["//visibility:public"])

filegroup(
    name = "include",
    srcs = glob(["lib/gcc/avr/*/include*/**"]),
)

filegroup(
    name = "lib",
    srcs = glob(["lib/*.a"]),
)

filegroup(
    name = "bin",
    srcs = glob(["avr/bin/**", "bin/**"]),
)
        """,
        repository = "@nixpkgs//:default.nix",
    )

    nixpkgs_package(
        name = "dfu-programmer",
        repository = "@nixpkgs//:default.nix",
    )

    nixpkgs_package(
        name = "avrdude",
        repository = "@nixpkgs//:default.nix",
    )
