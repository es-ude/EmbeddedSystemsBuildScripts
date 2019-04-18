load("@bazel_tools//tools/build_defs/repo:utils.bzl", "workspace_and_buildfile")

"""
Preliminary primitive rules for cloning git repositories.
"""
def _clone_git_impl(ctx):
    repo_root = ctx.path(".")
    git = ctx.which("git")
    ctx.execute([git, "clone", ctx.attr.url, "."])

_clone_git_impl_attrs = {
    "url": attr.string(),
}

clone_git = repository_rule(
    implementation = _clone_git_impl,
    attrs = _clone_git_impl_attrs,
    doc = """
    This rule calls the git executable
    provided by the OS directly. If you need
    authentication, you have to make sure that
    git handles that on its own.
        url: The url of the repository. Internally the call 'git clone <url>' will be issued.
    """
)


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
_INC_DIR_MARKER_BEGIN = "#include <...>"

# OSX add " (framework directory)" at the end of line, strip it.
_OSX_FRAMEWORK_SUFFIX = " (framework directory)"
_OSX_FRAMEWORK_SUFFIX_LEN =  len(_OSX_FRAMEWORK_SUFFIX)
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

  paths = [repository_ctx.path(_cxx_inc_convert(p))
            for p in inc_dirs.split("\n")]
  return ['{}'.format(x) for x in paths]

def _get_avr_toolchain_def(ctx):
    repo_root = ctx.path(".")
    avr_gcc = ctx.attr.avr_gcc
    if avr_gcc == "":
        avr_gcc = ctx.which("avr-gcc")
    host_system_name = "linux"

    ctx.file("BUILD", avr_toolchain_build_file_template.format(
        host_system_name=host_system_name,
        avr_gcc=ctx.which("avr-gcc"),
        avr_ar =ctx.which("avr-ar"),
        avr_ld =ctx.which("avr-ld"),
        avr_cpp =ctx.which("avr-cpp"),
        avr_gcov=ctx.which("avr-gcov"),
        avr_nm=ctx.which("avr-nm"),
        avr_objdump=ctx.which("avr-objdump"),
        avr_strip=ctx.which("avr-strip"),
        cxx_include_dirs=_get_cxx_inc_directories(ctx, ctx.which("avr-gcc"))
        ))
    ctx.file("cc_toolchain_config.bzl", _cc_toolchain_config_template)

_get_avr_toolchain_def_attrs = {
    "avr_gcc": attr.string(),
}

create_avr_toolchain = repository_rule(
    implementation = _get_avr_toolchain_def,
    attrs = _get_avr_toolchain_def_attrs,
)
    
