workspace(
    name = "EmbeddedSystemsBuildScripts",
)

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")
load("//AvrToolchain:avr.bzl", "avr_toolchain")

avr_toolchain()

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

nixpkgs_rules_version = "61f838ad6bf8a650b0ed3d97f35b46e717ced417"

http_archive(
    name = "io_tweag_rules_nixpkgs",
    strip_prefix = "rules_nixpkgs-{}".format(nixpkgs_rules_version),
    urls = ["https://github.com/tweag/rules_nixpkgs/archive/{}.tar.gz".format(nixpkgs_rules_version)],
)

load("@io_tweag_rules_nixpkgs//nixpkgs:nixpkgs.bzl", "nixpkgs_cc_configure", "nixpkgs_git_repository", "nixpkgs_package")

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
    name = "avr-gcc",
    attribute_path = "pkgsCross.avr.buildPackages.gcc",
    repository = "@nixpkgs//:default.nix",
)

nixpkgs_package(
    name = "avr-binutils",
    attribute_path = "pkgsCross.avr.buildPackages.binutils",
    repository = "@nixpkgs//:default.nix",
)

nixpkgs_pacakge(
    name = "dfu-programmer",
    repository = "@nixpkgs//:default.nix",
)
