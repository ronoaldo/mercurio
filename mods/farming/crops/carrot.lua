
--[[
	Original textures from PixelBox texture pack
	https://forum.minetest.net/viewtopic.php?id=4990
]]

local S = farming.translate
local a = farming.recipe_items

-- carrot
minetest.register_craftitem("farming:carrot", {
	description = S("Carrot"),
	inventory_image = "farming_carrot.png",
	groups = {compostability = 48, seed = 2, food_carrot = 1, flammable = 2},
	on_place = function(itemstack, placer, pointed_thing)
		return farming.place_seed(itemstack, placer, pointed_thing, "farming:carrot_1")
	end,
	on_use = minetest.item_eat(4)
})

-- carrot juice
minetest.register_craftitem("farming:carrot_juice", {
	description = S("Carrot Juice"),
	inventory_image = "farming_carrot_juice.png",
	on_use = minetest.item_eat(4, "vessels:drinking_glass"),
	groups = {vessel = 1, drink = 1}
})

minetest.register_craft({
	output = "farming:carrot_juice",
	recipe = {
		{a.juicer},
		{"group:food_carrot"},
		{"vessels:drinking_glass"}
	},
	replacements = {
		{"group:food_juicer", "farming:juicer"}
	}
})

-- golden carrot
minetest.register_craftitem("farming:carrot_gold", {
	description = S("Golden Carrot"),
	inventory_image = "farming_carrot_gold.png",
	on_use = minetest.item_eat(10)
})

minetest.register_craft({
	output = "farming:carrot_gold",
	recipe = {{"group:food_carrot", "default:gold_lump"}}
})

-- carrot definition
local def = {
	drawtype = "plantlike",
	tiles = {"farming_carrot_1.png"},
	paramtype = "light",
	sunlight_propagates = true,
	walkable = false,
	buildable_to = true,
	drop = "",
	waving = 1,
	selection_box = farming.select,
	groups = {
		handy = 1, snappy = 3, flammable = 2, plant = 1, attached_node = 1,
		not_in_creative_inventory = 1, growing = 1
	},
	sounds = farming.sounds.node_sound_leaves_defaults()
}


-- stage 1
minetest.register_node("farming:carrot_1", table.copy(def))

-- stage 2
def.tiles = {"farming_carrot_2.png"}
minetest.register_node("farming:carrot_2", table.copy(def))

-- stage 3
def.tiles = {"farming_carrot_3.png"}
minetest.register_node("farming:carrot_3", table.copy(def))

-- stage 4
def.tiles = {"farming_carrot_4.png"}
minetest.register_node("farming:carrot_4", table.copy(def))

-- stage 5
def.tiles = {"farming_carrot_5.png"}
minetest.register_node("farming:carrot_5", table.copy(def))

-- stage 6
def.tiles = {"farming_carrot_6.png"}
minetest.register_node("farming:carrot_6", table.copy(def))

-- stage 7
def.tiles = {"farming_carrot_7.png"}
def.drop = {
	items = {
		{items = {"farming:carrot"}, rarity = 1},
		{items = {"farming:carrot 2"}, rarity = 3}
	}
}
minetest.register_node("farming:carrot_7", table.copy(def))

-- stage 8 (final)
def.tiles = {"farming_carrot_8.png"}
def.groups.growing = nil
def.selection_box = farming.select_final
def.drop = {
	items = {
		{items = {"farming:carrot 2"}, rarity = 1},
		{items = {"farming:carrot 3"}, rarity = 2}
	}
}
minetest.register_node("farming:carrot_8", table.copy(def))

-- add to registered_plants
farming.registered_plants["farming:carrot"] = {
	crop = "farming:carrot",
	seed = "farming:carrot",
	minlight = farming.min_light,
	maxlight = farming.max_light,
	steps = 8
}

-- mapgen
local mg = farming.mapgen == "v6"

def = {
	y_max = mg and 30 or 20,
	near = mg and "group:water" or nil,
	num = mg and 1 or -1,
}

minetest.register_decoration({
	deco_type = "simple",
	place_on = {"default:dirt_with_grass", "mcl_core:dirt_with_grass"},
	sidelen = 16,
	noise_params = {
		offset = 0,
		scale = farming.carrot,
		spread = {x = 100, y = 100, z = 100},
		seed = 890,
		octaves = 3,
		persist = 0.6
	},
	y_min = 1,
	y_max = def.y_max,
	decoration = "farming:carrot_8",
	spawn_by = def.near,
	num_spawn_by = def.num
})
