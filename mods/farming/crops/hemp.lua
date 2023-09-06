
local S = farming.translate
local a = farming.recipe_items

-- hemp seeds
minetest.register_node("farming:seed_hemp", {
	description = S("Hemp Seed"),
	tiles = {"farming_hemp_seed.png"},
	inventory_image = "farming_hemp_seed.png",
	wield_image = "farming_hemp_seed.png",
	drawtype = "signlike",
	groups = {compostability = 38, seed = 1, snappy = 3, attached_node = 1, growing = 1},
	paramtype = "light",
	paramtype2 = "wallmounted",
	walkable = false,
	sunlight_propagates = true,
	selection_box = farming.select,
	next_plant = "farming:hemp_1",
	on_place = function(itemstack, placer, pointed_thing)
		return farming.place_seed(itemstack, placer, pointed_thing, "farming:seed_hemp")
	end
})

-- harvested hemp
minetest.register_craftitem("farming:hemp_leaf", {
	description = S("Hemp Leaf"),
	inventory_image = "farming_hemp_leaf.png",
	groups = {compostability = 35}
})

-- hemp oil
minetest.register_node("farming:hemp_oil", {
	description = S("Bottle of Hemp Oil"),
	drawtype = "plantlike",
	tiles = {"farming_hemp_oil.png"},
	inventory_image = "farming_hemp_oil.png",
	wield_image = "farming_hemp_oil.png",
	paramtype = "light",
	is_ground_content = false,
	walkable = false,
	selection_box = {
		type = "fixed",
		fixed = {-0.25, -0.5, -0.25, 0.25, 0.3, 0.25}
	},
	groups = {
		food_oil = 1, vessel = 1, dig_immediate = 3, attached_node = 1,
		compostability = 45
	},
	sounds = farming.sounds.node_sound_glass_defaults()
})

minetest.register_craft( {
	output = "farming:hemp_oil",
	recipe = {
		{"farming:hemp_leaf", "farming:hemp_leaf", "farming:hemp_leaf"},
		{"farming:hemp_leaf", "farming:hemp_leaf", "farming:hemp_leaf"},
		{"", a.glass_bottle, ""}
	}
})

minetest.register_craft( {
	output = "farming:hemp_oil",
	recipe = {
		{"farming:seed_hemp", "farming:seed_hemp", "farming:seed_hemp"},
		{"farming:seed_hemp", "farming:seed_hemp", "farming:seed_hemp"},
		{"farming:seed_hemp", a.glass_bottle, "farming:seed_hemp"}
	}
})

minetest.register_craft({
	type = "fuel",
	recipe = "farming:hemp_oil",
	burntime = 20,
	replacements = {{"farming:hemp_oil", a.glass_bottle}}
})

-- hemp fibre
minetest.register_craftitem("farming:hemp_fibre", {
	description = S("Hemp Fibre"),
	inventory_image = "farming_hemp_fibre.png",
	groups = {compostability = 55}
})

minetest.register_craft( {
	output = "farming:hemp_fibre 8",
	recipe = {
		{"farming:hemp_leaf", "farming:hemp_leaf", "farming:hemp_leaf"},
		{"farming:hemp_leaf", "group:water_bucket", "farming:hemp_leaf"},
		{"farming:hemp_leaf", "farming:hemp_leaf", "farming:hemp_leaf"}
	},
	replacements = {{a.bucket_water, a.bucket_empty}}
})

if minetest.get_modpath("bucket_wooden") then
	minetest.register_craft( {
		output = "farming:hemp_fibre 8",
		recipe = {
			{"farming:hemp_leaf", "farming:hemp_leaf", "farming:hemp_leaf"},
			{"farming:hemp_leaf", "group:water_bucket_wooden", "farming:hemp_leaf"},
			{"farming:hemp_leaf", "farming:hemp_leaf", "farming:hemp_leaf"}
		},
		replacements = {{"group:water_bucket_wooden", "bucket_wooden:bucket_empty"}}
	})
end

-- hemp block
minetest.register_node("farming:hemp_block", {
	description = S("Hemp Block"),
	tiles = {"farming_hemp_block.png"},
	paramtype = "light",
	groups = {
		handy = 1, snappy = 2, oddly_breakable_by_hand = 1, flammable = 2,
		compostability = 85
	},
	sounds =  farming.sounds.node_sound_leaves_defaults()
})

minetest.register_craft( {
	output = "farming:hemp_block",
	recipe = {
		{"farming:hemp_fibre", "farming:hemp_fibre", "farming:hemp_fibre"},
		{"farming:hemp_fibre", "farming:hemp_fibre", "farming:hemp_fibre"},
		{"farming:hemp_fibre", "farming:hemp_fibre", "farming:hemp_fibre"}
	}
})

