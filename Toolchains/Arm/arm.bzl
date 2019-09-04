load("//Toolchains:tools.bzl", "get_tools")
load("//Toolchains:third_party.bzl", "get_cxx_inc_directories")
load(
    "@bazel_tools//tools/cpp:lib_cc_configure.bzl",
    "resolve_labels",
)

ARM_RESOURCE_PREFIX = "@EmbeddedSystemsBuildScripts//Toolchains/Arm"

def _impl(repository_ctx):
    tools = get_tools(repository_ctx, "arm-none-eabi-")
    cxx_include_paths = get_cxx_inc_directories(repository_ctx, tools["gcc"])
    prefix = ARM_RESOURCE_PREFIX + ":"
    paths = resolve_labels(repository_ctx, [
        prefix + "BUILD.bazel.tpl",
        prefix + "cc_toolchain_config.bzl",
        prefix + "platforms/BUILD.bazel.tpl"
    ])
    repository_ctx.template(
        "cc_toolchain/BUILD.bazel",
        paths[prefix + "BUILD.bazel.tpl"],
        substitutions = {
            "@cxx_include_directories@": "{}".format(cxx_include_paths),
            "@gcc@": tools["gcc"],
            "@g++@": tools["g++"],
            "@objcopy@": tools["objcopy"],
            "@nm@": tools["nm"],
            "@strip@": tools["strip"],
            "@objdump@": tools["objdump"],
            "@gcov@": tools["gcov"],
            "@ld@": tools["ld"],
            "@ar@": tools["ar"],
            "@size@": tools["size"],
        },
    )
    repository_ctx.template(
        "cc_toolchain/cc_toolchain_config.bzl",
        paths[prefix + "cc_toolchain_config.bzl"],
    )
    repository_ctx.template(
        "platforms/BUILD.bazel",
        paths[prefix + "platforms/BUILD.bazel.tpl"],
    )

_attributes = {
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
}

create_arm_toolchain = repository_rule(
    implementation = _impl,
    attrs = _attributes,
)

def arm_toolchain():
    create_arm_toolchain(
        name = "ArmToolchain",
    )
    native.register_toolchains("@ArmToolchain//cc_toolchain:cc-toolchain-arm-eabi-cortex-m0")
