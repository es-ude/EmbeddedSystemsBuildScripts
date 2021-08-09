workspace(
    name = "EmbeddedSystemsBuildScripts",
)

http_archive(
    name = "platforms",
    strip_prefix = "platforms-master",
    urls = ["https://github.com/bazelbuild/platforms/archive/master.tar.gz"],
)

load("//Toolchains/Avr:avr.bzl", "avr_toolchain")

avr_toolchain()

load("//Toolchains/Arm:arm.bzl", "arm_toolchain")

arm_toolchain()
