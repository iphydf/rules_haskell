"""GHCi REPL support"""

load(":tools.bzl",
     "get_ghci"
)

load("@bazel_skylib//:lib.bzl",
     "paths"
)

load(":providers.bzl",
     "HaskellPackageInfo"
)

def _haskell_repl_impl(ctx):
  args = ["-hide-all-packages"]

  # Generate options that bring "prebuilt dependencies" in scope.
  args += ["-package " + dep for dep in ctx.attr.prebuilt_dependencies]

  # Generate options that bring Haskell dependencies in scope.
  for dep in ctx.attr.deps:
    if HaskellPackageInfo in dep:
      # I'm not sure about exact logic here. Should we make visible only
      # direct dependencies or also all transitive dependencies? I think
      # Stack/Cabal only make direct dependencies visible, and one should
      # add transitive dependencies explicitly.
      pkg = dep[HaskellPackageInfo]
      args += ["-package {0}".format(pkg.name)]
      args += ["-package-db {0}".format(c.dirname) for c in pkg.caches.to_list()]

  ctx.actions.expand_template(
    template = ctx.file._ghci_repl_wrapper,
    output = ctx.outputs.executable,
    substitutions = {
      "{GHCi}": get_ghci(ctx).path,
      "{ARGS}": " ".join(args),
    },
    is_executable = True,
  )

  return [DefaultInfo(
    executable = ctx.outputs.executable,
    runfiles = ctx.runfiles(files=ctx.files.deps),
  )]

haskell_repl = rule(
  _haskell_repl_impl,
  executable = True,
  attrs = {
    "deps": attr.label_list(
      doc = "List of Haskell libraries to be available in the REPL.",
    ),
    "prebuilt_dependencies": attr.string_list(
      doc = "Non-Bazel supplied Cabal dependencies.",
    ),
    "_ghci_repl_wrapper": attr.label(
      allow_single_file = True,
      default = Label("@io_tweag_rules_haskell//haskell:ghci-repl-wrapper.sh"),
    ),
  },
  toolchains = ["@io_tweag_rules_haskell//haskell:toolchain"],
)
"""Produce a script that calls GHCi with all specified dependencies in
scope.

Example of use:

```
$ bazel build test:my-repl
$ bazel-bin/test/my-repl
```
"""