-- check and register stairs
if minetest.global_exists("stairs") then

	if stairs.mod and stairs.mod == "redo" then

		stairs.register_all("hemp_block", "farming:hemp_block",
			{snappy = 2, oddly_breakable_by_hand = 1, flammable = 2},
			{"farming_hemp_block.png"},
			"Hemp Block",
			farming.sounds.node_sound_leaves_defaults())
	else

		stairs.register_stair_and_slab("hemp_block", "farming:hemp_block",
			{snappy = 2, oddly_breakable_by_hand = 1, flammable = 2},
			{"farming_hemp_block.png"},
			"Hemp Block Stair",
			"Hemp Block Slab",
			farming.sounds.node_sound_leaves_defaults())
	end
end

-- paper
minetest.register_craft( {
	output = a.paper .. " 3",
	recipe = {
		{"farming:hemp_fibre", "farming:hemp_fibre", "farming:hemp_fibre"}
	}
})

-- string
minetest.register_craft( {
	output = "farming:cotton 3",
	recipe = {
		{"farming:hemp_fibre"},
		{"farming:hemp_fibre"},
		{"farming:hemp_fibre"}
	}
})

-- hemp rope
minetest.register_node("farming:hemp_rope", {
	description = S("Hemp Rope"),
	walkable = false,
	climbable = true,
	sunlight_propagates = true,
	paramtype = "light",
	tiles = {"farming_hemp_rope.png"},
	wield_image = "farming_hemp_rope.png",
	inventory_image = "farming_hemp_rope.png",
	drawtype = "plantlike",
	groups = {
		flammable = 2, choppy = 3, oddly_breakable_by_hand = 3, compostability = 55
	},
	sounds =  farming.sounds.node_sound_leaves_defaults(),
	selection_box = {
		type = "fixed",
		fixed = {-1/7, -1/2, -1/7, 1/7, 1/2, 1/7}
	}
})

-- string
minetest.register_craft( {
	output = "farming:hemp_rope 6",
	recipe = {
		{"farming:hemp_fibre", "farming:hemp_fibre", "farming:hemp_fibre"},
		{"farming:cotton", "farming:cotton", "farming:cotton"},
		{"farming:hemp_fibre", "farming:hemp_fibre", "farming:hemp_fibre"}
	}
})

-- hemp definition
local def = {
	drawtype = "plantlike",
	tiles = {"farming_hemp_1.png"},
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
minetest.register_node("farming:hemp_1", table.copy(def))

-- stage 2
def.tiles = {"farming_hemp_2.png"}
minetest.register_node("farming:hemp_2", table.copy(def))

-- stage 3
def.tiles = {"farming_hemp_3.png"}
minetest.register_node("farming:hemp_3", table.copy(def))

-- stage 4
def.tiles = {"farming_hemp_4.png"}
minetest.register_node("farming:hemp_4", table.copy(def))

-- stage 5
def.tiles = {"farming_hemp_5.png"}
minetest.register_node("farming:hemp_5", table.copy(def))

-- stage 6
def.tiles = {"farming_hemp_6.png"}
def.drop = {
	items = {
		{items = {"farming:hemp_leaf"}, rarity = 2},
		{items = {"farming:seed_hemp"}, rarity = 1}
	}
}
minetest.register_node("farming:hemp_6", table.copy(def))

-- stage 7
def.tiles = {"farming_hemp_7.png"}
def.drop = {
	items = {
		{items = {"farming:hemp_leaf"}, rarity = 1},
		{items = {"farming:hemp_leaf"}, rarity = 3},
		{items = {"farming:seed_hemp"}, rarity = 1},
		{items = {"farming:seed_hemp"}, rarity = 3}
	}
}
minetest.register_node("farming:hemp_7", table.copy(def))

-- stage 8 (final)
def.tiles = {"farming_hemp_8.png"}
def.groups.growing = nil
def.selection_box = farming.select_final
def.drop = {
	items = {
		{items = {"farming:hemp_leaf 2"}, rarity = 1},
		{items = {"farming:hemp_leaf"}, rarity = 2},
		{items = {"farming:seed_hemp"}, rarity = 1},
		{items = {"farming:seed_hemp"}, rarity = 2}
	}
}
minetest.register_node("farming:hemp_8", table.copy(def))

-- add to registered_plants
farming.registered_plants["farming:hemp"] = {
	crop = "farming:hemp",
	seed = "farming:seed_hemp",
	minlight = farming.min_light,
	maxlight = farming.max_light,
	steps = 8
}

-- mapgen
minetest.register_decoration({
	deco_type = "simple",
	place_on = {
		"default:dirt_with_grass", "default:dirt_with_rainforest_litter",
		"mcl_core:dirt_with_grass"
	},
	sidelen = 16,
	noise_params = {
		offset = 0,
		scale = farming.hemp,
		spread = {x = 100, y = 100, z = 100},
		seed = 420,
		octaves = 3,
		persist = 0.6
	},
	y_min = 3,
	y_max = 45,
	decoration = "farming:hemp_7",
	spawn_by = "group:tree",
	num_spawn_by = 1
})
