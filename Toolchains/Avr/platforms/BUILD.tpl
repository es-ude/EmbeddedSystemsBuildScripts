package(default_visibility = ["//visibility:public"])

constraint_value(
    name = "avr",
    constraint_setting = "@bazel_tools//platforms:cpu",
)

config_setting(
    name = "avr_config",
    constraint_values = [
        ":avr",
    ]
)

constraint_value(
    name = "bare_metal",
    constraint_setting = "@bazel_tools//platforms:os"
)

platform(
    name = "avr_common",
    constraint_values = [
        "@Toolchains_Avr//platforms:bare_metal",
        "@Toolchains_Avr//platforms:avr"
    ]
)

platform(
    name = "Motherboard",
    constraint_values = [
        "@Toolchains_Avr//platforms/mcu:atmega32u4",
        "@Toolchains_Avr//platforms/misc:lufa_uart",
        "@Toolchains_Avr//platforms/misc:lis2de",
        "@Toolchains_Avr//platforms/misc:has_mrf",
        "@Toolchains_Avr//platforms/cpu_frequency:8mhz",
        "@Toolchains_Avr//platforms/board_id:motherboard",
    ],
    parents = [":avr_common"]
)

platform(
    name = "ElasticNode_v3",
    constraint_values = [
        "@Toolchains_Avr//platforms/mcu:atmega64",
        "@Toolchains_Avr//platforms/misc:hardware_uart",
        "@Toolchains_Avr//platforms/misc:has_mrf",
        "@Toolchains_Avr//platforms/cpu_frequency:12mhz",
        "@Toolchains_Avr//platforms/board_id:elastic_node_v3"
    ],
    parents = [":avr_common"]
)

platform(
    name = "ElasticNode_v4",
    constraint_values = [
            "@Toolchains_Avr//platforms/cpu_frequency:8mhz",
            "@Toolchains_Avr//platforms/misc:lufa_uart",
            "@Toolchains_Avr//platforms/misc:fpga_connected",
            "@Toolchains_Avr//platforms/mcu:at90usb1287",
            "@Toolchains_Avr//platforms/board_id:elastic_node_v4",
    ],
    parents = [":avr_common"],
)

platform(
    name = "ArduinoUno",
    constraint_values = [
        "@Toolchains_Avr//platforms/cpu_frequency:16mhz",
        "@Toolchains_Avr//platforms/misc:hardware_uart",
        "@Toolchains_Avr//platforms/mcu:atmega328p",
        "@Toolchains_Avr//platforms/board_id:arduino_uno"
    ],
    parents = [":avr_common"],
)

platform(
    name = "ArduinoMega",
    constraint_values = [
        "@Toolchains_Avr//platforms/cpu_frequency:16mhz",
        "@Toolchains_Avr//platforms/misc:hardware_uart",
        "@Toolchains_Avr//platforms/mcu:atmega2560",
        "@Toolchains_Avr//platforms/board_id:arduino_mega_config",
    ],
    parents = [":avr_common"],
)



