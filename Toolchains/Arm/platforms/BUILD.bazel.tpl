package(default_visibility = ["//visibility:public"])

constraint_value(
    name = "cortex-m4",
    constraint_setting = "@bazel_tools//platforms:cpu",
)
