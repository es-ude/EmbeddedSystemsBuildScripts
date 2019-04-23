load("@bazel_tools//tools/build_defs/repo:utils.bzl", "workspace_and_buildfile")

"""
This template is used to
autogenerate a build file containing
the avr-gcc toolchain setup that was
detected for your system. However it can
be used as an example on how to use the
cc_toolchain_config rule to define your own
toolchain.
"""
avr_toolchain_build_file_template = """
# This is an auto generated file
load(":cc_toolchain_config.bzl", "cc_toolchain_config")

package(default_visibility = ['//visibility:public'])

filegroup(name = "empty")

config_setting(
        name = "avr-config",
        values = {{
                "cpu": "avr",
                }},
        visibility = ["//visibility:public"]
        )


cc_toolchain_suite(
    name = "avr-gcc",
    toolchains = {{
        "avr": ":avr_cc_toolchain",
        "avr|cc": ":avr_cc_toolchain",
    }},
)

cc_toolchain_config(
    name = "avr_cc_toolchain_config",
    host_system_name = "{host_system_name}",
    target_system_name = "avr",
    tools = {{
        "gcc": "{avr_gcc}",
        "ar": "{avr_ar}",
        "ld": "{avr_ld}",
        "cpp": "{avr_cpp}",
        "gcov": "{avr_gcov}",
        "nm": "{avr_nm}",
        "objdump": "{avr_objdump}",
        "strip": "{avr_strip}",
    }},
    cxx_include_dirs = {cxx_include_dirs}
)

cc_toolchain(
    name = "avr_cc_toolchain",
    toolchain_config = ":avr_cc_toolchain_config",
    toolchain_identifier = "avr-toolchain",
    cpu = "avr",
    all_files = ":empty",
    compiler_files = ":empty",
    dwp_files = ":empty",
    linker_files = ":empty",
    objcopy_files = ":empty",
    strip_files = ":empty",
)


"""

_cc_toolchain_config_template = """
load("@bazel_tools//tools/cpp:cc_toolchain_config_lib.bzl",
    "feature",
    "flag_group",
    "flag_set",
    "tool_path",
    "with_feature_set",
    )
load("@bazel_tools//tools/build_defs/cc:action_names.bzl", "ACTION_NAMES")

def _impl(ctx):
    tools = ctx.attr.tools
    tool_paths = [
        tool_path(
            name = key,
            path = tools[key],
        ) for key in tools
    ]

    return cc_common.create_cc_toolchain_config_info(
        ctx = ctx,
        toolchain_identifier = "avr-toolchain",
        host_system_name = ctx.attr.host_system_name,
        target_system_name = ctx.attr.target_system_name,
        target_cpu = ctx.attr.target_cpu,
        target_libc = ctx.attr.target_libc,
        abi_version = ctx.attr.abi_version,
        compiler = "cc",
        abi_libc_version = "unknown",
        tool_paths = tool_paths,
        cxx_builtin_include_directories = ctx.attr.cxx_include_dirs,
    )



cc_toolchain_config = rule(
    implementation = _impl,
    attrs = {
        "host_system_name": attr.string(),
        "target_system_name": attr.string(default="avr"),
        "target_cpu": attr.string(default="avr"),
        "target_libc": attr.string(default="unknown"),
        "abi_version": attr.string(default="unknown"),
        "tools": attr.string_dict(),
        "cxx_include_dirs": attr.string_list(),
    },
    provides = [CcToolchainConfigInfo],
)

"""

