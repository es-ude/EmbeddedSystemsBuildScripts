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
    tools = {
        "gcc": ctx.file._gcc.basename,
        "cpp": ctx.file._cpp.basename,
        "nm": "/bin/false",
        "size": "/bin/false",
        "ld": ctx.file._ld.basename,
        "gcov": "/bin/false",
        "objcopy": "/bin/false",
        "objdump": "/bin/false",
        "ar": "/bin/false",
        "ranlib": "/bin/false",
        "strip": "/bin/false",
    }

    tool_paths = [
        tool_path(
            name = key,
            path = ctx.file._gcc.basename,
        )
        for key in tools
    ]
    opt_feature = new_feature("opt", __CODE_SIZE_OPTIMIZATION_COPTS)
    fastbuild_feature = new_feature("fastbuild", ["-O2"])
    c99_feature = new_feature("gnu99", ["-std=gnu99"], True)
    nostdinc_feature = new_feature("nostdinc", [
        "-nostdinc",
        "-isystem",
        "external/avr-gcc-unwrapped/lib/gcc/avr/7.4.0/include",
        "-isystem",
        "external/avr-gcc-unwrapped/lib/gcc/avr/7.4.0/include-fixed",
        "-isystem",
        "external/avr-libc/avr/include",
        "-B",
        "external/avr-libc/avr/lib",
    ], True)

    features = [opt_feature, fastbuild_feature, c99_feature, nostdinc_feature]
    if ctx.attr.mcu != "none":
        features.append(new_feature("mcu", ["-mmcu=" + ctx.attr.mcu], True))
    return [
        cc_common.create_cc_toolchain_config_info(
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
            cxx_builtin_include_directories = [],
            features = features,
            make_variables = [make_variable("MCU", ctx.attr.mcu)],
        ),
        platform_common.TemplateVariableInfo({"MCU": ctx.attr.mcu}),
    ]

#McuProvider = provider(fields = ["mcu"])
#
#def _mcu_impl(ctx):
#    return McuProvider(mcu = ctx.build_setting_value)
#
#mcu = rule(
#    implementation = _mcu_impl,
#    build_setting = config.string(flag = True),
#)

cc_toolchain_config = rule(
    implementation = _impl,
    attrs = {
        "host_system_name": attr.string(),
        "target_system_name": attr.string(default = "avr"),
        "mcu": attr.string(mandatory = True),
        "toolchain_identifier": attr.string(default = "avr-toolchain"),
        "target_cpu": attr.string(default = "avr"),
        "target_libc": attr.string(default = "unknown"),
        "abi_version": attr.string(default = "unknown"),
        "_gcc": attr.label(allow_single_file = True, default = "//example:avr-gcc.sh"),
        "_cpp": attr.label(allow_single_file = True, default = "//example:avr-gcc.sh"),
        "_ld": attr.label(allow_single_file = True, default = "//example:avr-gcc.sh"),
    },
    provides = [CcToolchainConfigInfo, platform_common.TemplateVariableInfo],
)
