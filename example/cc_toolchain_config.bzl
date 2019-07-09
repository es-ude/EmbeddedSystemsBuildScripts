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
load("//example:third_party.bzl", "get_cxx_inc_directories")
load("@bazel_skylib//lib:paths.bzl", "paths")

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
        "gcc": ctx.attr._gcc,
        "cpp": ctx.attr._cpp,
        "nm": ctx.attr._nm,
        "size": ctx.attr._size,
        "ld": ctx.attr._ld,
        "gcov": ctx.attr._gcov,
        "objcopy": ctx.attr._objcopy,
        "objdump": ctx.attr._objdump,
        "ar": ctx.attr._ar,
        "ranlib": ctx.attr._ranlib,
        "strip": ctx.attr._strip,
    }

    tool_paths = [
        tool_path(
            name = key,
            path = "avr-gcc.sh",
        )
        for key in tools
    ]
    for tool in tool_paths:
        print(tool)
    opt_feature = new_feature("opt", __CODE_SIZE_OPTIMIZATION_COPTS)
    fastbuild_feature = new_feature("fastbuild", ["-O2"])
    c99_feature = new_feature("gnu99", ["-std=gnu99"], True)
    cxx_include_directories = [
        "external/avr-gcc-unwrapped/lib/gcc/avr/7.4.0/include",
        "external/avr-gcc-unwrapped/lib/gcc/avr/7.4.0/include-fixed",
        "external/avr-libc/avr/include",
    ]

    #    convert_warnings_to_errors = new_feature("treat_warnings_as_errors", @warnings_as_errors@)
    features = [opt_feature, fastbuild_feature, c99_feature]  #convert_warnings_to_errors]
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
            cxx_builtin_include_directories = cxx_include_directories,
            features = features,
            make_variables = [make_variable("MCU", ctx.attr.mcu)],
        ),
        platform_common.TemplateVariableInfo({"MCU": ctx.attr.mcu}),
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
        "_gcc": attr.label(allow_single_file = True, default = "@avr-gcc//:bin/avr-gcc"),
        "_cpp": attr.label(allow_single_file = True, default = "@avr-gcc//:bin/avr-g++"),
        "_nm": attr.label(allow_single_file = True, default = "@avr-binutils//:bin/avr-nm"),
        "_objcopy": attr.label(allow_single_file = True, default = "@avr-binutils//:bin/avr-objcopy"),
        "_ld": attr.label(allow_single_file = True, default = "@avr-gcc//:bin/avr-ld"),
        "_size": attr.label(allow_single_file = True, default = "@avr-binutils//:bin/avr-size"),
        "_gcov": attr.label(allow_single_file = True, default = "none"),
        "_ar": attr.label(allow_single_file = True, default = "@avr-binutils//:bin/avr-ar"),
        "_objdump": attr.label(allow_single_file = True, default = "@avr-binutils//:bin/avr-objdump"),
        "_strip": attr.label(allow_single_file = True, default = "@avr-binutils//:bin/avr-strip"),
        "_ranlib": attr.label(allow_single_file = True, default = "@avr-binutils//:bin/avr-ranlib"),
        "_cxx_include_dirs": attr.label_list(allow_files = True, default = ["@avr-gcc-unwrapped//:lib"]),
        "_data": attr.label_list(allow_files = True, default = ["@avr-gcc//:bin", "//example:avr-gcc.sh"]),
    },
    provides = [CcToolchainConfigInfo, platform_common.TemplateVariableInfo],
)
