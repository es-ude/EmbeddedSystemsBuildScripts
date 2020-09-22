load(
    "//Toolchains:third_party.bzl",
    "add_compiler_option_if_supported",
    "get_cxx_inc_directories",
)
load("//Toolchains/Arm:common_definitions.bzl", "ARM_RESOURCE_PREFIX")

def get_tools(repository_ctx, prefix = ""):
    tools = {
        "gcc": repository_ctx.attr.gcc_tool,
        "ar": repository_ctx.attr.ar_tool,
        "ld": repository_ctx.attr.ld_tool,
        "g++": repository_ctx.attr.cpp_tool,
        "gcov": repository_ctx.attr.gcov_tool,
        "nm": repository_ctx.attr.nm_tool,
        "objdump": repository_ctx.attr.objdump_tool,
        "strip": repository_ctx.attr.strip_tool,
        "size": repository_ctx.attr.size_tool,
        "objcopy": repository_ctx.attr.objcopy_tool,
    }
    for key in tools.keys():
        if tools[key] == "":
            tools[key] = "{}".format(repository_ctx.which(prefix + key))
    return tools

def arm_tools(repository_ctx):
    return get_tools(repository_ctx, "arm-none-eabi-")

def _get_treat_warnings_as_errors_flags(repository_ctx, gcc):
    # below flags are most certainly coding errors
    flags_to_add = [
        "-Werror=null-dereference",
        "-Werror=return-type",
        "-Werror=incompatible-pointer-types",
        "-Werror=int-conversion",
    ]
    supported_flags = []
    for flag in flags_to_add:
        supported_flags.extend(add_compiler_option_if_supported(
            repository_ctx,
            gcc,
            flag,
        ))
    return supported_flags

def create_cc_toolchain_config_rule(repository_ctx, gcc):
    repository_ctx.template(
        "cc_toolchain/cc_toolchain_config.bzl",
        repository_ctx.path(Label(ARM_RESOURCE_PREFIX + ":cc_toolchain/cc_toolchain_config.bzl.tpl")),
        substitutions = {
            "@warnings_as_errors@": "{}".format(_get_treat_warnings_as_errors_flags(repository_ctx, gcc)),
        },
    )

def create_toolchain_definitions(tools, cpus, repository_ctx):
    cc_toolchain_template = """load("@ArmToolchain//cc_toolchain:cc_toolchain_config.bzl",
"cc_toolchain_config")
package(default_visibility = ["//visibility:public"])

filegroup(
    name = "empty",
    srcs = [],
)
    """
    cpu_specific = """
cc_toolchain_config(
    name = "arm_cc_toolchain_config_{cpu}",
    cxx_include_dirs = {cxx_include_dirs},
    host_system_name = "{host_system_name}",
    cpu = "{cpu}",
    target_system_name = "arm-{cpu}",
    tools = {{
        "gcc": "{gcc}",
        "ar": "{ar}",
        "ld": "{ld}",
        "cpp": "{g++}",
        "gcov": "{gcov}",
        "nm": "{nm}",
        "objdump": "{objdump}",
        "strip": "{strip}",
    }},
)

cc_toolchain(
    name = "arm_cc_toolchain_{cpu}",
    all_files = ":empty",
    compiler_files = ":empty",
    dwp_files = ":empty",
    linker_files = ":empty",
    objcopy_files = ":empty",
    strip_files = ":empty",
    toolchain_config = ":arm_cc_toolchain_config_{cpu}",
    toolchain_identifier = "arm-toolchain-{cpu}",
)

toolchain(
    name = "cc-toolchain-arm-{cpu}",
    target_compatible_with = [
        "@ArmToolchain//platforms/cpu:{cpu}",
        "@ArmToolchain//platforms:arm",
    ],
    exec_compatible_with = [
    ],
    toolchain = ":arm_cc_toolchain_{cpu}",
    toolchain_type = "@bazel_tools//tools/cpp:toolchain_type",
)
    """
    for cpu in cpus:
        cc_toolchain_template += cpu_specific.format(
            cpu = cpu,
            cxx_include_dirs = get_cxx_inc_directories(repository_ctx, tools["gcc"]),
            host_system_name = repository_ctx.os.name,
            **tools
        )

    return cc_toolchain_template

def create_cc_toolchain_package(repository_ctx, paths):
    tools = arm_tools(repository_ctx)
    cpu_list = repository_ctx.attr.cpu_list
    repository_ctx.file(
        "cc_toolchain/BUILD.bazel",
        create_toolchain_definitions(
            tools,
            cpu_list,
            repository_ctx,
        ),
    )
    cc_toolchain_rule_template = paths[ARM_RESOURCE_PREFIX + ":cc_toolchain/cc_toolchain_config.bzl.tpl"]
    create_cc_toolchain_config_rule(repository_ctx, tools["gcc"])
