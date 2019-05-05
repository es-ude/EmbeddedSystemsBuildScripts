load("@{name}//:platform_constraints.bzl", "create_platforms")

package(default_visibility = ["//visibility:public"])

create_platforms()