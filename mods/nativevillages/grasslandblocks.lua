minetest.register_node("nativevillages:grasslandaltar", {
    description = "Altar",
    visual_scale = 1,
    mesh = "Grasslandaltar.b3d",
    tiles = {"texturegrasslandaltar.png"},
    inventory_image = "agrasslandaltar.png",
    paramtype = "light",
    paramtype2 = "facedir",
    groups = {choppy = 3},
    drawtype = "mesh",
    collision_box = {
        type = "fixed",
        fixed = {
            {-0.5, -0.5, -0.5, 0.5, 0.5, 0.5},
            --[[{-0.5, -0.5, -0.5, 0.5, 0.5, 0.5},
            {-0.5, -0.5, -0.5, 0.5, 0.5, 0.5}]]
        }
    },
    selection_box = {
        type = "fixed",
        fixed = {
            {-0.5, -0.5, -0.5, 0.5, 0.5, 0.5}
        }
    },
    sounds = default.node_sound_wood_defaults()
})

minetest.register_craft({
	type = "cooking",
	output = "default:cobble",
	recipe = "nativevillages:grasslandaltar",
})

minetest.register_node("nativevillages:grasslandbarrel", {
    description = "Barrel",
    visual_scale = 1,
    mesh = "Grasslandbarrel.b3d",
    tiles = {"texturegrasslandbarrel.png"},
    inventory_image = "agrasslandbarrel.png",
    paramtype = "light",
    paramtype2 = "facedir",
    groups = {choppy = 3},
    drawtype = "mesh",
    collision_box = {
        type = "fixed",
        fixed = {
            {-0.5, -0.5, -0.5, 0.5, 1, 0.5},
            --[[{-0.5, -0.5, -0.5, 0.5, 1, 0.5},
            {-0.5, -0.5, -0.5, 0.5, 1, 0.5}]]
        }
    },
    selection_box = {
        type = "fixed",
        fixed = {
            {-0.5, -0.5, -0.5, 0.5, 1, 0.5}
        }
    },
    sounds = default.node_sound_wood_defaults()
})

minetest.register_craft({
	type = "cooking",
	output = "default:cobble",
	recipe = "nativevillages:grasslandbarrel",
})

minetest.register_node("nativevillages:cowdropping", {
    description = "Cow Dropping",
    visual_scale = 1,
    mesh = "Cowdropping.b3d",
    tiles = {"texturecowdropping.png"},
    inventory_image = "acowdropping.png",
    paramtype = "light",
    paramtype2 = "facedir",
    groups = {choppy = 3},
    drawtype = "mesh",
    collision_box = {
        type = "fixed",
        fixed = {
            {-0.5, -0.5, -0.5, 0.5, -0.45, 0.5},
            --[[{-0.5, -0.5, -0.5, 0.5, -0.45, 0.5},
            {-0.5, -0.5, -0.5, 0.5, -0.45, 0.5}]]
        }
    },
    selection_box = {
        type = "fixed",
        fixed = {
            {-0.5, -0.5, -0.5, 0.5, -0.45, 0.5}
        }
    },
    sounds = default.node_sound_wood_defaults()
})

minetest.register_craft({
	type = "cooking",
	output = "default:coal_lump",
	recipe = "nativevillages:cowdropping",

})