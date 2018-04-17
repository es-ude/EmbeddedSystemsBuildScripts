def generate_hex(name, input, mcu):
    native.genrule(
        name = name,
        srcs = [input],
        outs = [input + ".hex"],
        cmd = "avr-objcopy -O ihex -j .text -j .data -j .bss $(SRCS) $(OUTS); avr-size --mcu=%s --format avr $(OUTS)" % (mcu),
        testonly = 1,
    )