_embedded_lib_helper_macros = """

def __create_upload_script():
    native.genrule(
        name = "internal_upload_script",
        outs = ["upload.sh"],
        cmd = "echo 'sudo dfu-programmer atmega32u4 erase; sudo dfu-programmer atmega32u4 flash $$1; sudo dfu-programmer atmega32u4 reset' > $@",
    )

def upload(name, srcs = []):
    if not "internal_upload_script" in native.existing_rules():
        __create_upload_script()
    native.sh_binary(
        name = name,
        srcs = ["upload.sh"],
        args = ["$(location {{input}})".format(input = srcs[0])],
        data = [srcs[0]],
    )

def generate_hex(name, input, testonly = 0):
    native.genrule(
        name = name,
        srcs = [input],
        outs = [name + ".hex"],
        cmd = select({{
            "@{avr_toolchain_project}//:avr-config": "{avr_objcopy} -O ihex -j .text -j .data -j .bss $(SRCS) $(OUTS); {avr_size} --mcu=$(MCU) --format avr $(SRCS)",
            "//conditions:default": "echo 'target only valid for avr platforms'; return 1",
            }}),
        testonly = testonly,
    )

def avr_cmock_copts():
    name = "@{avr_toolchain_project}"
    return select({{
        name + "//:avr-config": [
            "-DCEXCEPTION_NONE=0x00",
            "-DEXCEPTION_T=uint8_t",
            "-DCMOCK_MEM_SIZE=512",
            "-DCMOCK_MEM_STATIC",
            "-mmcu=$(MCU)",
            "-O2",
        ],
        "//conditions:default": [],
    }})

def avr_cexception_copts():
    return select({{
        "@{avr_toolchain_project}//:avr-config": [
            "-DCEXCEPTION_NONE=0x00",
            "-DEXCEPTION_T=uint8_t",
            "-mmcu=$(MCU)",
            "-O2",
        ],
        "//conditions:default": [],
    }})

def avr_unity_copts():
    return select({{
        "@{avr_toolchain_project}//:avr-config": [
            "-mmcu=$(MCU)",
            "-include 'lib/include/UnityOutput.h'",
            "-DUNITY_OUTPUT_CHAR(a)=UnityOutput_write(a)",
            "-DUNITY_OUTPUT_START()=UnityOutput_init(9600)",
            "-include stddef.h",
            "-O2",
        ],
        "//conditions:default": [],
    }})

def avr_minimal_copts():
    return select({{
        "@{avr_toolchain_project}//:avr-config": ["-mmcu=$(MCU)"],
        "//conditions:default": [],
    }})

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
        deps = deps + ["{cexception}"],
        copts = copts + avr_minimal_copts() +
                __CODE_SIZE_OPTIMIZATION_COPTS +
                __CEXCEPTION_COPTS +
                select({{
                    "@{avr_toolchain_project}//:avr-config": ["-mrelax"],
                    "//conditions:default": [],
                }}),
        visibility = visibility,
    )

def default_embedded_binary(name, srcs = [], deps = [], copts = [], linkopts = [], visibility = []):
    native.cc_binary(
        name = name + "ELF",
        srcs = srcs,
        deps = deps + ["{cexception}"],
        copts = copts + avr_minimal_copts() +
                __CODE_SIZE_OPTIMIZATION_COPTS,
        linkopts = linkopts + avr_minimal_copts() +
                   __CODE_SIZE_OPTIMIZATION_LINKOPTS +
                   __CEXCEPTION_COPTS +
                   select({{
                       "@{avr_toolchain_project}//:avr-config": ["-mrelax"],
                       "//conditions:default": [],
                   }}),
        visibility = visibility,
    )
    generate_hex(
        name = name,
        input = name + "ELF",
    )
    upload(
        name = "upload" + name,
        srcs = [name],
    )

def default_embedded_binaries(main_files, other_srcs = [], deps = [], copts = [], linkopts = [], visibility = []):
    for file in main_files:
        default_embedded_binary(
            name = file.rpartition(".")[0].rpartition("/")[2],
            srcs = other_srcs + [file],
            deps = deps,
            copts = copts,
            linkopts = linkopts,
            visibility = visibility,
        )


"""

_INC_DIR_MARKER_BEGIN = "#include <...>"

