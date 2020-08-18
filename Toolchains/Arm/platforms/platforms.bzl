load("//Toolchains/Arm:common_definitions.bzl", "ARM_RESOURCE_PREFIX")

def _write_cpu_constraints(repository_ctx, cpu_list):
    _write_constraints(repository_ctx, "cpu", cpu_list, "platforms/cpu/BUILD")

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
    _write_cpu_constraints(repository_ctx, repository_ctx.attr.cpu_list)
    _write_constraints(
        repository_ctx,
        "board_id",
        [
            "arm_ElasticNode"
        ],
        "platforms/board_id/BUILD",
    )
    repository_ctx.template(
        "platforms/BUILD.bazel.tpl",
        paths[ARM_RESOURCE_PREFIX + ":platforms/BUILD.bazel.tpl"]
    )