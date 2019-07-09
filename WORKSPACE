workspace(
    name = "EmbeddedSystemsBuildScripts",
)

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")
load("//AvrToolchain:avr.bzl", "create_avr_toolchain")
load("//AvrToolchain:platforms/platform_list.bzl", "platforms")

create_avr_toolchain(
    name = "AvrToolchain",
    mcu_list = platforms,
)

register_toolchains("//example:cc-toolchain-avr-atmega32u4")

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
    srcs = glob(["avr/include/**"]),
)

filegroup(
    name = "lib",
    srcs = glob(["lib/**"]),
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

skylib_version = "0.8.0"

http_archive(
    name = "bazel_skylib",
    sha256 = "2ef429f5d7ce7111263289644d233707dba35e39696377ebab8b0bc701f7818e",
    type = "tar.gz",
    url = "https://github.com/bazelbuild/bazel-skylib/releases/download/{}/bazel-skylib.{}.tar.gz".format(skylib_version, skylib_version),
)
