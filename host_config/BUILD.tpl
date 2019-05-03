package(default_visibility = ["//visibility:public"])

config_setting(
    name = "dfu_needs_askpass_via_constraints",
    constraint_values = [
        "@{name}//host_constraints:dfu_needs_askpass",
    ],
)

config_setting(
    name = "dfu_needs_askpass_via_defines",
    define_values = {
        "dfu_needs_askpass": "true",
    }
)

config_setting(
    name = "dfu_needs_sudo_via_constraints",
    constraint_values = [
        "@{name}//host_constraints:dfu_needs_sudo",
    ],
)

config_setting(
    name = "dfu_needs_sudo_via_defines",
    define_values = {
        "dfu_needs_sudo": "true",
    }
)

config_setting(
    name = "enable_avr_size_injection_constraints",
    constraint_values = [
        "@{name}//host_constraints:enable_avr_size_injection",
        "@{name}//constraints:avr",
    ],
)

config_setting(
    name = "enable_avr_size_injection_via_defines",
    define_values = {
        "enable_avr_size_injection": "true",
    },
    constraint_values = [
        "@{name}//constraints:avr",
    ]
)

"""
Using the below alias we can 'or'-combine several select statements.
The define version of the config_settings is used until we figure out
how exactly to consume constraints from host_platforms, i.e. until this
feature is implemented and/or completely documented.
Until then use the "--define key=value" syntax on command line to enable the injection.
The default condition can be set to an arbitrary item of the rest of the conditions, it won't
be selected ever.
"""
alias(
    name = "enable_avr_size_injection",
    actual = select({
        ":enable_avr_size_injection_constraints": ":enable_avr_size_injection_constraints",
        ":enable_avr_size_injection_via_defines": ":enable_avr_size_injection_via_defines",
        "//conditions:default": ":enable_avr_size_injection_via_defines",
    }),
)

alias(
    name = "dfu_needs_sudo",
    actual = select({
        ":dfu_needs_sudo_via_constraints": ":dfu_needs_sudo_via_constraints",
        ":dfu_needs_sudo_via_defines": ":dfu_needs_sudo_via_defines",
        "//conditions:default": ":dfu_needs_sudo_via_defines",
    })
)

config_setting(
    name = "disable_avr_size_injection",
    constraint_values = [
        "@{name}//host_constraints:disable_avr_size_injection",
    ],
)

alias(
    name = "dfu_needs_askpass",
    actual = select({
        ":dfu_needs_askpass_via_constraints": ":dfu_needs_askpass_via_constraints",
        ":dfu_needs_askpass_via_defines": ":dfu_needs_askpass_via_defines",
        "//conditions:default": ":dfu_needs_askpass_via_defines"
    })
)
