unused_args = false
allow_defined_top = true

globals = {
    "minetest",
    "airutils",
    "player_api",
    "player_monoids",
}

read_globals = {
    string = {fields = {"split"}},
    table = {fields = {"copy", "getn"}},

    -- Builtin
    "vector", "ItemStack",
    "dump", "DIR_DELIM", "VoxelArea",

    -- MTG
    "default", "sfinv", "creative",
}
