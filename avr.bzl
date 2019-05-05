load("@bazel_tools//tools/build_defs/repo:utils.bzl", "workspace_and_buildfile")
load(
    "@bazel_tools//tools/cpp:lib_cc_configure.bzl",
    "auto_configure_fail",
    "auto_configure_warning",
    "escape_string",
    "get_env_var",
    "get_starlark_list",
    "resolve_labels",
    "split_escaped",
    "which",
)

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

def _get_template_label(target_name, package_name=""):
    return "@EmbeddedSystemsBuildScripts//:" + target_name + ".tpl"

def _get_package_template_label(package_name):
    return _get_template_label(_get_package_target_name(package_name))

def _get_package_target_name(package_name):
    return package_name + "/BUILD"

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
            tools[key] = "{}".format(ctx.which(key))

    target_package_names = [
        "host_platforms",
        "host_constraints",
        "host_config",
        "platforms",
        "constraints",
        "config",
    ]

    template_labels = [
        _get_template_label("cc_toolchain_config.bzl"),
        _get_template_label("BUILD.AvrToolchain"),
        _get_template_label("helpers.bzl"),
        _get_template_label("platform_constraints.bzl"),
        _get_template_label("BUILD.LUFA"),
    ]
    package_labels = [_get_package_template_label(x) for x in target_package_names]
    templates = resolve_labels(ctx, template_labels + package_labels)
    for package in target_package_names:
        ctx.template(
            _get_package_target_name(package),
            templates[_get_package_template_label(package)],
            {"{name}": ctx.name},
            False,
        )

    target = "cc_toolchain_config.bzl"
    ctx.template(target, templates[_get_template_label(target)], {}, False)
    target = "BUILD.LUFA"
    ctx.template(target, templates[_get_template_label(target)], {
        "{name}": ctx.name,
    })
    target = "platform_constraints.bzl"
    ctx.template(target, templates[_get_template_label(target)], {
            "{name}": ctx.name,
    })
    ctx.template("BUILD", templates["@EmbeddedSystemsBuildScripts//:BUILD.AvrToolchain.tpl"], {
        "{host_system_name}": host_system_name,
        "{avr_gcc}": tools["avr-gcc"],
        "{avr_ar}": tools["avr-ar"],
        "{avr_ld}": tools["avr-ld"],
        "{avr_cpp}": tools["avr-g++"],
        "{avr_gcov}": tools["avr-gcov"],
        "{avr_nm}": tools["avr-nm"],
        "{avr_objdump}": tools["avr-objdump"],
        "{avr_strip}": tools["avr-strip"],
        "{cxx_include_dirs}": "{}".format(_get_cxx_inc_directories(ctx, ctx.which("avr-gcc"))),
        "{name}": ctx.name,
    }, False)
    target = "helpers.bzl"
    ctx.template(
        target,
        templates[_get_template_label(target)],
        {
            "{cexception}": ctx.attr.cexception,
            "{avr_toolchain_project}": ctx.name,
            "{avr_objcopy}": tools["avr-objcopy"],
            "{avr_size}": tools["avr-size"],
        },
    )

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

def avr_toolchain():
    create_avr_toolchain(
        name = "AvrToolchain",
    )
    native.register_toolchains(
        "@AvrToolchain//:cc-toolchain-avr",
    )