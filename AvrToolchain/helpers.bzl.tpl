load("@AvrToolchain//platforms/mcu:mcu.bzl", "get_mcu", "get_mcu_as_array")

def upload(name, srcs = [], upload_script = "@AvrToolchain//:dfu_upload_script"):
    native.sh_binary(
        name = name,
        srcs = [upload_script],
        args = get_mcu_as_array() + ["$(location {input})".format(input = srcs[0])],
        data = [srcs[0]],
    )

def generate_hex(name, input, testonly = 0, tags = []):
    native.genrule(
        name = name,
        srcs = [input],
        tags = tags,
        outs = [name + ".hex"],
        cmd = select(
                  {
                      "@AvrToolchain//platforms:avr_config": "{avr_objcopy} -O ihex -j .text -j .data -j .bss $(SRCS) $(OUTS); {avr_size} --mcu=",
                      "@AvrToolchain//host_config:enable_avr_size_injection": "{avr_objcopy} -O ihex -j .text -j .data -j .bss $(SRCS) $(OUTS); $(AVR_SIZE) --mcu=",
                      "//conditions:default": "echo 'target only valid for avr platforms'; return 1",
                  },
              ) +
              get_mcu() +
              select(
                  {
                      "@AvrToolchain//platforms:avr_config": " --format avr $(SRCS)",
                      "//conditions:default": "",
                  },
              ),
        testonly = testonly,
    )

def default_embedded_binary(name, uploader, **kwargs):
    native.cc_binary(name = name + "_" + "ELF", **kwargs)
    generate_hex(
        name = name,
        input = name + "_" + "ELF",
    )
    upload(
        name = name + "_" + "upload",
        srcs = [name],
        upload_script = uploader,
    )

def default_embedded_binaries(main_files, other_srcs = [], **kwargs):
    for file in main_files:
        default_embedded_binary(
            name = file.rpartition(".")[0].rpartition("/")[2],
            srcs = other_srcs + [file],
            **kwargs
        )

"""
Use this macro to create a unity library for your platform.
E.g.:

create_unity_library(
    name = "Unity",
    unity_output_start_macro="MyOutputInitFunctionCall(actual_init_value)",
    unity_output_char_macro="MyOutputCharacterFunctionName",
    deps = [":LibraryWithHeadersForAboveFunctions"],
)

unity_test(
    file_name = "MyTest.c",
    deps = [":MyLibUnderTest"],
    unity = [":Unity"],
)

"""

def create_unity_library(
        name = "Unity",
        srcs = ["@Unity//:UnitySrcs"],
        hdrs = ["@Unity//:UnityHdrs"],
        unity_output_start_macro = None,
        unity_output_char_macro = None,
        strip_include_prefix = "external/Unity/src/",
        defines = [],
        **kwargs):
    _defines = defines
    if unity_output_char_macro != None:
        _defines.append("UNITY_OUTPUT_CHAR(a)={}(a)".format(unity_output_char_macro))
    if unity_output_start_macro != None:
        _defines.append("UNITY_OUTPUT_START()={}".format(unity_output_start_macro))
    native.cc_library(
        name = name,
        srcs = srcs,
        hdrs = hdrs,
        strip_include_prefix = strip_include_prefix,
        **kwargs
    )
