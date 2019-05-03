package(default_visibility = ["//visibility:public"])

_MOTHERBOARD_CONSTRAINTS = [
    "@{name}//constraints:cpu_8mhz",
    "@{name}//constraints:lufa_uart",
    "@{name}//constraints:fpga_not_connected",
    "@{name}//constraints:atmega32u4",
]

_ELASTIC_NODE_CONSTRAINTS = [
    "@{name}//constraints:cpu_12mhz",
    "@{name}//constraints:hardware_uart",
    "@{name}//constraints:fpga_connected",
    "@{name}//constraints:atmega64",
]

platform(
    name = "AVR",
    constraint_values = [
        "@{name}//constraints:avr",
    ]
)

platform(
    name = "Motherboard",
    parents = [":AVR"],
    constraint_values = _MOTHERBOARD_CONSTRAINTS,
)

platform(
    name = "ElasticNode",
    parents = [":AVR"],
    constraint_values = _ELASTIC_NODE_CONSTRAINTS,
)
