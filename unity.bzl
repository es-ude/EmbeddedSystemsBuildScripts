# Description: This file has all the functions to construct unity tests
"""
This file contains so called macros which are just functions written
in skylark (googles own constraint subset of python). For a quick
summary of what is different between python and skylark see:
https://docs.bazel.build/versions/master/skylark/language.html
"""

"""
Use the helper scripts shipped with unity to
generate a test runner for the specified file.
The genrule used here executes cmd to produce
the files specified in the outs attribute.
In the tools attribute we need to specify all the
files, that are needed during the execution of cmd.

srcs lists all input files and outs all output files.

Side fact:
The cmd is executed in bash.
The $(location ...) and $(SRC),$(OUTS) stuff is expanded
before handing it over to bash.

More Info:
https://docs.bazel.build/versions/master/be/general.html#genrule
"""

def generate_test_runner(file_name, visibility = None, cexception = True):
    if cexception:
        cmd = "ruby $(location @Unity//:TestRunnerGenerator) -cexception --enforce_strict_ordering=1 $(SRCS) $(OUTS)"
    else:
        cmd = "ruby $(location @Unity//:TestRunnerGenerator) --enforce_strict_ordering=1 $(SRCS) $(OUTS)"
    native.genrule(
        name = runner_base_name(file_name),
        srcs = [file_name],
        outs = [runner_file_name(file_name)],
        cmd = cmd,
        tools = [
            "@Unity//:TestRunnerGenerator",
            "@Unity//:HelperScripts",
        ],
        visibility = visibility,
    )

def mock(
        name,
        srcs,
        deps = [],
        plugins = ["ignore", "ignore_arg", "expect_any_args", "cexception", "callback", "return_thru_ptr", "array"],
        visibility = None,
        enforce_strict_ordering = False,
        strippables = [],
        treat_as_void = [],
        verbosity = 2,
        copts = [],
        linkopts = [],
        includes = [],
        when_ptr = "smart",
        fail_on_unexpected_calls = True):
    mock_srcs = name + "Srcs"
    sub_dir = __extract_sub_dir_from_header_path(srcs[0])
    other_arguments = __build_cmock_argument_string(
        enforce_strict_ordering,
        strippables,
        treat_as_void,
        verbosity,
        when_ptr,
        fail_on_unexpected_calls,
    )
    basename = __get_mock_hdr_base_name(srcs[0])
    plugin_argument = __build_plugins_argument(plugins)
    deps = __add_mock_deps(deps, plugin_argument)

    cmd = __build_mock_generator_cmd(sub_dir, plugin_argument, other_arguments)
    native.genrule(
        name = mock_srcs,
        srcs = srcs,
        outs = ["mocks/" + sub_dir + "/" + basename + ".c", "mocks/" + sub_dir + "/" + basename + ".h"],
        cmd = cmd,
        tools = [
            "@Unity//:HelperScripts",
            "@CMock//:HelperScripts",
            "@CMock//:MockGenerator",
        ],
    )
    mock_library_files = __add_header_to_srcs_if_possible([mock_srcs], srcs[0])
    native.cc_library(
        name = name,
        srcs = mock_library_files,
        hdrs = [mock_srcs],
        copts = copts,
        linkopts = linkopts,
        includes = includes,
        deps = [
            "@Unity//:Unity",
            "@CMock//:CMock",
        ] + deps,
        strip_include_prefix = "mocks/",
        visibility = visibility,
    )

"""
This macro creates a cc_test rule and a genrule (that creates
the test runner) for a given file.
It adds unity as dependency so the user doesn't have to do it himself.
Additional dependencies can be specified using the deps parameter.

The source files for the test are only the *_Test.c that the user writes
and the corresponding generated *_Test_Runner.c file.
"""

