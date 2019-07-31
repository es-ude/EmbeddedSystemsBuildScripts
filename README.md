[![Documentation Status](https://readthedocs.org/projects/embeddedsystemsbuildscripts/badge/?version=latest)](https://embeddedsystemsbuildscripts.readthedocs.io/en/latest/?badge=latest)

Embedded Systems Build Scripts
------------------------------

This is a collection of build scripts providing unit testing, cross compilation for avr platforms as well as definitions of target platforms developed by the department.
Please note that we currently have issues with Windows, so we recommend
using one of the former systems.

Head to https://nixos.org/nix/download.html to install the
nix package manager, then run
```
$ nix-env -iA nixos.bazel
```
to install bazel.

TODO: Update the template of the `WORKSPACE` file below

To use the scripts add these lines to your `WORKSPACE` file

```python
load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

http_archive(
    name = "EmbeddedSystemsBuildScripts",
    strip_prefix = "EmbeddedSystemsBuildScripts-<version>",
    urls = ["https://github.com/es-ude/EmbeddedSystemsBuildScripts/archive/v<version>.tar.gz"]
)
```
Where `<version>` is the version number of the scripts, that you want to use.

For more detailed documentation see [docs](https://embeddedsystemsbuildscripts.readthedocs.io/en/latest/)

### AvrToolchain
To be able to build for avr microcontrollers you add the following lines to your `WORKSPACE`:
```python
load("@EmbeddedSystemsBuildScripts//:external_dependencies.bzl", "avr_toolchain")

avr_toolchain()
```
This will generate an external Workspace, containing a toolchain definition for every supported microcontroller, as well as bazel constraints and config_settings to support creating new platforms and make build choices depending on different constraints chosen for the current build.

Use
```bash
$ bazel query 'kind(constraint_setting, @AvrToolchain//platforms/...)'
```
to retrieve a list of all defined constraint settings. These are dimensions from which you can choose values to define your own platform.
Note that the constraint_setting `board_id` is used by the department to refer to development boards.

To see a list of possible values for constraint call for
```bash
$ bazel query 'attr(constraint_setting, <your_constraint_setting_name>, @AvrToolchain//platforms/...)'
```

You can then use these constraints to create your own platform definitions:
```python
platform(
    name = "MyPlatform",
    constraint_values = [
        "@AvrToolchain//platforms/mcu:atmega328p",
        "@AvrToolchain//platforms/cpu_frequency:16mhz",
        "@AvrToolchain//platforms/misc:hardware_usart",
    ]
)
```
The `mcu` constraint is mandatory and used internally to choose the correct toolchain configuration.

To build a target for your platform use
```bash
$ bazel build //:myTarget --incompatible_cc_toolchain_resolution=true --platforms //:MyPlatform
```

Additionally to creating your own platform you can use one of
our predefined boards. To get a list call
```bash
$ bazel query 'kind(platform, @AvrToolchain//platforms/...)'
```

In most cases you'll want to apply various build flags to optimize the program size. Calling the build with the flag `--compilation_mode opt` will apply a set of flags we found useful for that.

To treat warnings that most probably come from programming errors - e.g. missing return statement - into compiler errors apply the following flag to the bazel call
```bash
--features=treat_warnings_as_errors
```

### Macros
#### Embedded Builds
While there is no difference in how native and embedded cc_* targets are defined, actually being able to program a device involves more steps.
These are building the binary, converting it to a `.hex` file and uploading it to the program memory.
The macro `default_embedded_binary` does all that.
```python
load("@AvrToolchain//:helpers.bzl", "default_embedded_binary")

load("@AvrToolchain//platforms/cpu_frequency:cpu_frequency.bzl", "cpu_frequency_flag")

default_embedded_binary(
    name = "main",
    copts = cpu_frequency_flag(),
    srcs = ["main.c"],
    deps = [":MyLib"],
)
```

The above call will create hex file with the target name `"main"`, an elf file with the name `"_mainELF"` and an upload script that receives the hex file as it's argument named `"_mainUpload"`.

Additionally the `cpu_frequency_flag` macro is loaded. It simply resolves the applied cpu frequency constraint to the matching symbol definition flag, accessible in the source files
by the c macro `F_CPU`.

#### Unity
###### unity_test
There are two macros unit tests. All can be found in the file
with the label `"@EmbeddedSystemsBuildScripts//Unity:unity.bzl"`. First the `unity_test` macro: It is responsible for creating a test runner, using the ruby shipped with unity. After generating the test runner it creates a cc_binary from that test runner and the provided source file containing the test functions.
```python
unity_test(
    file_name = "MyTest.c"
)
```
The test can then be called like so
```bash
$ bazel test //:MyTest
```

Attributes listed in the `unity_test` call are passed to the internal cc_binary call.

###### mock
With the help of the mock macro you can use CMock to create mock functions for a specified header file.
Currently the corresponding header file has to be exported with the `exports_files` rule from the package that contains it.
You can then define a mock library, containing the header to control and query the mocks state as well as the object file with the mock implementation by
```python
mock(
  name = "MyMock",
  srcs = ["//lib:Functions.h"],
)

unity_test(
  file_name = "MyTest.c",
  deps = [":MyMock", "//lib:MyLib"],
)
```

Note the order of the targets listed in the deps attribute.
This will make sure, that the definitions from MyMock are used instead of production code. Often however it will be better to build a small lib containing only the code under test.
