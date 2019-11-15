package(default_visibility = ["//visibility:public"])

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
        "@Toolchains_Avr//host_config:dfu_needs_sudo": UPLOAD_SCRIPT_TEMPLATE.format(
            export = "",
            sudo = "sudo ",
        ),
        "@Toolchains_Avr//host_config:dfu_needs_ask_pass": UPLOAD_SCRIPT_TEMPLATE.format(
            export = "export SUDO_ASKPASS=$(ASKPASS)",
            sudo = "sudo ",
        ),
        "//conditions:default": UPLOAD_SCRIPT_TEMPLATE.format(
            export = "",
            sudo = "",
        ),
    }) + "' > $@",
)