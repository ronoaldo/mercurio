unused_args = false
allow_defined_top = true

globals = {
    "minetest",
    "mercurio",

    -- Mods
    "respawn", "mobs", "unified_inventory"
}

read_globals = {
    string = {fields = {"split"}},
    table = {fields = {"copy", "getn"}},

    -- Builtin
    "vector", "ItemStack",
    "dump", "DIR_DELIM", "VoxelArea", "Settings",

    -- MTG
    "default", "sfinv", "creative",
}
