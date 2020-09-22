load(
    "//Toolchains/Avr:cc_toolchain/third_party.bzl",
    "add_compiler_option_if_supported",
    "get_cxx_inc_directories",
)

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

def avr_tools(repository_ctx):
    return get_tools(repository_ctx, "avr-")

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
        repository_ctx.path(Label("@EmbeddedSystemsBuildScripts//Toolchains/Avr:cc_toolchain/cc_toolchain_config.bzl.tpl")),
        substitutions = {
            "@warnings_as_errors@": "{}".format(_get_treat_warnings_as_errors_flags(repository_ctx, gcc)),
        },
    )

def create_toolchain_definitions(tools, mcus, repository_ctx):
    cc_toolchain_template = """load("@AvrToolchain//cc_toolchain:cc_toolchain_config.bzl",
"cc_toolchain_config")
package(default_visibility = ["//visibility:public"])

filegroup(
    name = "empty",
    srcs = [],
)
    """
    mcu_specific = """
cc_toolchain_config(
    name = "avr_cc_toolchain_config_{mcu}",
    cxx_include_dirs = {cxx_include_dirs},
    host_system_name = "{host_system_name}",
    mcu = "{mcu}",
    target_system_name = "avr-{mcu}",
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
    name = "avr_cc_toolchain_{mcu}",
    all_files = ":empty",
    compiler_files = ":empty",
    dwp_files = ":empty",
    linker_files = ":empty",
    objcopy_files = ":empty",
    strip_files = ":empty",
    toolchain_config = ":avr_cc_toolchain_config_{mcu}",
    toolchain_identifier = "avr-toolchain-{mcu}",
)

toolchain(
    name = "cc-toolchain-avr-{mcu}",
    target_compatible_with = [
        "@AvrToolchain//platforms/mcu:{mcu}",
        "@AvrToolchain//platforms:avr",
    ],
    exec_compatible_with = [
    ],
    toolchain = ":avr_cc_toolchain_{mcu}",
    toolchain_type = "@bazel_tools//tools/cpp:toolchain_type",
)
    """
    for mcu in mcus:
        cc_toolchain_template += mcu_specific.format(
            mcu = mcu,
            cxx_include_dirs = get_cxx_inc_directories(repository_ctx, tools["gcc"]),
            host_system_name = repository_ctx.os.name,
            **tools
        )

    return cc_toolchain_template

def create_cc_toolchain_package(repository_ctx, paths):
    tools = avr_tools(repository_ctx)
    check_for_missing_tools(tools)
    mcu_list = repository_ctx.attr.mcu_list
    repository_ctx.file(
        "cc_toolchain/BUILD",
        create_toolchain_definitions(
            tools,
            mcu_list,
            repository_ctx,
        ),
    )
    cc_toolchain_rule_template = paths["@EmbeddedSystemsBuildScripts//Toolchains/Avr:cc_toolchain/cc_toolchain_config.bzl.tpl"]
    create_cc_toolchain_config_rule(repository_ctx, tools["gcc"])

def check_for_missing_tools(tools):
    for key in tools.keys():
        if "None" in tools[key]:
            fail("Unable to find the avr-%s toolchain, make sure avr-gcc and avr-binutils are installed and accecable from your path environment" % key)
