package(default_visibility = ["//visibility:public"])

constraint_setting(
    name = "dfu_permission",
)

constraint_value(
    name = "dfu_needs_askpass",
    constraint_setting = "dfu_permission",
)

constraint_value(
    name = "dfu_needs_sudo",
    constraint_setting = "dfu_permission",
)

constraint_setting(
    name = "avr_size_injection",
)

constraint_value(
    name = "enable_avr_size_injection",
    constraint_setting = "avr_size_injection",
)

constraint_value(
    name = "disable_avr_size_injection",
    constraint_setting = "avr_size_injection",
)
