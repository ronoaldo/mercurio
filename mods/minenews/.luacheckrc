unused_args = false
allow_defined_top = true

globals = {
    "minetest",
}

read_globals = {
    string = {fields = {"split"}},
    table = {fields = {"copy", "getn"}},

    -- Builtin
    "vector", "ItemStack",
    "dump", "DIR_DELIM", "VoxelArea", "Settings",
    "PcgRandom",

    -- MTG
    "default", "sfinv", "creative",

    -- Deps
    "md2f"
}