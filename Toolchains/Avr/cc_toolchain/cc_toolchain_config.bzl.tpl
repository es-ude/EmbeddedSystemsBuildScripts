load(
    "@bazel_tools//tools/cpp:cc_toolchain_config_lib.bzl",
    "feature",
    "feature_set",
    "flag_group",
    "flag_set",
    "tool_path",
    "with_feature_set",
    "make_variable",
)
load("@bazel_tools//tools/build_defs/cc:action_names.bzl", "ACTION_NAMES")

__CODE_SIZE_OPTIMIZATION_COPTS = [
    "-Os",
    "-s",
    "-fno-asynchronous-unwind-tables",
    "-fno-inline-small-functions",
    "-fno-strict-aliasing",
    "-funsigned-char",
    "-gdwarf-2",
    "-g2",
    "-funsigned-bitfields",
    "-fpack-struct",
    "-fno-strict-aliasing",
    "-funsigned-char",
    "-funsigned-bitfields",
    "-ffast-math",
    "-fmerge-all-constants",
    "-fmerge-all-constants",
    "-fdata-sections",
    "-ffunction-sections",
    "-fshort-enums",
    "-fno-jump-tables",
    "-Xlinker",
    "--gc-sections",
    "-Xlinker",
    "--relax",
    "-mrelax",
]

__CEXCEPTION_FLAGS = [
    "-include",
    "stdint.h",
    "-DCEXCEPTION_T=uint8_t",
    "-DCEXCEPTION_NONE=0x00",
]

def new_feature(name, flags, enabled = False):
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
    result = feature(
        name = name,
        enabled = enabled,
        flag_sets = [
            flag_set(
                actions = ALL_ACTIONS,
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
    opt_feature = new_feature("opt", __CODE_SIZE_OPTIMIZATION_COPTS)
    fastbuild_feature = new_feature("fastbuild", ["-Os"])
    c99_feature = new_feature("gnu99", ["-std=gnu99"], True)
    convert_warnings_to_errors = new_feature("treat_warnings_as_errors", @warnings_as_errors@)
    features = [opt_feature, fastbuild_feature, c99_feature, convert_warnings_to_errors]
    if ctx.attr.mcu != "none":
        features.append(new_feature("mcu", ["-mmcu=" + ctx.attr.mcu], True))
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
        cxx_builtin_include_directories = ctx.attr.cxx_include_dirs,
        features = features,
        make_variables = [make_variable("MCU", ctx.attr.mcu)]
    ),
    platform_common.TemplateVariableInfo({'MCU': ctx.attr.mcu})
    ]

cc_toolchain_config = rule(
    implementation = _impl,
    attrs = {
        "host_system_name": attr.string(),
        "target_system_name": attr.string(default = "avr"),
        "mcu": attr.string(default = "none"),
        "toolchain_identifier": attr.string(default = "avr-toolchain"),
        "target_cpu": attr.string(default = "avr"),
        "target_libc": attr.string(default = "unknown"),
        "abi_version": attr.string(default = "unknown"),
        "tools": attr.string_dict(),
        "cxx_include_dirs": attr.string_list(),
    },
    provides = [CcToolchainConfigInfo, platform_common.TemplateVariableInfo],
)
