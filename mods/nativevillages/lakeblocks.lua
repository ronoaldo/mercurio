minetest.register_node("nativevillages:fishtrap", {
    description = "Fish Trap",
    visual_scale = 1,
    mesh = "Fishtrap.b3d",
    tiles = {"texturefishtrap.png"},
    inventory_image = "afishtrap.png",
    paramtype = "light",
    paramtype2 = "facedir",
    groups = {choppy = 3},
    drawtype = "mesh",
    collision_box = {
        type = "fixed",
        fixed = {
            {-0.25, -0.5, -0.5, 0.25, 0.12, 0.5},
            --[[{-0.25, -0.5, -0.5, 0.25, 0.12, 0.5},
            {-0.25, -0.5, -0.5, 0.25, 0.12, 0.5}]]
        }
    },
    selection_box = {
        type = "fixed",
        fixed = {
            {-0.25, -0.5, -0.5, 0.25, 0.12, 0.5}
        }
    },
    sounds = default.node_sound_wood_defaults()
})

minetest.register_craft({
	type = "fuel",
	recipe = "nativevillages:fishtrap",
	burntime = 3,
})

minetest.register_node("nativevillages:hangingfish", {
    description = "Hangning Fish",
    visual_scale = 1,
    mesh = "Hangingfish.b3d",
    tiles = {"texturehangingfish.png"},
    inventory_image = "ahangingfish.png",
    paramtype = "light",
    paramtype2 = "facedir",
    groups = {choppy = 3},
    drawtype = "mesh",
    collision_box = {
        type = "fixed",
        fixed = {
            {-1, -0.5, -0.2, 1, 0.9, 0.2},
            --[[{-1, -0.5, -0.2, 1, 0.9, 0.2},
            {-1, -0.5, -0.2, 1, 0.9, 0.2}]]
        }
    },
    selection_box = {
        type = "fixed",
        fixed = {
            {-1, -0.5, -0.2, 1, 0.9, 0.2}
        }
    },
    sounds = default.node_sound_wood_defaults()
})

minetest.register_craft({
	type = "fuel",
	recipe = "nativevillages:hangingfish",
	burntime = 3,
})

minetest.register_craftitem("nativevillages:pearl", {
	description = ("Pearl"),
	inventory_image = "nativevillages_pearl.png",
})