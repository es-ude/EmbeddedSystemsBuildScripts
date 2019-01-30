def generate_hex(name, input, testonly = 0, mcu = ""):
    native.genrule(
        name = name,
        srcs = [input],
        outs = [name + ".hex"],
        cmd = "avr-objcopy -O ihex -j .text -j .data -j .bss $(SRCS) $(OUTS); avr-size --mcu=$(MCU) --format avr $(SRCS)",  # % (mcu),
        testonly = testonly,
    )

def avr_cmock_copts():
    name = "@AVR_Toolchain"
    return select({
        name + "//:avr-config": [
            "-DCEXCEPTION_NONE=0x00",
            "-DEXCEPTION_T=uint8_t",
            "-DCMOCK_MEM_SIZE=512",
            "-DCMOCK_MEM_STATIC",
            "-mmcu=$(MCU)",
            "-O2",
        ],
        "//conditions:default": [],
    })

def avr_cexception_copts():
    return select({
        "@AVR_Toolchain//:avr-config": [
            "-DCEXCEPTION_NONE=0x00",
            "-DEXCEPTION_T=uint8_t",
            "-mmcu=$(MCU)",
            "-O2",
        ],
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
            "-O2",
        ],
        "//conditions:default": [],
    })

def avr_minimal_copts():
    return select({
        "@AVR_Toolchain//:avr-config": ["-mmcu=$(MCU)"],
        "//conditions:default": [],
    })

__CEXCEPTION_COPTS = [
    "-DCEXCEPTION_NONE=0x00",
    "-DEXCEPTION_T=uint8_t",
    "-include stdint.h",
]

__CODE_SIZE_OPTIMIZATION_COPTS = [
    "-Os",
    "-s",
    "-fno-asynchronous-unwind-tables",
    "-ffast-math",
    "-fmerge-all-constants",
    "-fmerge-all-constants",
    "-include stdint.h",
    "-fdata-sections",
    "-ffunction-sections",
    "-DCEXCEPTION_T=uint8_t",
    "-DCEXCEPTION_NONE=0x00",
    "-fshort-enums",
    "-mrelax",
    "-fno-jump-tables",
]

__CODE_SIZE_OPTIMIZATION_LINKOPTS = [
    "-Xlinker --gc-sections",
    "-Xlinker --relax",
] + __CODE_SIZE_OPTIMIZATION_COPTS

def optimizing_for_size_copts():
    return __CODE_SIZE_OPTIMIZATION_COPTS

def default_embedded_lib(name, hdrs = [], srcs = [], deps = [], copts = [], visibility = []):
    native.cc_library(
        name = name,
        hdrs = hdrs,
        srcs = srcs,
        deps = deps + ["@CException"],
        copts = copts + avr_minimal_copts() +
                __CODE_SIZE_OPTIMIZATION_COPTS +
                __CEXCEPTION_COPTS,
        visibility = visibility,
    )

    def default_embedded_binary(name, srcs = [], deps = [], copts = [], linkopts=[], visibility = []):
    native.cc_binary(
        name = name + "ELF",
        srcs = srcs,
        deps = deps + ["@CException"],
        copts = copts + avr_minimal_copts() +
                __CODE_SIZE_OPTIMIZATION_COPTS,
        linkopts = linkopts + avr_minimal_copts() +
                   __CODE_SIZE_OPTIMIZATION_LINKOPTS +
                   __CEXCEPTION_COPTS,
        visibility = visibility,
    )
    generate_hex(
        name = name,
        input = name + "ELF",
    )
