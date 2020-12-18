package(default_visibility=["//visibility:public"])

constraint_value(
    name="avr", constraint_setting="@bazel_tools//platforms:cpu",
)

config_setting(
    name="avr_config", constraint_values=[":avr"],
)

constraint_value(
    name="bare_metal", constraint_setting="@bazel_tools//platforms:os",
)

platform(
    name="avr_common",
    constraint_values=[
        "@AvrToolchain//platforms:bare_metal",
        "@AvrToolchain//platforms:avr",
    ],
)

platform(
    name="Motherboard",
    constraint_values=[
        "@AvrToolchain//platforms/mcu:atmega32u4",
        "@AvrToolchain//platforms/misc:lufa_uart",
        "@AvrToolchain//platforms/misc:lis2de",
        "@AvrToolchain//platforms/misc:has_mrf",
        "@AvrToolchain//platforms/cpu_frequency:8mhz",
        "@AvrToolchain//platforms/board_id:motherboard",
        "@AvrToolchain//platforms/programmer:stk500",
    ],
    parents=[":avr_common"],
)

platform(
    name="ElasticNode_v3",
    constraint_values=[
        "@AvrToolchain//platforms/mcu:atmega64",
        "@AvrToolchain//platforms/misc:hardware_uart",
        "@AvrToolchain//platforms/misc:has_mrf",
        "@AvrToolchain//platforms/cpu_frequency:12mhz",
        "@AvrToolchain//platforms/board_id:elastic_node_v3",
        "@AvrToolchain//platforms/programmer:stk500",
    ],
    parents=[":avr_common"],
)

platform(
    name="ElasticNode_v3_monitor",
    constraint_values=[
        "@AvrToolchain//platforms/cpu_frequency:8mhz",
        "@AvrToolchain//platforms/misc:lufa_uart",
        "@AvrToolchain//platforms/mcu:atmega32u4",
        "@AvrToolchain//platforms/board_id:elastic_node_v3_monitor",
    ],
    parents=[":avr_common"],
)

platform(
    name="ElasticNode_v4",
    constraint_values=[
        "@AvrToolchain//platforms/cpu_frequency:8mhz",
        "@AvrToolchain//platforms/misc:lufa_uart",
        "@AvrToolchain//platforms/misc:fpga_connected",
        "@AvrToolchain//platforms/mcu:at90usb1287",
        "@AvrToolchain//platforms/board_id:elastic_node_v4",
        "@AvrToolchain//platforms/programmer:stk500",
    ],
    parents=[":avr_common"],
)

platform(
    name="ElasticNode_v4_monitor",
    constraint_values=[
        "@AvrToolchain//platforms/cpu_frequency:8mhz",
        "@AvrToolchain//platforms/misc:lufa_uart",
        "@AvrToolchain//platforms/mcu:atmega32u4",
        "@AvrToolchain//platforms/board_id:elastic_node_v4_monitor",
        "@AvrToolchain//platforms/programmer:stk500",
    ],
    parents=[":avr_common"],
)

platform(
    name="ArduinoUno",
    constraint_values=[
        "@AvrToolchain//platforms/cpu_frequency:16mhz",
        "@AvrToolchain//platforms/misc:hardware_uart",
        "@AvrToolchain//platforms/mcu:atmega328p",
        "@AvrToolchain//platforms/board_id:arduino_uno",
        "@AvrToolchain//platforms/programmer:arduino",
    ],
    parents=[":avr_common"],
)

platform(
    name="ArduinoMega",
    constraint_values=[
        "@AvrToolchain//platforms/cpu_frequency:16mhz",
        "@AvrToolchain//platforms/misc:hardware_uart",
        "@AvrToolchain//platforms/mcu:atmega2560",
        "@AvrToolchain//platforms/board_id:arduino_mega",
        "@AvrToolchain//platforms/programmer:wiring",
    ],
    parents=[":avr_common"],
)
