load("@AvrToolchain//platforms:platform_list.bzl", "platforms")

def get_mcu():
    options = {}
    for platform in platforms:
        options["@AvrToolchain//platforms/mcu:{}_config".format(platform)] = platform
    options["//conditions:default"] = "none"
    return select(options)

def get_mcu_as_array():
    options = {}
    for platform in platforms:
        options["@AvrToolchain//platforms/mcu:{}_config".format(platform)] = [platform]
    options["//conditions:default"] = []
    return select(options)
