workspace(
    name = "EmbeddedSystemsBuildScripts",
)

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

nixpkgs_rules_version = "61f838ad6bf8a650b0ed3d97f35b46e717ced417"

http_archive(
    name = "io_tweag_rules_nixpkgs",
    strip_prefix = "rules_nixpkgs-{}".format(nixpkgs_rules_version),
    urls = ["https://github.com/tweag/rules_nixpkgs/archive/{}.tar.gz".format(nixpkgs_rules_version)],
)

load("//AvrToolchain:avr.bzl", "avr_toolchain", "create_avr_toolchain")

avr_toolchain()
