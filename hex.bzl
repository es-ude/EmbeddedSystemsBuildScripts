def generate_hex(name, input, mcu):
    native.genrule(
        name = name,
        srcs = [input],
        outs = [input + ".hex"],
        cmd = "avr-objcopy -O ihex -j .text -j .data -j .bss $(SRCS) $(OUTS); avr-size --mcu=%s --format avr $(OUTS)" % (mcu),
        testonly = 1,
    )

def avr_cmock_copts():
  return select({
      "@AVR_Toolchain//:avr-config": ["-DCEXCEPTION_NONE=0x00",
                                      "-DEXCEPTION_T=uint8_t",
                                      "-DCMOCK_MEM_SIZE=512",
                                      "-DCMOCK_MEM_STATIC",
                                      "-mmcu=$(MCU)",
                                      "-O2"],
      "//conditions:default": [],
  })

def avr_cexception_copts():
    select({
        "@AVR_Toolchain//:avr-config": ["-DCEXCEPTION_NONE=0x00",
                                        "-DEXCEPTION_T=uint8_t",
                                        "-mmcu=$(MCU)"],
        "//conditions:default": [],
    })