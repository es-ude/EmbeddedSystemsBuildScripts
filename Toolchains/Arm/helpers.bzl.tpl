def generate_hex(name, input, testonly = 0, tags = []):
    native.genrule(
        name = name,
        srcs = [input],
        tags = tags,
        outs = [name + ".bin"],
        cmd = "arm-none-eabi-objcopy -O binary $(SRCS) $(OUTS)",
        testonly = testonly
    )

def default_arm_binary(name, uploader = None, **kwargs):
    native.cc_binary(
        name = "_" + name + "ELF",
        **kwargs
    )
    generate_hex(
        name = name,
        input = "_" + name + "ELF",
    )