# OSX add " (framework directory)" at the end of line, strip it.
_OSX_FRAMEWORK_SUFFIX = " (framework directory)"
_OSX_FRAMEWORK_SUFFIX_LEN = len(_OSX_FRAMEWORK_SUFFIX)

def _cxx_inc_convert(path):
    """Convert path returned by cc -E xc++ in a complete path."""
    path = path.strip()
    if path.endswith(_OSX_FRAMEWORK_SUFFIX):
        path = path[:-_OSX_FRAMEWORK_SUFFIX_LEN].strip()
    return path

def _get_cxx_inc_directories(repository_ctx, cc):
    """Compute the list of default C++ include directories."""
    result = repository_ctx.execute([cc, "-E", "-xc++", "-", "-v"])
    index1 = result.stderr.find(_INC_DIR_MARKER_BEGIN)
    if index1 == -1:
        return []
    index1 = result.stderr.find("\n", index1)
    if index1 == -1:
        return []
    index2 = result.stderr.rfind("\n ")
    if index2 == -1 or index2 < index1:
        return []
    index2 = result.stderr.find("\n", index2 + 1)
    if index2 == -1:
        inc_dirs = result.stderr[index1 + 1:]
    else:
        inc_dirs = result.stderr[index1 + 1:index2].strip()

    paths = [
        repository_ctx.path(_cxx_inc_convert(p))
        for p in inc_dirs.split("\n")
    ]
    return ["{}".format(x) for x in paths]

def _get_avr_toolchain_def(ctx):
    repo_root = ctx.path(".")
    avr_gcc = ctx.attr.avr_gcc
    if avr_gcc == "":
        avr_gcc = ctx.which("avr-gcc")
    host_system_name = "linux"
    tools = {
        "avr-gcc": ctx.attr.avr_gcc,
        "avr-ar": ctx.attr.avr_ar,
        "avr-ld": ctx.attr.avr_ld,
        "avr-g++": ctx.attr.avr_cpp,
        "avr-gcov": ctx.attr.avr_gcov,
        "avr-nm": ctx.attr.avr_nm,
        "avr-objdump": ctx.attr.avr_objdump,
        "avr-strip": ctx.attr.avr_strip,
        "avr-size": ctx.attr.avr_size,
        "avr-objcopy": ctx.attr.avr_objcopy,
    }
    for key in tools.keys():
        if tools[key] == "":
            tools[key] = ctx.which(key)
    ctx.file("BUILD", avr_toolchain_build_file_template.format(
        host_system_name = host_system_name,
        avr_gcc = tools["avr-gcc"],
        avr_ar = tools["avr-ar"],
        avr_ld = tools["avr-ld"],
        avr_cpp = tools["avr-g++"],
        avr_gcov = tools["avr-gcov"],
        avr_nm = tools["avr-nm"],
        avr_objdump = tools["avr-objdump"],
        avr_strip = tools["avr-strip"],
        cxx_include_dirs = _get_cxx_inc_directories(ctx, ctx.which("avr-gcc")),
    ))
    ctx.file("helpers.bzl", _embedded_lib_helper_macros.format(
        cexception = ctx.attr.cexception,
        avr_toolchain_project = ctx.attr.name,
        avr_objcopy = tools["avr-objcopy"],
        avr_size = tools["avr-size"],
    ))
    ctx.file("cc_toolchain_config.bzl", _cc_toolchain_config_template)

_get_avr_toolchain_def_attrs = {
    "avr_gcc": attr.string(),
    "cexception": attr.string(default = "@CException"),
    "avr_size": attr.string(),
    "avr_ar": attr.string(),
    "avr_ld": attr.string(),
    "avr_cpp": attr.string(),
    "avr_gcov": attr.string(),
    "avr_nm": attr.string(),
    "avr_objdump": attr.string(),
    "avr_strip": attr.string(),
    "avr_objcopy": attr.string(),
}

create_avr_toolchain = repository_rule(
    implementation = _get_avr_toolchain_def,
    attrs = _get_avr_toolchain_def_attrs,
)
