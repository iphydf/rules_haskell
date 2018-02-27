#!/bin/sh
#
# Usage: ghci-repl-wrapper.sh

# The $(basename $PWD) bit is not very nice. But it is not clear how to
# infer relative path to ghci with bazel-* part included.

bazel-$(basename $PWD)/{GHCi} {ARGS}
