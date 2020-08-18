# package(default_visibility = ["//visibility:public"])

# constraint_value(
#     name = "cortex-m4",
#     constraint_setting = "@bazel_tools//platforms:cpu",
# )
# load("@ArmToolchain//cc_toolchain:cc_toolchain_config.bzl", "cc_toolchain_config")

package(
    default_visibility = ["//visibility:public"]
)

constraint_value(
    name = "arm",
    constraint_setting = "@bazel_tools//platforms:cpu"
)

config_setting(
    name = "arm_config"
)

constraint_value(
    name = "bare_metal",
    constraint_setting = "@bazel_tools//platforms:os"
)

platform(
    name = "arm_common",
    constraint_values = [
        "@ArmToolchain//platforms:bare_metal",
        "@ArmToolchain//platforms:arm"
    ]
)

platform(
    name = "arm_ElasticNode",
    constraint_values = [
        "@ArmToolchain//platforms/cpu:cortex-m4",
        "@ArmToolchain//platforms/board_id:arm_ElasticNode"
    ],
    parents = [":arm_common"]
)


# filegroup(
#     name = "empty",
#     srcs = [],
# )

# cc_toolchain_config(
#     name = "arm_none_eabi_toolchain_config_cortex_m0",
#     cxx_include_dirs = @cxx_include_directories@,
#     host_system_name = "linux",
#     target_system_name = "cortex",
#     target_cpu = "cortex-m0plus",
#     tools = {
#         "gcc": "@gcc@",
#         "cpp": "@g++@",
#         "ar": "@ar@",
#         "ld": "@ld@",
#         "nm": "@nm@",
#         "strip": "@strip@",
#         "objdump": "@objdump@",
#         "size": "@size@",
#         "objcopy": "@objcopy@",
#         "gcov": "@gcov@",
#     }
# )

# cc_toolchain_config(
#     name = "arm_none_eabi_toolchain_config_cortex_m4",
#     cxx_include_dirs = @cxx_include_directories@ + ["/usr/include/newlib"],
#     host_system_name = "linux",
#     target_system_name = "cortex",
#     target_cpu = "cortex-m4",
#     tools = {
#         "gcc": "@gcc@",
#         "cpp": "@g++@",
#         "ar": "@ar@",
#         "ld": "@ld@",
#         "nm": "@nm@",
#         "strip": "@strip@",
#         "objdump": "@objdump@",
#         "size": "@size@",
#         "objcopy": "@objcopy@",
#         "gcov": "@gcov@",
#     }
# )

# cc_toolchain(
#     name = "arm_none_eabi_toolchain",
#     all_files = ":empty",
#     compiler_files = ":empty",
#     dwp_files = ":empty",
#     linker_files = ":empty",
#     objcopy_files = ":empty",
#     strip_files = ":empty",
#     toolchain_config = ":arm_none_eabi_toolchain_config_cortex_m0",
#     toolchain_identifier = "arm-eabi-cc-toolchain",
# )

# toolchain(
#     name = "cc-toolchain-arm-eabi-cortex-m0",
#     exec_compatible_with = [
#     ],
#     target_compatible_with = [
#         "@ArmToolchain//platforms:cortex-m0"
#     ],
#     toolchain = ":arm_none_eabi_toolchain",
#     toolchain_type = "@bazel_tools//tools/cpp:toolchain_type",
# )
