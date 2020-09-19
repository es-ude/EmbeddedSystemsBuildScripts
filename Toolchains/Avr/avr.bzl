load(
    "@bazel_tools//tools/cpp:lib_cc_configure.bzl",
    "resolve_labels",
)
load(
    "//Toolchains/Avr:cc_toolchain/cc_toolchain.bzl",
    "avr_tools",
    "create_cc_toolchain_package",
)
load(
    "//Toolchains/Avr:platforms/platforms.bzl",
    "write_constraints",
)
load(
    "//Toolchains/Avr:platforms/platform_list.bzl",
    "platforms",
)

def _avr_toolchain_impl(repository_ctx):
    prefix = "@EmbeddedSystemsBuildScripts//Toolchains/Avr:"
    tools = avr_tools(repository_ctx)
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
        ]],
    )
    write_constraints(repository_ctx, paths)
    create_cc_toolchain_package(repository_ctx, paths)
    repository_ctx.template(
        "helpers.bzl",
        paths["@EmbeddedSystemsBuildScripts//Toolchains/Avr:helpers.bzl.tpl"],
        substitutions = {
            "{avr_objcopy}": tools["objcopy"],
            "{avr_size}": tools["size"],
        },
    )
    repository_ctx.file("BUILD")
    repository_ctx.template("host_config/BUILD", paths["@EmbeddedSystemsBuildScripts//Toolchains/Avr:host_config/BUILD.tpl"])
    repository_ctx.template(
        "platforms/platform_list.bzl",
        paths["@EmbeddedSystemsBuildScripts//Toolchains/Avr:platforms/platform_list.bzl"],
    )
    repository_ctx.template(
        "platforms/mcu/mcu.bzl",
        paths["@EmbeddedSystemsBuildScripts//Toolchains/Avr:platforms/mcu/mcu.bzl"],
    )
    repository_ctx.template(
        "BUILD",
        paths["@EmbeddedSystemsBuildScripts//Toolchains/Avr:BUILD.tpl"],
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
