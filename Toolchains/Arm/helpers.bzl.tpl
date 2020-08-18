load("@ArmToolchain//platforms/cpu:cpu.bzl", "get_cpu", "get_cpu_as_array")

def upload(name, srcs = [], upload_script = "@ArmToolchain//:stm"):
    native.sh_binary(
        name = name,
        srcs = [upload_script],
        args = get_cpu_as_array() + [
            "$(location {input})".format(input = srcs[0])
        ],
        data = [srcs[0]]
    )

def generate_hex(name, input, testonly = 0, tags = []):
    native.genrule(
        name = name,
        srcs = [input],
        tags = tags,
        outs = [name + ".bin"],
        cmd = "{arm_objcopy} -O binary $(SRCS) $(OUTS)",
        testonly = testonly
    )

def default_arm_binary(name, uploader = None, **kwargs):
    native.cc_binary(
        name = name + "_" + "ELF",
        **kwargs
    )
    generate_hex(
        name = name,
        input = name + "_" + "ELF",
    )
    generate_stm_upload_script()
    upload(
        name = name + "_" + "Upload",
        srcs = [name],
        upload_script = uploader
    )

def generate_stm_upload_script():
    native.genrule(
        name = "STM",
        outs = ["stm_upload_script.sh"],
        cmd = """
        echo "st-flash erase; st-flash write \$$2 \$$3;" > $@
        """,
    )

