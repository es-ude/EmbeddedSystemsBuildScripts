package(default_visibility = ["//visibility:public"])

UPLOAD_SCRIPT_TEMPLATE = """
{export}
{sudo} $(rootpath @dfu-programmer//:bin/dfu-programmer) \$$1 erase;
{sudo} $(rootpath @dfu-programmer//:bin/dfu-programmer) \$$1 flash \$$2;
{sudo} $(rootpath @dfu-programmer//:bin/dfu-programmer) \$$1 reset;
"""

genrule(
    name = "dfu_upload_script",
    outs = ["dfu_upload_script.sh"],
    cmd = """cat <<EOF > $@""" + select({
        "@AvrToolchain//host_config:dfu_needs_sudo": UPLOAD_SCRIPT_TEMPLATE.format(
            export = "",
            sudo = "sudo",
        ),
        "@AvrToolchain//host_config:dfu_needs_ask_pass": UPLOAD_SCRIPT_TEMPLATE.format(
            export = "export SUDO_ASKPASS=$(ASKPASS)",
            sudo = "sudo",
        ),
        "//conditions:default": UPLOAD_SCRIPT_TEMPLATE.format(
            export = "",
            sudo = "",
        ),
    }) + "EOF\n",
    tools = ["@dfu-programmer//:bin/dfu-programmer"],
)
