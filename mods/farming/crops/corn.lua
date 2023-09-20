
--[[
	Original textures from GeMinecraft
	http://www.minecraftforum.net/forums/mapping-and-modding/minecraft-mods/wip-mods/1440575-1-2-5-generation-minecraft-beta-1-2-farming-and
]]

local S = farming.translate
local a = farming.recipe_items

-- corn
minetest.register_craftitem("farming:corn", {
	description = S("Corn"),
	inventory_image = "farming_corn.png",
	groups = {compostability = 45, seed = 2, food_corn = 1, flammable = 2},
	on_place = function(itemstack, placer, pointed_thing)
		return farming.place_seed(itemstack, placer, pointed_thing, "farming:corn_1")
	end,
	on_use = minetest.item_eat(3)
})

-- corn on the cob (texture by TenPlus1)
minetest.register_craftitem("farming:corn_cob", {
	description = S("Corn on the Cob"),
	inventory_image = "farming_corn_cob.png",
	groups = {compostability = 65, food_corn_cooked = 1, flammable = 2},
	on_use = minetest.item_eat(5)
})

minetest.register_craft({
	type = "cooking",
	cooktime = 10,
	output = "farming:corn_cob",
	recipe = "group:food_corn"
})

-- popcorn
minetest.register_craftitem("farming:popcorn", {
	description = S("Popcorn"),
	inventory_image = "farming_popcorn.png",
	groups = {compostability = 55, food_popcorn = 1, flammable = 2},
	on_use = minetest.item_eat(4)
})

minetest.register_craft({
	output = "farming:popcorn",
	recipe = {
		{"group:food_oil", "group:food_corn", a.pot}
	},
	replacements = {
		{"group:food_pot", "farming:pot"},
		{"group:food_oil", "vessels:glass_bottle"}
	}
})

-- cornstarch
minetest.register_craftitem("farming:cornstarch", {
	description = S("Cornstarch"),
	inventory_image = "farming_cornstarch.png",
	groups = {food_cornstarch = 1, food_gelatin = 1, flammable = 2, compostability = 65}
})

minetest.register_craft({
	output = "farming:cornstarch",
	recipe = {
		{a.mortar_pestle, "group:food_corn_cooked", a.baking_tray},
		{"", "group:food_bowl", ""},
	},
	replacements = {
		{"group:food_mortar_pestle", "farming:mortar_pestle"},
		{"group:food_baking_tray", "farming:baking_tray"}
	}
})

-- ethanol (thanks to JKMurray for this idea)
minetest.register_node("farming:bottle_ethanol", {
	description = S("Bottle of Ethanol"),
	drawtype = "plantlike",
	tiles = {"farming_bottle_ethanol.png"},
	inventory_image = "farming_bottle_ethanol.png",
	wield_image = "farming_bottle_ethanol.png",
	paramtype = "light",
	is_ground_content = false,
	walkable = false,
	selection_box = {
		type = "fixed",
		fixed = {-0.25, -0.5, -0.25, 0.25, 0.3, 0.25}
	},
	groups = {vessel = 1, dig_immediate = 3, attached_node = 1},
	sounds = farming.sounds.node_sound_glass_defaults()
})

minetest.register_craft( {
	output = "farming:bottle_ethanol",
	recipe = {
		{"group:food_corn", "group:food_corn", "group:food_corn"},
		{"group:food_corn", a.glass_bottle, "group:food_corn"},
		{"group:food_corn", "group:food_corn", "group:food_corn"}
	}
})

minetest.register_craft({
	type = "fuel",
	recipe = "farming:bottle_ethanol",
	burntime = 80,
	replacements = {{"farming:bottle_ethanol", a.glass_bottle}}
})

-- corn definition
local def = {
	drawtype = "plantlike",
	tiles = {"farming_corn_1.png"},
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
minetest.register_node("farming:corn_1", table.copy(def))

-- stage 2
def.tiles = {"farming_corn_2.png"}
minetest.register_node("farming:corn_2", table.copy(def))

-- stage 3
def.tiles = {"farming_corn_3.png"}
minetest.register_node("farming:corn_3", table.copy(def))

-- stage 4
def.tiles = {"farming_corn_4.png"}
minetest.register_node("farming:corn_4", table.copy(def))

-- stage 5
def.tiles = {"farming_corn_5.png"}
minetest.register_node("farming:corn_5", table.copy(def))

-- stage 6
def.tiles = {"farming_corn_6.png"}
def.visual_scale = 1.9
minetest.register_node("farming:corn_6", table.copy(def))

-- stage 7
def.tiles = {"farming_corn_7.png"}
def.drop = {
	items = {
		{items = {"farming:corn"}, rarity = 1},
		{items = {"farming:corn"}, rarity = 2},
		{items = {"farming:corn"}, rarity = 3}
	}
}
minetest.register_node("farming:corn_7", table.copy(def))

-- stage 8 (final)
def.tiles = {"farming_corn_8.png"}
def.groups.growing = nil
def.selection_box = farming.select_final
def.drop = {
	items = {
		{items = {"farming:corn 2"}, rarity = 1},
		{items = {"farming:corn 2"}, rarity = 2},
		{items = {"farming:corn 2"}, rarity = 2}
	}
}
minetest.register_node("farming:corn_8", table.copy(def))

-- add to registered_plants
farming.registered_plants["farming:corn"] = {
	crop = "farming:corn",
	seed = "farming:corn",
	minlight = farming.min_light,
	maxlight = farming.max_light,
	steps = 8
}

-- mapgen
minetest.register_decoration({
	deco_type = "simple",
	place_on = {"default:dirt_with_grass", "mcl_core:dirt_with_grass"},
	sidelen = 16,
	noise_params = {
		offset = 0,
		scale = farming.corn,
		spread = {x = 100, y = 100, z = 100},
		seed = 134,
		octaves = 3,
		persist = 0.6
	},
	y_min = 12,
	y_max = 25,
	decoration = "farming:corn_7"
})
