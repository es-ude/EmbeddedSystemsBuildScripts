load("@ArmToolchain//cc_toolchain:cc_toolchain_config.bzl", "cc_toolchain_config")

filegroup(
    name = "empty",
    srcs = [],
)

cc_toolchain_config(
    name = "arm_eabi_toolchain_config_cortex_m0",
    cxx_include_dirs = @cxx_include_directories@,
    host_system_name = "linux",
    target_system_name = "cortex",
    target_cpu = "cortex-m0",
    tools = {
        "gcc": "@gcc@",
        "cpp": "@g++@",
        "ar": "@ar@",
        "ld": "@ld@",
        "nm": "@nm@",
        "strip": "@strip@",
        "objdump": "@objdump@",
        "size": "@size@",
        "objcopy": "@objcopy@",
        "gcov": "@gcov@",
    }
)

cc_toolchain(
    name = "arm_eabi_toolchain",
    all_files = ":empty",
    compiler_files = ":empty",
    dwp_files = ":empty",
    linker_files = ":empty",
    objcopy_files = ":empty",
    strip_files = ":empty",
    toolchain_config = ":arm_eabi_toolchain_config_cortex_m0",
    toolchain_identifier = "arm-eabi-cc-toolchain",
)

toolchain(
    name = "cc-toolchain-arm-eabi-cortex-m0",
    exec_compatible_with = [
    ],
    target_compatible_with = [
        "@ArmToolchain//platforms:cortex-m0"
    ],
    toolchain = ":arm_eabi_toolchain",
    toolchain_type = "@bazel_tools//tools/cpp:toolchain_type",
)
