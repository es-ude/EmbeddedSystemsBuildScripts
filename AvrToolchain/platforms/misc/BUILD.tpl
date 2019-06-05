package(default_visibility = ["//visibility:public"])

constraint_setting(name = "fpga")
constraint_setting(name = "mrf")
constraint_setting(name = "uart")

constraint_value(
    name = "hardware_uart",
    constraint_setting = ":uart",
)

constraint_value(
    name = "lufa_uart",
    constraint_setting = ":uart",
)

constraint_value(
    name = "has_mrf",
    constraint_setting = ":mrf"
)

constraint_setting(
    name = "accelerometer",
)

constraint_value(
    name = "lis2de",
    constraint_setting = ":accelerometer",
)

constraint_value(
    name = "fpga_connected",
    constraint_setting = ":fpga",
)