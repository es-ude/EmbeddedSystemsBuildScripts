package(default_visibility = ["//visibility:public"])

config_setting(
    name = "cpu_8mhz",
    constraint_values = [
        "@{name}//constraints:cpu_8mhz",
        "@{name}//constraints:avr",
    ],
)

config_setting(
    name = "cpu_12mhz",
    constraint_values = [
        "@{name}//constraints:cpu_12mhz",
        "@{name}//constraints:avr",
    ],
)

config_setting(
    name = "no_mcu",
    constraint_values = [
        "@{name}//constraints:avr",
        "@{name}//constraints:no_mcu",
    ],
)

config_setting(
    name = "atmega32u4",
    constraint_values = [
        "@{name}//constraints:atmega32u4",
        "@{name}//constraints:avr",
    ],
)

config_setting(
    name = "atmega64",
    constraint_values = [
        "@{name}//constraints:atmega64",
        "@{name}//constraints:avr",
    ],
)

config_setting(
    name = "avr",
    constraint_values = [
        "@{name}//constraints:avr",
    ],
)