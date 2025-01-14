# API for X-Decor-libre

X-Decor-libre is mostly self-contained but it allows for limited extension with
a simple API. Not that extensibility is not the main goal of this mod.

The function documentation can be found in the respective source code files
under the header "--[[ API FUNCTIONS ]]".

These are the features:

## Add custom tool enchantments

You can register tools to be able to be enchanted at the enchanting table.

See `src/enchanting.lua` for details.

## Add custom hammers

You can add a custom hammer for repairing tools at the workbench,
using custom stats.

See `src/workbench.lua` for details.

## EXPERIMENTAL: Add cut nodes

You can register "cut" node variants of an existing node which can
be created at the workbench.
This will add thin stairs, half stairs, panels, microcubes, etc.

THIS FEATURE IS EXPERIMENTAL!

See `src/workbench.lua` for details.
