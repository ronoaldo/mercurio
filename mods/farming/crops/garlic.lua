
local S = farming.translate

-- garlic clove
minetest.register_craftitem("farming:garlic_clove", {
	description = S("Garlic clove"),
	inventory_image = "crops_garlic_clove.png",
	groups = {compostability = 35, seed = 2, food_garlic_clove = 1, flammable = 3},
	on_place = function(itemstack, placer, pointed_thing)
		return farming.place_seed(itemstack, placer, pointed_thing, "farming:garlic_1")
	end
})

-- garlic bulb
minetest.register_craftitem("farming:garlic", {
	description = S("Garlic"),
	inventory_image = "crops_garlic.png",
	on_use = minetest.item_eat(1),
	groups = {food_garlic = 1, flammable = 3, compostability = 55}
})

minetest.register_craft({
	output = "farming:garlic_clove 8",
	recipe = {{"farming:garlic"}}
})

minetest.register_craft({
	output = "farming:garlic",
	recipe = {
		{"farming:garlic_clove", "farming:garlic_clove", "farming:garlic_clove"},
		{"farming:garlic_clove", "", "farming:garlic_clove"},
		{"farming:garlic_clove", "farming:garlic_clove", "farming:garlic_clove"}
	}
})

-- garlic braid
minetest.register_node("farming:garlic_braid", {
	description = S("Garlic Braid"),
	inventory_image = "crops_garlic_braid.png",
	wield_image = "crops_garlic_braid.png",
	drawtype = "nodebox",
	use_texture_alpha = "clip",
	paramtype = "light",
	paramtype2 = "facedir",
	tiles = {
		"crops_garlic_braid_top.png",
		"crops_garlic_braid.png",
		"crops_garlic_braid_side.png^[transformFx",
		"crops_garlic_braid_side.png",
		"crops_garlic_braid.png",
		"crops_garlic_braid.png"
	},
	groups = {vessel = 1, dig_immediate = 3, flammable = 3, compostability = 65},
	sounds = farming.sounds.node_sound_leaves_defaults(),
	node_box = {
		type = "fixed",
		fixed = {
			{-0.1875, -0.5, 0.5, 0.1875, 0.5, 0.125}
		}
	}
})

minetest.register_craft({
	output = "farming:garlic_braid",
	recipe = {
		{"farming:garlic", "farming:garlic", "farming:garlic"},
		{"farming:garlic", "farming:garlic", "farming:garlic"},
		{"farming:garlic", "farming:garlic", "farming:garlic"}
	}
})

minetest.register_craft({
	type = "shapeless",
	output = "farming:garlic 9",
	recipe = {"farming:garlic_braid"}
})

-- crop definition
local def = {
	drawtype = "plantlike",
	tiles = {"crops_garlic_plant_1.png"},
	paramtype = "light",
	paramtype2 = "meshoptions",
	place_param2 = 3,
	sunlight_propagates = true,
	waving = 1,
	walkable = false,
	buildable_to = true,
	drop = "",
	selection_box = farming.select,
	groups = {
		handy = 1, snappy = 3, flammable = 3, plant = 1, attached_node = 1,
		not_in_creative_inventory = 1, growing = 1
	},
	sounds = farming.sounds.node_sound_leaves_defaults()
}

-- stage 1
minetest.register_node("farming:garlic_1", table.copy(def))

-- stage 2
def.tiles = {"crops_garlic_plant_2.png"}
minetest.register_node("farming:garlic_2", table.copy(def))

-- stage 3
def.tiles = {"crops_garlic_plant_3.png"}
minetest.register_node("farming:garlic_3", table.copy(def))

-- stage 4
def.tiles = {"crops_garlic_plant_4.png"}
minetest.register_node("farming:garlic_4", table.copy(def))

-- stage 5
def.tiles = {"crops_garlic_plant_5.png"}
def.groups.growing = nil
def.selection_box = farming.select_final
def.drop = {
	items = {
		{items = {"farming:garlic 3"}, rarity = 1},
		{items = {"farming:garlic"}, rarity = 2},
		{items = {"farming:garlic"}, rarity = 5}
	}
}
minetest.register_node("farming:garlic_5", table.copy(def))

-- add to registered_plants
farming.registered_plants["farming:garlic"] = {
	crop = "farming:garlic",
	seed = "farming:garlic_clove",
	minlight = farming.min_light,
	maxlight = farming.max_light,
	steps = 5
}

-- mapgen
minetest.register_decoration({
	deco_type = "simple",
	place_on = {"default:dirt_with_grass", "mcl_core:dirt_with_grass"},
	sidelen = 16,
	noise_params = {
		offset = 0,
		scale = farming.garlic,
		spread = {x = 100, y = 100, z = 100},
		seed = 467,
		octaves = 3,
		persist = 0.6
	},
	y_min = 3,
	y_max = 35,
	decoration = "farming:garlic_5",
	spawn_by = "group:tree",
	num_spawn_by = 1
})
