minetest.register_node("nativevillages:driedpeople", {
	description = "Dried Human Remains",
	tiles = {
		"nativevillages_driedpeople_top.png",
		"nativevillages_driedpeople_bottom.png",
		"nativevillages_driedpeople_right.png",
		"nativevillages_driedpeople_left.png",
		"nativevillages_driedpeople_back.png",
		"nativevillages_driedpeople_front.png"
	},
	groups = {crumbly = 3},
	drop = "nativevillages:driedhumanmeat 9",
	sounds = default.node_sound_dirt_defaults(),
})

minetest.register_craft({
	output = "nativevillages:driedpeople",
	recipe = {
		{"nativevillages:driedhumanmeat", "nativevillages:driedhumanmeat", "nativevillages:driedhumanmeat"},
		{"nativevillages:driedhumanmeat", "nativevillages:driedhumanmeat", "nativevillages:driedhumanmeat"},
		{"nativevillages:driedhumanmeat", "nativevillages:driedhumanmeat", "nativevillages:driedhumanmeat"},
	}
})


minetest.register_craftitem(":nativevillages:driedhumanmeat", {
	description = ("Dried Human Meat"),
	inventory_image = "nativevillages_driedhumanmeat.png",
	on_use = minetest.item_eat(2),
	groups = {mushroom = 1, snappy = 3, attached_node = 1, flammable = 1},
})


minetest.register_node("nativevillages:cannibalshrine", {
    description = "Cannibal Shrine",
    visual_scale = 1,
    mesh = "Cannibalshrine.b3d",
    tiles = {"texturecannibalshrine.png"},
    inventory_image = "acannibalshrine.png",
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
	recipe = "nativevillages:cannibalshrine",
})