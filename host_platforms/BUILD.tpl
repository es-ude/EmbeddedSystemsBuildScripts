package(default_visibility = ["//visibility:public"])

platform(
    name = "linux_nixos_ide",
    constraint_values = [
        "@{name}//host_constraints:dfu_needs_ask_pass",
        "@{name}//host_constraints:enable_avr_size_injection",
        "@bazel_tools//platforms:linux",
    ],
)
