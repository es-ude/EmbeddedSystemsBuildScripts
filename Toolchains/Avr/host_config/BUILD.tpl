package(default_visibility = ["//visibility:public"])

config_setting(
    name = "enable_avr_size_injection",
    define_values = {
        "enable_avr_size_injection": "true",
    },
)

config_setting(
    name = "dfu_needs_sudo",
    define_values = {
        "dfu_needs_sudo": "true",
    },
)

config_setting(
    name = "dfu_needs_ask_pass",
    define_values = {
        "dfu_needs_ask_pass": "true",
    },
)
