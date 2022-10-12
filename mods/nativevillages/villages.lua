minetest.register_decoration({
    name = "nativevillages:lakevillage",
    deco_type = "schematic",
    place_on = {"default:dirt", "default:sand"},
    place_offset_y = 0,
    sidelen = 16,
    fill_ratio = 0.00008,
    biomes = {"deciduous_forest_ocean", "grassland_ocean", "deciduous_forest_shore", "coniferous_forest_ocean"},
    y_max = -0.5,
    y_min = -0.5,
    schematic = minetest.get_modpath("nativevillages").."/schematics/lakevillage3_0_180.mts",
    flags = "force_placement",
})

minetest.register_decoration({
    name = "nativevillages:junglevillage",
    deco_type = "schematic",
    place_on = {"default:dirt_with_rainforest_litter"},
    place_offset_y = -4,
    sidelen = 16,
    fill_ratio = 0.0001,
    biomes = {"rainforest", "rainforest_swamp"},
    y_max = 3.5,
    y_min = 2.5,
    schematic = minetest.get_modpath("nativevillages").."/schematics/junglevillage_4_180.mts",
    flags = "force_placement",
})

minetest.register_decoration({
    name = "nativevillages:grasslandvillage",
    deco_type = "schematic",
    place_on = {"default:dirt_with_grass"},
    place_offset_y = -4,
    sidelen = 16,
    fill_ratio = 0.0001,
    biomes = {"grassland", "grassland_dunes", "deciduous_forest_shore"},
    y_max = 3.5,
    y_min = 2.5,
    schematic = minetest.get_modpath("nativevillages").."/schematics/grasslandvillage_4_270.mts",
    flags = "force_placement",
})

minetest.register_decoration({
    name = "nativevillages:savannavillge",
    deco_type = "schematic",
    place_on = {"default:dry_dirt_with_dry_grass"},
    place_offset_y = -4,
    sidelen = 16,
    fill_ratio = 0.0001,
    biomes = {"savanna"},
    y_max = 3.5,
    y_min = 2.5,
    schematic = minetest.get_modpath("nativevillages").."/schematics/savannavillage_4_180.mts",
    flags = "force_placement",
})

minetest.register_decoration({
    name = "nativevillages:desertvillage",
    deco_type = "schematic",
    place_on = {"default:desert_sand", "default:sand"},
    place_offset_y = -4,
    sidelen = 16,
    fill_ratio = 0.0001,
    biomes = {"desert"},
    y_max = 3.5,
    y_min = 2.5,
    schematic = minetest.get_modpath("nativevillages").."/schematics/desertvillage_4_180.mts",
    flags = "force_placement",
})

minetest.register_decoration({
    name = "nativevillages:icevillage",
    deco_type = "schematic",
    place_on = {"default:snowblock"},
    place_offset_y = -4,
    sidelen = 16,
    fill_ratio = 0.0001,
    biomes = {"icesheet", "icesheet_ocean", "tundra", "tundra_ocean", "tundra_highland", },
    y_max = 3.5,
    y_min = 2.5,
    schematic = minetest.get_modpath("nativevillages").."/schematics/icevillage_4_90.mts",
    flags = "force_placement",
})