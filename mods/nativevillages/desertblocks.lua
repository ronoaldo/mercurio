minetest.register_node("nativevillages:hookah", {
    description = "Hookah",
    visual_scale = 1,
    mesh = "Hookah.b3d",
    tiles = {"texturehookah.png"},
    inventory_image = "ahookah.png",
    paramtype = "light",
    paramtype2 = "facedir",
    groups = {choppy = 3},
    drawtype = "mesh",
    collision_box = {
        type = "fixed",
        fixed = {
            {-0.2, -0.5, -0.2, 0.2, 0.5, 0.2},
            --[[{-0.2, -0.5, -0.2, 0.2, 0.5, 0.2},
            {-0.2, -0.5, -0.2, 0.2, 0.5, 0.2}]]
        }
    },
    selection_box = {
        type = "fixed",
        fixed = {
            {-0.2, -0.5, -0.2, 0.2, 0.5, 0.2}
        }
    },
    sounds = default.node_sound_wood_defaults()
})

minetest.register_craft({
	type = "cooking",
	output = "default:bronzeblock",
	recipe = "nativevillages:hookah",
})

minetest.register_node("nativevillages:desertcrpet", {
    description = "Desert Carpet",
    visual_scale = 1,
    mesh = "Desertcarpet.b3d",
    tiles = {"texturedesertcarpet.png"},
    inventory_image = "adesertcarpet.png",
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
	output = "wool:red",
	recipe = "nativevillages:desertcarpet",
})

minetest.register_node("nativevillages:desertcage", {
    description = "Slave Bracelet",
    visual_scale = 1,
    mesh = "Desertcage.b3d",
    tiles = {"texturedesertcage.png"},
    inventory_image = "adesertcage.png",
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
	output = "default:steelblock",
	recipe = "nativevillages:desertcage",
})

minetest.register_node("nativevillages:desertseeds", {
    description = "Desert Seeds",
    visual_scale = 1,
    mesh = "Desertseeds.b3d",
    tiles = {"texturedesertseeds.png"},
    inventory_image = "adesertseeds.png",
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
	output = "farming:bread",
	recipe = "nativevillages:deserseeds",
})