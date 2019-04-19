def generate_hex(name, input, mcu, testonly=0):
    native.genrule(
        name = name,
        srcs = [input],
        outs = [input + ".hex"],
        cmd = "avr-objcopy -O ihex -j .text -j .data -j .bss $(SRCS) $(OUTS); avr-size --mcu=%s --format avr $(SRCS)" % (mcu),
		testonly = testonly,
    )

def avr_cmock_copts():
  name = "@AVR_Toolchain"
  return select({
      name + "//:avr-config": ["-DCEXCEPTION_NONE=0x00",
                                      "-DEXCEPTION_T=uint8_t",
                                      "-DCMOCK_MEM_SIZE=512",
                                      "-DCMOCK_MEM_STATIC",
                                      "-mmcu=$(MCU)",
                                      "-O2"],
      "//conditions:default": [],
  })

def avr_cexception_copts():
    return select({
        "@AVR_Toolchain//:avr-config": ["-DCEXCEPTION_NONE=0x00",
                                        "-DEXCEPTION_T=uint8_t",
                                        "-mmcu=$(MCU)",
                                        "-O2"],
        "//conditions:default": [],
    })

def avr_unity_copts():
  return select({
        "@AVR_Toolchain//:avr-config": [
            "-mmcu=$(MCU)",
            "-include 'lib/include/UnityOutput.h'",
            "-DUNITY_OUTPUT_CHAR(a)=UnityOutput_write(a)",
            "-DUNITY_OUTPUT_START()=UnityOutput_init(9600)",
            "-include stddef.h",
            "-O2",],
        "//conditions:default": [],
    })

def avr_minimal_copts():
  return select({
      "@AVR_Toolchain//:avr-config": ["-mmcu=$(MCU)", "-O2"],
      "//conditions:default": [],
  })
