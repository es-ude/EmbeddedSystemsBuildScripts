package(default_visibility = ["//visibility:public"])

constraint_setting(name = "flashing_method")

constraint_value(
    name = "dfu_programmer",
    constraint_setting = "flashing_method",
)

constraint_value(
    name = "avrdude",
    constraint_setting = "flashing_method",
)

constraint_setting(name = "fpga")

constraint_value(
    name = "fpga_connected",
    constraint_setting = ":fpga",
)

constraint_value(
    name = "fpga_not_connected",
    constraint_setting = ":fpga",
)

constraint_setting(name = "uart")

constraint_value(
    name = "lufa_uart",
    constraint_setting = ":uart",
)

constraint_value(
    name = "software_uart",
    constraint_setting = ":uart",
)

constraint_value(
    name = "hardware_uart",
    constraint_setting = ":uart",
)

constraint_setting(name = "cpu_frequency")

constraint_value(
    name = "cpu_12mhz",
    constraint_setting = ":cpu_frequency",
)

constraint_value(
    name = "cpu_8mhz",
    constraint_setting = ":cpu_frequency",
)

constraint_value(
    name = "cpu_16mhz",
    constraint_setting = ":cpu_frequency",
)

constraint_setting(name = "uart_baud_rate")

constraint_value(
    name = "uart_9600",
    constraint_setting = ":uart_baud_rate",
)

constraint_setting(name = "mcu")

constraint_value(
    name = "atmega64",
    constraint_setting = ":mcu",
)

constraint_value(
    name = "at90usb1287",
    constraint_setting = ":mcu",
)

constraint_value(
    name = "none",
    constraint_setting = ":mcu",
)

constraint_value(
    name = "atmega32u4",
    constraint_setting = ":mcu",
)

constraint_value(
    name = "atmega328p",
    constraint_setting = ":mcu",
)

constraint_value(
    name = "atmega2560",
    constraint_setting = ":mcu",
)

constraint_value(
    name = "no_mcu",
    constraint_setting = ":mcu",
)

constraint_value(
    name = "avr",
    constraint_setting = "@bazel_tools//platforms:cpu",
)
