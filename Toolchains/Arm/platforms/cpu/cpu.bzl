load("@ArmToolchain//platforms:platform_list.bzl", "platforms")

def get_cpu():
    options = {}
    for platform in platforms:
        options["@ArmToolchain//platforms/cpu:{}_config".format(platform)] = platform
    options["//conditions:default"] = "none"
    return select(options)

def get_cpu_as_array():
    options = {}
    for platform in platforms:
        options["@ArmToolchain//platforms/cpu:{}_config".format(platform)] = [platform]
    options["//conditions:default"] = []
    return select(options)
