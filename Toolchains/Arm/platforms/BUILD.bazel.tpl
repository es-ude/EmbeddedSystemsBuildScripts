# package(default_visibility = ["//visibility:public"])

# constraint_value(
#     name = "cortex-m4",
#     constraint_setting = "@bazel_tools//platforms:cpu",
# )
# load("@ArmToolchain//cc_toolchain:cc_toolchain_config.bzl", "cc_toolchain_config")

package(default_visibility=["//visibility:public"])

constraint_value(name="arm", constraint_setting="@bazel_tools//platforms:cpu")

config_setting(name="arm_config")

platform(
    name="arm_common", constraint_values=["@ArmToolchain//platforms:arm",],
)

platform(
    name="arm_ElasticNode",
    constraint_values=[
        "@ArmToolchain//platforms/cpu:cortex-m4",
        "@ArmToolchain//platforms/board_id:arm_ElasticNode",
    ],
    parents=[":arm_common"],
)
