def _write_mcu_constraints(repository_ctx, mcu_list):
    _write_constraints(repository_ctx, "mcu", mcu_list, "platforms/mcu/BUILD")

def _write_cpu_frequency_constraints(repository_ctx, cpu_frequency_list):
    _write_constraints(repository_ctx, "cpu_frequency", cpu_frequency_list, "platforms/cpu_frequency/BUILD")

def _write_constraints(repository_ctx, setting, constraint_list, path):
    result = """package(default_visibility = ["//visibility:public"])

constraint_setting(name = "{}")
        """.format(setting)
    for constraint in constraint_list:
        result += """
constraint_value(name = "{constraint}", constraint_setting = ":{setting}")
config_setting(name = "{constraint}_config", constraint_values = ["{constraint}"])
        """.format(constraint = constraint, setting = setting)
    repository_ctx.file(path, result)

def write_constraints(repository_ctx, paths):
    _write_cpu_frequency_constraints(repository_ctx, ["{}mhz".format(x) for x in range(1, 32)])
    _write_mcu_constraints(repository_ctx, repository_ctx.attr.mcu_list)
    repository_ctx.template(
        "platforms/cpu_frequency/cpu_frequency.bzl",
        paths["@EmbeddedSystemsBuildScripts//Toolchains/Avr:platforms/cpu_frequency/cpu_frequency.bzl.tpl"],
    )
    _write_constraints(
        repository_ctx,
        "uploader",
        [
            "dfu_programmer",
            "avrdude",
        ],
        "platforms/uploader/BUILD",
    )
    _write_constraints(
        repository_ctx,
        "board_id",
        [
            "motherboard",
            "elastic_node_v3",
            "elastic_node_v3_monitor",
            "elastic_node_v4",
            "elastic_node_v4_monitor",
            "arduino_uno",
            "arduino_mega",
        ],
        "platforms/board_id/BUILD",
    )
    _write_constraints(
        repository_ctx,
        "programmer",
        [
            "arduino",
            "wiring",
            "stk500",
        ],
        "platforms/programmer/BUILD",
    )
    repository_ctx.template("platforms/misc/BUILD", paths["@EmbeddedSystemsBuildScripts//Toolchains/Avr:platforms/misc/BUILD.tpl"])
    repository_ctx.template("platforms/BUILD", paths["@EmbeddedSystemsBuildScripts//Toolchains/Avr:platforms/BUILD.tpl"])