def unity_test(
        file_name,
        deps = [],
        copts = [],
        size = "small",
        cexception = True,
        mocks = [],
        linkopts = [],
        visibility = None,
        additional_srcs = []):
    generate_test_runner(
        file_name,
        visibility,
        cexception = cexception,
    )
    for header in mocks:
        deps = deps + [__get_mock_hdr_base_name(header)]
    native.cc_test(
        name = strip_extension(file_name),
        srcs = [file_name, runner_file_name(file_name)] + additional_srcs,
        visibility = visibility,
        deps = deps + ["@Unity//:Unity"],
        size = size,
        linkopts = linkopts,
        copts = copts,
        linkstatic = 1,
    )

"""
Convenience macro that generates a unity test for every file in a given list
using the same parameters.
"""

def generate_a_unity_test_for_every_file(
        file_list,
        deps = [],
        copts = None,
        linkopts = None,
        size = "small",
        mocks = [],
        visibility = None,
        cexception = True):
    for file in file_list:
        unity_test(
            file_name = file,
            deps = deps,
            visibility = visibility,
            copts = copts,
            size = size,
            mocks = mocks,
            linkopts = linkopts,
            cexception = cexception,
        )

def generate_a_mock_for_every_file(
        file_list,
        deps = [],
        copts = [],
        linkopts = [],
        visibility = ["//visibility:private"],
        enforce_strict_ordering = True):
    for file in file_list:
        mock(
            name = __get_mock_hdr_base_name(file),
            srcs = [file],
            deps = deps,
            copts = copts,
            linkopts = linkopts,
            visibility = visibility,
        )

def __extract_sub_dir_from_header_path(single_header_path):
    sub_dir = single_header_path
    if sub_dir.count("//") > 0:
        sub_dir = sub_dir.partition("//")[2]
    sub_dir = sub_dir.replace(":", "/").rsplit("/", maxsplit = 1)[0]
    if sub_dir.startswith("//"):
        sub_dir = sub_dir[2:]
    elif sub_dir.startswith("/"):
        sub_dir = sub_dir[1:]
    if sub_dir.endswith("/") and sub_dir.length > 1:
        sub_dir = sub_dir[:-1]
    return sub_dir

def __build_cmock_argument_string(enforce_strict_ordering, strippables, treat_as_void, verbosity, when_ptr, fail_on_unexpected_calls):
    other_arguments = ""
    if enforce_strict_ordering:
        other_arguments += " --enforce_strict_ordering=1"
    if strippables != []:
        other_arguments += " --strippables=" + ";".join(strippables) + ";"
    if treat_as_void != []:
        other_arguments += " --treat_as_void=" + ";".join(treat_as_void) + ";"
        other_arguments += " --verbosity={}".format(verbosity)
        other_arguments += " --when_ptr=" + when_ptr
    if not fail_on_unexpected_calls:
        other_arguments += " --fail_on_unexpected_calls=0"
    return other_arguments

def __build_plugins_argument(plugins):
    plugin_argument = ""
    if len(plugins) > 0:
        plugin_argument = ";".join(plugins) + ";'"
        plugin_argument = " --plugins='" + plugin_argument
    return plugin_argument

def __get_mock_hdr_base_name(path):
    return "Mock" + path.split("/")[-1].split(":")[-1][:-2]

def __file_comes_from_current_package(file_name):
    return native.package_name() == Label(file_name).package

def __build_mock_generator_cmd(sub_dir, plugin_argument, other_arguments):
    cmd = "UNITY_DIR=external/Unity/ ruby $(location @CMock//:MockGenerator) --mock_path=$(@D)/mocks/"
    if not sub_dir == "":
        cmd = cmd + " --subdir=" + sub_dir
    cmd = cmd + plugin_argument + other_arguments + " $(SRCS)"
    return cmd

def __add_mock_deps(deps, plugin_argument):
    if plugin_argument.find("cexception") >= 0:
        deps = deps + ["@CException"]
    return deps

def __add_header_to_srcs_if_possible(srcs, header):
    if __file_comes_from_current_package(header):
        srcs = srcs + [header]
    return srcs

# i guess this could be done more elegant using the File class but it does what we want
def strip_extension(file_name):
    return file_name[0:-2]

def runner_base_name(file_name):
    return strip_extension(file_name) + "_Runner"

def runner_file_name(file_name):
    return runner_base_name(file_name) + ".c"
