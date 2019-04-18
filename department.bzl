load("@bazel_tools//tools/build_defs/repo:utils.bzl", "workspace_and_buildfile")

def _clone_git_impl(ctx):
    repo_root = ctx.path(".")
    git = ctx.which("git")
    ctx.execute([git, "clone", ctx.attr.url, "."])

#    ctx.file("WORKSPACE", "workspace(name = \"{name}\")".format(name = ctx.name))

_clone_git_impl_attrs = {
    "url": attr.string(),
}

clone_git = repository_rule(
    implementation = _clone_git_impl,
    attrs = _clone_git_impl_attrs,
)
