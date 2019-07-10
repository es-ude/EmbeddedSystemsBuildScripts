load(
    "//AvrToolchain:cc_toolchain/third_party.bzl",
    "add_compiler_option_if_supported",
    "get_cxx_inc_directories",
)

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
        repository_ctx.path(Label("@EmbeddedSystemsBuildScripts//AvrToolchain:cc_toolchain/cc_toolchain_config.bzl.tpl")),
        substitutions = {
            "@warnings_as_errors@": "{}".format(_get_treat_warnings_as_errors_flags(repository_ctx, gcc)),
        },
    )

def create_toolchain_definitions(mcus, repository_ctx):
    cc_toolchain_template = """load("@AvrToolchain//cc_toolchain:cc_toolchain_config.bzl",
"cc_toolchain_config")
package(default_visibility = ["//visibility:public"])

filegroup(
    name = "empty",
    srcs = [],
)

filegroup(
    name = "all_files",
    srcs = [
        ":avr-gcc.sh",
        "@avr-binutils//:bin",
        "@avr-gcc-unwrapped//:bin",
        "@avr-libc//:include",
        "@avr-libc//:lib",
        "@avr-gcc-unwrapped//:include",
    ],
)
    """
    mcu_specific = """
cc_toolchain_config(
    name = "avr_cc_toolchain_config_{mcu}",
    host_system_name = "{host_system_name}",
    mcu = "{mcu}",
    target_system_name = "avr-{mcu}",
)

cc_toolchain(
    name = "avr_cc_toolchain_{mcu}",
    all_files = ":all_files",
    compiler_files = ":all_files",
    dwp_files = ":empty",
    linker_files = ":all_files",
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
            host_system_name = repository_ctx.os.name,
        )
    return cc_toolchain_template

def create_cc_toolchain_package(repository_ctx, paths):
    mcu_list = repository_ctx.attr.mcu_list
    repository_ctx.file(
        "cc_toolchain/BUILD",
        create_toolchain_definitions(
            mcu_list,
            repository_ctx,
        ),
    )
    repository_ctx.template(
        "cc_toolchain/avr-gcc.sh",
        paths["@EmbeddedSystemsBuildScripts//AvrToolchain:cc_toolchain/avr-gcc.sh"],
    )
    create_cc_toolchain_config_rule(repository_ctx, "@EmbeddedSystemsBuildScripts//AvrToolchain:cc_toolchain/avr-gcc.sh")
