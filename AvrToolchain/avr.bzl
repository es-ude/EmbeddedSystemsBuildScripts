load("@bazel_tools//tools/build_defs/repo:utils.bzl", "workspace_and_buildfile")
load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")
load(
    "@bazel_tools//tools/cpp:lib_cc_configure.bzl",
    "auto_configure_fail",
    "auto_configure_warning",
    "escape_string",
    "get_env_var",
    "get_starlark_list",
    "resolve_labels",
    "split_escaped",
    "which",
)
load(
    "//AvrToolchain:cc_toolchain/cc_toolchain.bzl",
    "create_cc_toolchain_package",
)
load(
    "//AvrToolchain:platforms/platforms.bzl",
    "write_constraints",
)
load(
    "//AvrToolchain:platforms/platform_list.bzl",
    "platforms",
)
load("@io_tweag_rules_nixpkgs//nixpkgs:nixpkgs.bzl", "nixpkgs_cc_configure", "nixpkgs_git_repository", "nixpkgs_package")

def _avr_toolchain_impl(repository_ctx):
    prefix = "@EmbeddedSystemsBuildScripts//AvrToolchain:"
    paths = resolve_labels(
        repository_ctx,
        [prefix + label for label in [
            "cc_toolchain/cc_toolchain_config.bzl.tpl",
            "platforms/cpu_frequency/cpu_frequency.bzl.tpl",
            "platforms/misc/BUILD.tpl",
            "platforms/BUILD.tpl",
            "helpers.bzl.tpl",
            "host_config/BUILD.tpl",
            "platforms/platform_list.bzl",
            "platforms/mcu/mcu.bzl",
            "BUILD.tpl",
            "cc_toolchain/avr-gcc.sh",
        ]],
    )
    write_constraints(repository_ctx, paths)
    create_cc_toolchain_package(repository_ctx, paths)
    repository_ctx.template(
        "helpers.bzl",
        paths["@EmbeddedSystemsBuildScripts//AvrToolchain:helpers.bzl.tpl"],
    )
    repository_ctx.file("BUILD")
    repository_ctx.template("host_config/BUILD", paths["@EmbeddedSystemsBuildScripts//AvrToolchain:host_config/BUILD.tpl"])
    repository_ctx.template(
        "platforms/platform_list.bzl",
        paths["@EmbeddedSystemsBuildScripts//AvrToolchain:platforms/platform_list.bzl"],
    )
    repository_ctx.template(
        "platforms/mcu/mcu.bzl",
        paths["@EmbeddedSystemsBuildScripts//AvrToolchain:platforms/mcu/mcu.bzl"],
    )
    repository_ctx.template(
        "BUILD",
        paths["@EmbeddedSystemsBuildScripts//AvrToolchain:BUILD.tpl"],
    )

_get_avr_toolchain_def_attrs = {
    "gcc_tool": attr.string(),
    "size_tool": attr.string(),
    "ar_tool": attr.string(),
    "ld_tool": attr.string(),
    "cpp_tool": attr.string(),
    "gcov_tool": attr.string(),
    "nm_tool": attr.string(),
    "objdump_tool": attr.string(),
    "strip_tool": attr.string(),
    "objcopy_tool": attr.string(),
    "mcu_list": attr.string_list(mandatory = True),
}

create_avr_toolchain = repository_rule(
    implementation = _avr_toolchain_impl,
    attrs = _get_avr_toolchain_def_attrs,
    doc = """
Creates an avr toolchain repository. The repository
will contain toolchain definitions and constraints
to allow compilation for avr platforms using the avr-gcc
compiler. The compiler itself has to be provided by the
operating system and discoverable through the PATH variable.
Additionally avr-binutils and avr-libc should be installed.
    """,
)

def avr_toolchain():
    create_avr_toolchain(
        name = "AvrToolchain",
        mcu_list = platforms,
    )
    for mcu in platforms:
        native.register_toolchains(
            "@AvrToolchain//cc_toolchain:cc-toolchain-avr-" + mcu,
        )

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
