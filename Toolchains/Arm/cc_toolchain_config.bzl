load(
    "@bazel_tools//tools/cpp:cc_toolchain_config_lib.bzl",
    "feature",
    "feature_set",
    "flag_group",
    "flag_set",
    "make_variable",
    "tool_path",
    "with_feature_set",
)
load("@bazel_tools//tools/build_defs/cc:action_names.bzl", "ACTION_NAMES")

def new_feature(name, flags, enabled = False, actions = []):
    ALL_ACTIONS = [
        ACTION_NAMES.assemble,
        ACTION_NAMES.preprocess_assemble,
        ACTION_NAMES.linkstamp_compile,
        ACTION_NAMES.c_compile,
        ACTION_NAMES.cpp_compile,
        ACTION_NAMES.cpp_header_parsing,
        ACTION_NAMES.cpp_module_compile,
        ACTION_NAMES.cpp_module_codegen,
        ACTION_NAMES.lto_backend,
        ACTION_NAMES.clif_match,
        ACTION_NAMES.cpp_link_executable,
    ]
    if len(actions) == 0:
        actions = ALL_ACTIONS
    result = feature(
        name = name,
        enabled = enabled,
        flag_sets = [
            flag_set(
                actions = actions,
                flag_groups = [
                    flag_group(
                        flags = flags,
                    ),
                ],
            ),
        ],
    )
    return result

def _impl(ctx):
    tools = ctx.attr.tools

    tool_paths = [
        tool_path(
            name = key,
            path = tools[key],
        )
        for key in tools
    ]
    features = [
        new_feature("architecture", enabled = True, flags = ["-mcpu=" + ctx.attr.target_cpu]),
        #        new_feature("temporary_flags", enabled = True, flags = ["-DUSE_HAL_DRIVER", "-std=gnu11", "-g3", "-O0", "-mfloat-abi=soft", "-mthumb", "--specs=nano.specs", "-Wall", "-fmessage-length=0", "-fno-builtin", "-ffunction-sections", "-fdata-sections", "-fsingle-precision-constant"]),
        new_feature("arm_flags", enabled = True, flags = ["-D__REDLIB__", "-DDEBUG", "-D__USE_LPCOPEN", "-DCORE_M4", "-DNO_BOARD_LIB", "-D__LPC407X_8X__", "-O0", "-g3", "-Wall", "-fmessage-length=0", "-fno-builtin", "-ffunction-sections", "-fdata-sections", "-fsingle-precision-constant", "-mcpu=cortex-m4", "-mfpu=fpv4-sp-d16", "-mfloat-abi=softfp", "-mthumb", "-fstack-usage", "-MMD", "-MP", "-std=gnu99", "-Wall", "-g3"]),
        new_feature("hardcoded_linker_flags", enabled = True, flags = ["-mcpu=cortex-m4 -mfpu=fpv4-sp-d16", "-mfloat-abi=softfp -mthumb", "-Wl,--gc-sections", "-Wl,--cref", "-Wl,--print-memory-usage"], actions = [ACTION_NAMES.cpp_link_executable]),
    ]

    return [cc_common.create_cc_toolchain_config_info(
        ctx = ctx,
        toolchain_identifier = ctx.attr.toolchain_identifier,
        host_system_name = ctx.attr.host_system_name,
        target_system_name = ctx.attr.target_system_name,
        target_cpu = ctx.attr.target_cpu,
        target_libc = ctx.attr.target_libc,
        abi_version = ctx.attr.abi_version,
        compiler = "cc",
        abi_libc_version = "unknown",
        tool_paths = tool_paths,
        features = features,
        cxx_builtin_include_directories = ctx.attr.cxx_include_dirs,
    )]

cc_toolchain_config = rule(
    implementation = _impl,
    attrs = {
        "host_system_name": attr.string(),
        "target_system_name": attr.string(default = "k8"),
        "toolchain_identifier": attr.string(default = "arm-toolchain"),
        "target_cpu": attr.string(),
        "target_libc": attr.string(default = "nano"),
        "abi_version": attr.string(default = "unknown"),
        "tools": attr.string_dict(),
        "cxx_include_dirs": attr.string_list(),
    },
    provides = [CcToolchainConfigInfo],
)
