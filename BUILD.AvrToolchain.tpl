# This is an auto generated file
load("@{name}//:cc_toolchain_config.bzl", "cc_toolchain_config")

package(default_visibility = ["//visibility:public"])

toolchain_type(name = "toolchain_type")

filegroup(name = "empty")

cc_toolchain_suite(
    name = "avr-gcc",
    toolchains = {
        "avr": ":avr_cc_toolchain",
        "avr|cc": ":avr_cc_toolchain",
    },
)

cc_toolchain_config(
    name = "avr_cc_toolchain_config",
    cxx_include_dirs = {cxx_include_dirs},
    host_system_name = "{host_system_name}",
    target_system_name = "avr",
    tools = {
        "gcc": "{avr_gcc}",
        "ar": "{avr_ar}",
        "ld": "{avr_ld}",
        "cpp": "{avr_cpp}",
        "gcov": "{avr_gcov}",
        "nm": "{avr_nm}",
        "objdump": "{avr_objdump}",
        "strip": "{avr_strip}",
    },
)

cc_toolchain(
    name = "avr_cc_toolchain",
    all_files = ":empty",
    compiler_files = ":empty",
    dwp_files = ":empty",
    linker_files = ":empty",
    objcopy_files = ":empty",
    strip_files = ":empty",
    toolchain_config = ":avr_cc_toolchain_config",
    toolchain_identifier = "avr-toolchain",
)

toolchain(
    name = "cc-toolchain-avr",
    target_compatible_with = [
        "@{name}//constraints:avr",
    ],
    toolchain = ":avr_cc_toolchain",
    toolchain_type = ":toolchain_type",
)

UPLOAD_SCRIPT_TEMPLATE = """
{export}
{sudo}dfu-programmer $$1 erase;
{sudo}dfu-programmer $$1 flash $$2;
{sudo}dfu-programmer $$1 reset;
"""

genrule(
    name = "dfu_upload_script",
    outs = ["dfu_upload_script.sh"],
    cmd = "echo '" + select({
        "@{name}//host_config:dfu_needs_sudo": UPLOAD_SCRIPT_TEMPLATE.format(
            export = "",
            sudo = "sudo ",
        ),
        "@{name}//host_config:dfu_needs_askpass": UPLOAD_SCRIPT_TEMPLATE.format(
            export = "export SUDO_ASKPASS=$(ASKPASS)",
            sudo = "sudo ",
        ),
        "//conditions:default": UPLOAD_SCRIPT_TEMPLATE.format(
            export = "",
            sudo = "",
        ),
    }) + "' > $@",
)
