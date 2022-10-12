minetest.register_node("nativevillages:savannathrone", {
    description = "Savanna Throne",
    visual_scale = 1,
    mesh = "Savannathrone.b3d",
    tiles = {"texturesavannathrone.png"},
    inventory_image = "asavannathrone.png",
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
	output = "default:bronzeblock",
	recipe = "nativevillages:savannathrone",
})

minetest.register_node("nativevillages:savannavessels", {
    description = "Savanna Vessels",
    visual_scale = 1,
    mesh = "Savannavessels.b3d",
    tiles = {"texturesavannavessels.png"},
    inventory_image = "asavannavessels.png",
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
	output = "default:bronzeblock",
	recipe = "nativevillages:savannavessels",
})

minetest.register_node("nativevillages:savannavshrine", {
    description = "Savanna Shrine",
    visual_scale = 1,
    mesh = "Savannashrine.b3d",
    tiles = {"texturesavannashrine.png"},
    inventory_image = "asavannashrine.png",
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
	output = "default:bronzeblock",
	recipe = "nativevillages:savannashrine",
})

minetest.register_node("nativevillages:savannacorpse", {
    description = "Savanna Corpse",
    visual_scale = 1,
    mesh = "Savannacorpse.b3d",
    tiles = {"texturesavannacorpse.png"},
    inventory_image = "asavannacorpse.png",
    paramtype = "light",
    paramtype2 = "facedir",
    groups = {choppy = 3},
    drawtype = "mesh",
    collision_box = {
        type = "fixed",
        fixed = {
            {-1, -0.5, -0.5, 0.5, 0.1, 1.3},
            --[[{-1, -0.5, -0.5, 0.5, 0.1, 1.3},
            {-1, -0.5, -0.5, 0.5, 0.1, 1.3}]]
        }
    },
    selection_box = {
        type = "fixed",
        fixed = {
            {-1, -0.5, -0.5, 0.5, 0.1, 1.3}
        }
    },
    sounds = default.node_sound_wood_defaults()
})

minetest.register_craft({
	type = "cooking",
	output = "mobs:meat",
	recipe = "nativevillages:savannacorpse",
})