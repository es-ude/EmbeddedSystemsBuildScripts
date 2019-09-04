package(default_visibility = ["//visibility:public"])

constraint_value(
    name = "cortex-m0",
    constraint_setting = "@bazel_tools//platforms:cpu",
)
