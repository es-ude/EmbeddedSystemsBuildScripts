package(default_visibility = ["//visibility:public"])

DFU_UPLOAD_SCRIPT_TEMPLATE = """
{export}
{sudo}dfu-programmer $$1 erase;
{sudo}dfu-programmer $$1 flash $$2;
{sudo}dfu-programmer $$1 reset;
"""

AVRDUDE_UPLOAD_SCRIPT_TEMPLATE = """
avrdude -c wiring -p \$$1 -P /dev/ttyACM0 -D -V -U flash:w:\$$2" > $@
"""

genrule(
    name = "dfu_upload_script",
    outs = ["dfu_upload_script.sh"],
    cmd = "echo '" + select({
        "@AvrToolchain//host_config:dfu_needs_sudo": DFU_UPLOAD_SCRIPT_TEMPLATE.format(
            export = "",
            sudo = "sudo ",
        ),
        "@AvrToolchain//host_config:dfu_needs_ask_pass": DFU_UPLOAD_SCRIPT_TEMPLATE.format(
            export = "export SUDO_ASKPASS=$(ASKPASS)",
            sudo = "sudo ",
        ),
        "//conditions:default": DFU_UPLOAD_SCRIPT_TEMPLATE.format(
            export = "",
            sudo = "",
        ),
    }) + "' > $@",
)

genrule(
    name = "avrdude_upload_script",
    outs = ["avrdude_upload_script.sh"],
    cmd = " echo '" + select({
        "//conditions:default": AVRDUDE_UPLOAD_SCRIPT_TEMPLATE.format(
            
        )
    }) + "' > $@",
)