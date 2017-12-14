"""Tools used during build.
"""
def get_build_tools(ctx):
  """Get the set of all build tools we have available.

  Args:
    ctx: Rule context.
  """
  return depset([
    f for bt in ctx.attr.build_tools
      for f in bt.files
  ])

def get_build_tools_path(ctx):
  """Get list of build tools suited for PATH. Useful to make sure that
  GHC can find hsc2hs or cpphs at runtime: even if those files aren't
  expected, user may just be using OPTIONS_GHC to invoke them so they
  should be available.

  Args:
    ctx: Rule context.
  """
  return ":".join(depset([bt.dirname for bt in get_build_tools(ctx)]).to_list())

def get_build_tool(ctx, tool_name):

  """Find the requested build tool from all the build tools we were given.

  Args:
    ctx: Rule context.
    tool_name: Name of the binary we want to find.
  """
  for tool in get_build_tools(ctx):
    if tool.basename == tool_name:
      return tool

  fail("Could not find the '{0}' tool.".format(tool_name))

def get_compiler(ctx):
  """Get the compiler path.

  Args:
    ctx: Rule context.
  """
  # We use allow_single_file with mandatory so this should always
  # exist.
  return get_build_tool(ctx, "ghc")

def get_ghc_pkg(ctx):
  """Get the compiler path.

  Args:
    ctx: Rule context.
  """
  # We use allow_single_file with mandatory so this should always
  # exist.
  return get_build_tool(ctx, "ghc-pkg")

def get_hsc2hs(ctx):
  """Get the hsc2hs tool.

  Args:
    ctx: Rule context.
  """
  return get_build_tool(ctx, "hsc2hs")

def get_cpphs(ctx):
  """Get the cpphs tool.

  Args:
    ctx: Rule context.
  """
  return get_build_tool(ctx, "cpphs")

def get_ar(ctx):
  """Get the ar tool.

  Args:
    ctx: Rule context.
  """
  return get_build_tool(ctx, "ar")
