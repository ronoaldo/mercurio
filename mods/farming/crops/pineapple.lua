
local S = farming.translate
local a = farming.recipe_items

-- pineapple top
minetest.register_craftitem("farming:pineapple_top", {
	description = S("Pineapple Top"),
	inventory_image = "farming_pineapple_top.png",
	groups = {compostability = 48, seed = 2, flammable = 2},
	on_place = function(itemstack, placer, pointed_thing)
		return farming.place_seed(itemstack, placer, pointed_thing, "farming:pineapple_1")
	end
})

-- pineapple
minetest.register_node("farming:pineapple", {
	description = S("Pineapple"),
	drawtype = "plantlike",
	tiles = {"farming_pineapple.png"},
	inventory_image = "farming_pineapple.png",
	wield_image = "farming_pineapple.png",
	paramtype = "light",
	sunlight_propagates = true,
	walkable = false,
	selection_box = {
		type = "fixed",
		fixed = {-0.27, -0.37, -0.27, 0.27, 0.44, 0.27}
	},
	groups = {
		food_pineapple = 1, fleshy = 3, dig_immediate = 3, flammable = 2,
		compostability = 65
	}
})

-- pineapple
minetest.register_craftitem("farming:pineapple_ring", {
	description = S("Pineapple Ring"),
	inventory_image = "farming_pineapple_ring.png",
	groups = {food_pineapple_ring = 1, flammable = 2, compostability = 45},
	on_use = minetest.item_eat(1)
})

minetest.register_craft( {
	output = "farming:pineapple_ring 5",
	recipe = {{"group:food_pineapple"}},
	replacements = {{"farming:pineapple", "farming:pineapple_top"}}
})

-- pineapple juice
minetest.register_craftitem("farming:pineapple_juice", {
	description = S("Pineapple Juice"),
	inventory_image = "farming_pineapple_juice.png",
	on_use = minetest.item_eat(4, "vessels:drinking_glass"),
	groups = {vessel = 1, drink = 1, compostability = 35}
})

minetest.register_craft({
	output = "farming:pineapple_juice",
	recipe = {
		{"group:food_pineapple_ring", "group:food_pineapple_ring",
				"group:food_pineapple_ring"},
		{"", a.drinking_glass, ""},
		{"", a.juicer, ""}
	},
	replacements = {
		{"group:food_juicer", "farming:juicer"}
	}
})

minetest.register_craft({
	output = "farming:pineapple_juice 2",
	recipe = {
		{a.drinking_glass, "group:food_pineapple", a.drinking_glass},
		{"", a.juicer, ""}
	},
	replacements = {
		{"group:food_juicer", "farming:juicer"}
	}
})

-- crop definition
local def = {
	drawtype = "plantlike",
	visual_scale = 1.5,
	tiles = {"farming_pineapple_1.png"},
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
minetest.register_node("farming:pineapple_1", table.copy(def))

-- stage 2
def.tiles = {"farming_pineapple_2.png"}
minetest.register_node("farming:pineapple_2", table.copy(def))

-- stage 3
def.tiles = {"farming_pineapple_3.png"}
minetest.register_node("farming:pineapple_3", table.copy(def))

-- stage 4
def.tiles = {"farming_pineapple_4.png"}
minetest.register_node("farming:pineapple_4", table.copy(def))

-- stage 5
def.tiles = {"farming_pineapple_5.png"}
minetest.register_node("farming:pineapple_5", table.copy(def))

-- stage 6
def.tiles = {"farming_pineapple_6.png"}
minetest.register_node("farming:pineapple_6", table.copy(def))

-- stage 7
def.tiles = {"farming_pineapple_7.png"}
minetest.register_node("farming:pineapple_7", table.copy(def))

-- stage 8 (final)
def.tiles = {"farming_pineapple_8.png"}
def.groups.growing = nil
def.selection_box = farming.select_final
def.drop = {
	items = {
		{items = {"farming:pineapple"}, rarity = 1},
		{items = {"farming:pineapple"}, rarity = 2}
	}
}
minetest.register_node("farming:pineapple_8", table.copy(def))

-- add to registered_plants
farming.registered_plants["farming:pineapple"] = {
	crop = "farming:pineapple",
	seed = "farming:pineapple_top",
	minlight = farming.min_light,
	maxlight = farming.max_light,
	steps = 8
}

-- mapgen
local mg = farming.mapgen == "v6"

def = {
	grow_on = mg and {"default:dirt_with_grass"} or {"default:dirt_with_dry_grass",
			"default:dry_dirt_with_dry_grass", "mcl_core:dirt_with_grass"},
	grow_near = mg and "group:sand" or nil,
	num = mg and 1 or -1
}

minetest.register_decoration({
	deco_type = "simple",
	place_on = def.grow_on,
	sidelen = 16,
	noise_params = {
		offset = 0,
		scale = farming.pineapple,
		spread = {x = 100, y = 100, z = 100},
		seed = 354,
		octaves = 3,
		persist = 0.6
	},
	y_min = 11,
	y_max = 30,
	decoration = {"farming:pineapple_8"},
	spawn_by = def.grow_near,
	num_spawn_by = def.num
})
