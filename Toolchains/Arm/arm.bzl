load(
    "@bazel_tools//tools/cpp:lib_cc_configure.bzl",
    "resolve_labels",
)
load(
    "//Toolchains/Arm:cc_toolchain/cc_toolchain.bzl",
    "create_cc_toolchain_package",
)
load(
    "//Toolchains/Arm:platforms/platforms.bzl",
    "write_constraints",
)
load(
    "//Toolchains/Arm:platforms/platform_list.bzl",
    "platforms",
)
load("//Toolchains:tools.bzl", "get_tools")
load("//Toolchains:third_party.bzl", "get_cxx_inc_directories")
load("//Toolchains/Arm:common_definitions.bzl", "ARM_RESOURCE_PREFIX")

def _arm_toolchain_impl(repository_ctx):
    tools = get_tools(repository_ctx, "arm-none-eabi-")
    cxx_include_paths = get_cxx_inc_directories(repository_ctx, tools["gcc"])
    prefix = ARM_RESOURCE_PREFIX + ":"
    paths = resolve_labels(repository_ctx, [
        prefix + "cc_toolchain/cc_toolchain_config.bzl.tpl",
        prefix + "BUILD.bazel.tpl",
        prefix + "platforms/BUILD.bazel.tpl",
        prefix + "platforms/cpu/cpu.bzl",
        prefix + "platforms/platform_list.bzl",
        prefix + "helpers.bzl.tpl",
    ])
    write_constraints(repository_ctx, paths)
    create_cc_toolchain_package(repository_ctx, paths)
    repository_ctx.file("BUILD.bazel")
    repository_ctx.template(
        "platforms/BUILD.bazel",
        paths[ARM_RESOURCE_PREFIX + ":platforms/BUILD.bazel.tpl"],
    )
    repository_ctx.template(
        "helpers.bzl",
        paths[ARM_RESOURCE_PREFIX + ":helpers.bzl.tpl"],
        substitutions = {
            "{arm_objcopy}": tools["objcopy"],
        },
    )
    repository_ctx.template(
        "platforms/cpu/cpu.bzl",
        paths[ARM_RESOURCE_PREFIX + ":platforms/cpu/cpu.bzl"],
    )
    repository_ctx.template(
        "platforms/platform_list.bzl",
        paths[ARM_RESOURCE_PREFIX + ":platforms/platform_list.bzl"],
    )

_get_arm_toolchain_def_attrs = {
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
    "optimize_flags": attr.string_list(),
    "cpu_flag": attr.string(),
    "cpu_list": attr.string_list(mandatory = True),
}

create_arm_toolchain = repository_rule(
    implementation = _arm_toolchain_impl,
    attrs = _get_arm_toolchain_def_attrs,
)

def arm_toolchain():
    create_arm_toolchain(
        name = "ArmToolchain",
        cpu_list = platforms,
    )
    for cpu in platforms:
        native.register_toolchains(
            "@ArmToolchain//cc_toolchain:cc-toolchain-arm-" + cpu,
        )
