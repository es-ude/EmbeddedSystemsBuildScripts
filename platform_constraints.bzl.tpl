"""
These macros help keeping a consistent
set of config_setting rules for all constraints
used for platform definitions.
"""

_CONSTRAINT_PREFIX = "@{name}//constraints:"

_MOTHERBOARD_CONSTRAINTS = [
    "cpu_8mhz",
    "lufa_uart",
    "fpga_not_connected",
    "atmega32u4",
]

_ELASTIC_NODE_3_CONSTRAINTS = [
    "cpu_12mhz",
    "hardware_uart",
    "fpga_connected",
    "atmega64",
]

_ELASTIC_NODE_4_CONSTRAINTS = [
    "cpu_8mhz",
    "lufa_uart",
    "fpga_connected",
    "at90usb1287",
]

_PLATFORMS = {
    "Motherboard": _MOTHERBOARD_CONSTRAINTS,
    "ElasticNode3": _ELASTIC_NODE_3_CONSTRAINTS,
    "ElasticNode4": _ELASTIC_NODE_4_CONSTRAINTS,
}

def platform_constraint_list(platform_name):
    return _PLATFORMS[platform_name]

def platform_constraint_list_with_avr(platform_name):
    return platform_constraint_list(platform_name) + ["avr"]

def create_platforms():
    for name in _PLATFORMS:
        native.platform(
            name = name,
            parents = [":AVR"],
            constraint_values = _constraint_list(_PLATFORMS[name]),
        )
    native.platform(
        name = "AVR",
        constraint_values = _constraint_list(["avr"]),
    )

def create_configs():
    all_constraints = []
    for name in _PLATFORMS:
        native.config_setting(
            name = name,
            constraint_values = _constraint_list(_PLATFORMS[name] + ["avr"])
        )
    for key in _PLATFORMS:
        all_constraints += _PLATFORMS[key]
    for constraint in _unique_elements(all_constraints):
        native.config_setting(
            name = constraint,
            constraint_values = _constraint_list([constraint, "avr"])
        )
    native.config_setting(
        name = "avr",
        constraint_values = _constraint_list(["avr"]),
    )

def _unique_elements(some_list):
    result = []
    for index, item in enumerate(some_list):
        if index == some_list.index(item):
            result.append(item)
    return result

def _constraint_list(names):
    return [_CONSTRAINT_PREFIX + constraint for constraint in names]