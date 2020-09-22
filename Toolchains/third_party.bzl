###############
# Functions in this section are
# copied and modified from Bazel Authors' unix_cc_configure.bzl
# https://source.bazel.build/bazel/+/1d205e14e4c069e9199ab71b127c6a6e26a9443b:tools/cpp/unix_cc_configure.bzl
#
# Copyright 2018 The Bazel Authors. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
#
#
##############

_INC_DIR_MARKER_BEGIN = "#include <...>"

# OSX add " (framework directory)" at the end of line, strip it.
_OSX_FRAMEWORK_SUFFIX = " (framework directory)"
_OSX_FRAMEWORK_SUFFIX_LEN = len(_OSX_FRAMEWORK_SUFFIX)

def cxx_inc_convert(path):
    """Convert path returned by cc -E xc++ in a complete path."""
    path = path.strip()
    if path.endswith(_OSX_FRAMEWORK_SUFFIX):
        path = path[:-_OSX_FRAMEWORK_SUFFIX_LEN].strip()
    return path

def get_cxx_inc_directories(repository_ctx, cc):
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
        repository_ctx.path(cxx_inc_convert(p))
        for p in inc_dirs.split("\n")
    ]
    return ["{}".format(x) for x in paths]

def is_compiler_option_supported(repository_ctx, cc, option):
    """Checks that `option` is supported by the C compiler. Doesn't %-escape the option."""
    result = repository_ctx.execute([
        cc,
        option,
        "-o",
        "/dev/null",
        "-c",
        str(repository_ctx.path("tools/cpp/empty.cc")),
    ])
    return result.stderr.find(option) == -1

def is_linker_option_supported(repository_ctx, cc, option, pattern):
    """Checks that `option` is supported by the C linker. Doesn't %-escape the option."""
    result = repository_ctx.execute([
        cc,
        option,
        "-o",
        "/dev/null",
        str(repository_ctx.path("tools/cpp/empty.cc")),
    ])
    return result.stderr.find(pattern) == -1

def add_compiler_option_if_supported(repository_ctx, cc, option):
    """Returns `[option]` if supported, `[]` otherwise. Doesn't %-escape the option."""
    return [option] if is_compiler_option_supported(repository_ctx, cc, option) else []

def add_linker_option_if_supported(repository_ctx, cc, option, pattern):
    """Returns `[option]` if supported, `[]` otherwise. Doesn't %-escape the option."""
    return [option] if is_linker_option_supported(repository_ctx, cc, option, pattern) else []

#######
# end of section containing copied functions under Apache License
#######
