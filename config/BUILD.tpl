load("@{name}//:platform_constraints.bzl", "create_configs")
package(default_visibility = ["//visibility:public"])

create_configs()
