"""
Prepend prefix to each of the tools (all
part of a gcc toolchain suite) and try
to find them in PATH environment.
If the tool is not found the corresponding
entry will be left empty.

Returns the dictionary containing the discovered
paths.
"""
def get_tools(repository_ctx, prefix = ""):
    tools = {
        "gcc": repository_ctx.attr.gcc_tool,
        "ar": repository_ctx.attr.ar_tool,
        "ld": repository_ctx.attr.ld_tool,
        "g++": repository_ctx.attr.cpp_tool,
        "gcov": repository_ctx.attr.gcov_tool,
        "nm": repository_ctx.attr.nm_tool,
        "objdump": repository_ctx.attr.objdump_tool,
        "strip": repository_ctx.attr.strip_tool,
        "size": repository_ctx.attr.size_tool,
        "objcopy": repository_ctx.attr.objcopy_tool,
    }
    for key in tools.keys():
        if tools[key] == "":
            tools[key] = "{}".format(repository_ctx.which(prefix + key))
    return tools
