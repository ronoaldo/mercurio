
-- Asteroid nodes

minetest.register_node(":asteroid:stone", {
	description = "Asteroid Stone",
	tiles = {"default_stone.png"},
	is_ground_content = false,
	drop = 'asteroid:cobble',
	groups = {cracky = 3, stone = 1, not_in_creative_inventory = 1},
	sounds = default.node_sound_stone_defaults()
})

minetest.register_node(":asteroid:redstone", {
	description = "Asteroid Stone",
	tiles = {"asteroid_redstone.png"},
	is_ground_content = false,
	drop = 'asteroid:redcobble',
	groups = {cracky = 3, stone = 1},
	sounds = default.node_sound_stone_defaults()
})

minetest.register_node(":asteroid:cobble", {
	description = "Asteroid Cobble",
	tiles = {"asteroid_cobble.png"},
	is_ground_content = false,
	groups = {cracky = 3, stone = 2},
	sounds = default.node_sound_stone_defaults()
})

minetest.register_node(":asteroid:redcobble", {
	description = "Asteroid Cobble",
	tiles = {"asteroid_redcobble.png"},
	is_ground_content = false,
	groups = {cracky = 3, stone = 2},
	sounds = default.node_sound_stone_defaults()
})

minetest.register_node(":asteroid:gravel", {
	description = "Asteroid Gravel",
	tiles = {"asteroid_gravel.png"},
	is_ground_content = false,
	groups = {crumbly = 2},
	sounds = default.node_sound_dirt_defaults({
		footstep = {name = "default_gravel_footstep", gain = 0.2}
	})
})

minetest.register_node(":asteroid:redgravel", {
	description = "Asteroid Gravel",
	tiles = {"asteroid_redgravel.png"},
	is_ground_content = false,
	groups = {crumbly = 2},
	sounds = default.node_sound_dirt_defaults({
		footstep = {name = "default_gravel_footstep", gain = 0.2}
	})
})

minetest.register_node(":asteroid:dust", {
	description = "Asteroid Dust",
	tiles = {"asteroid_dust.png"},
	is_ground_content = false,
	groups = {crumbly = 3},
	sounds = default.node_sound_dirt_defaults({
		footstep = {name = "default_gravel_footstep", gain = 0.1}
	})
})

minetest.register_node(":asteroid:reddust", {
	description = "Asteroid Dust",
	tiles = {"asteroid_reddust.png"},
	is_ground_content = false,
	groups = {crumbly = 3},
	sounds = default.node_sound_dirt_defaults({
		footstep = {name = "default_gravel_footstep", gain = 0.1}
	})
})

minetest.register_node(":asteroid:ironore", {
	description = "Asteroid Iron Ore",
	tiles = {"asteroid_redstone.png^default_mineral_iron.png"},
	is_ground_content = false,
	groups = {cracky = 2},
	drop = "default:iron_lump",
	sounds = default.node_sound_stone_defaults()
})

minetest.register_node(":asteroid:copperore", {
	description = "Asteroid Copper Ore",
	tiles = {"asteroid_redstone.png^default_mineral_copper.png"},
	is_ground_content = false,
	groups = {cracky = 2},
	drop = "default:copper_lump",
	sounds = default.node_sound_stone_defaults()
})

minetest.register_node(":asteroid:goldore", {
	description = "Asteroid Gold Ore",
	tiles = {"asteroid_redstone.png^default_mineral_gold.png"},
	is_ground_content = false,
	groups = {cracky = 2},
	drop = "default:gold_lump",
	sounds = default.node_sound_stone_defaults()
})

minetest.register_node(":asteroid:diamondore", {
	description = "Asteroid Diamond Ore",
	tiles = {"asteroid_redstone.png^default_mineral_diamond.png"},
	is_ground_content = false,
	groups = {cracky = 1},
	drop = "default:diamond",
	sounds = default.node_sound_stone_defaults()
})

minetest.register_node(":asteroid:meseore", {
	description = "Asteroid Mese Ore",
	tiles = {"asteroid_redstone.png^default_mineral_mese.png"},
	is_ground_content = false,
	groups = {cracky = 1},
	drop = "default:mese_crystal",
	sounds = default.node_sound_stone_defaults()
})

minetest.register_node(":asteroid:atmos", {
	description = "Comet Atmosphere",
	drawtype = "glasslike",
	tiles = {"asteroid_atmos.png"},
	paramtype = "light",
	sunlight_propagates = true,
	walkable = false,
	pointable = false,
	diggable = false,
	buildable_to = true,
	is_ground_content = false,
	use_texture_alpha = "blend",
	post_effect_color = {a = 31, r = 241, g = 248, b = 255},
	groups = {not_in_creative_inventory = 1},
	drop = {}
})

-- Redsky plant nodes

minetest.register_node(":mars:redgrass", {
	description = "Red Grass",
	drawtype = "plantlike",
	waving = 1,
	visual_scale = 1.3,
	tiles = {"mars_redgrass.png"},
	inventory_image = "mars_redgrass.png",
	wield_image = "mars_redgrass.png",
	paramtype = "light",
	sunlight_propagates = true,
	walkable = false,
	buildable_to = true,
	groups = {snappy = 3, flora = 1, attached_node = 1},
	sounds = default.node_sound_leaves_defaults(),
	selection_box = {
		type = "fixed",
		fixed = {-0.5, -0.5, -0.5, 0.5, -5/16, 0.5}
	}
})

minetest.register_node(":mars:redweed", {
	description = "Red Weed",
	drawtype = "plantlike",
	waving = 1,
	visual_scale = 1.3,
	tiles = {"mars_redweed.png"},
	inventory_image = "mars_redweed.png",
	wield_image = "mars_redweed.png",
	paramtype = "light",
	sunlight_propagates = true,
	walkable = false,
	buildable_to = true,
	groups = {snappy = 3, flora = 1, attached_node = 1},
	sounds = default.node_sound_leaves_defaults(),
	selection_box = {
		type = "fixed",
		fixed = {-0.5, -0.5, -0.5, 0.5, -5/16, 0.5}
	}
})

minetest.register_node(":mars:moss", {
	description = "Martian Moss",
	drawtype = "nodebox",
	tiles = {"mars_moss.png"},
	inventory_image = "mars_moss.png",
	wield_image = "mars_moss.png",
	paramtype = "light",
	paramtype2 = "facedir",
	use_texture_alpha = "clip",
	sunlight_propagates = true,
	walkable = false,
	node_box = {
		type = "fixed",
		fixed = {-1/2, -1/2, -1/2, 1/2, -15/32, 1/2},
	},
	selection_box = {
		type = "fixed",
		fixed = {-1/2, -1/2, -1/2, 1/2, -15/32, 1/2},
	},
	groups = {snappy = 3, flora = 1, attached_node = 1},
	sounds = default.node_sound_leaves_defaults()
})

-- mars grass

minetest.register_node(":mars:grass_1", {
	description = "Martian Grass",
	drawtype = "plantlike",
	waving = 1,
	tiles = {"mars_grass_1.png"},
	inventory_image = "mars_grass_3.png",
	wield_image = "mars_grass_3.png",
	paramtype = "light",
	sunlight_propagates = true,
	walkable = false,
	buildable_to = true,
	groups = {snappy = 3, flora = 1, attached_node = 1},
	sounds = default.node_sound_leaves_defaults(),
	selection_box = {
		type = "fixed",
		fixed = {-0.5, -0.5, -0.5, 0.5, -5/16, 0.5}
	},

	on_place = function(itemstack, placer, pointed_thing)

		-- place a random grass node
		local stack = ItemStack("mars:grass_" .. math.random(5))
		local ret = minetest.item_place(stack, placer, pointed_thing)

		return ItemStack("mars:grass_1 "
			.. itemstack:get_count() - (1 - ret:get_count()))
	end
})

for i = 2, 5 do

	minetest.register_node(":mars:grass_" .. i, {
		description = "Martian Grass",
		drawtype = "plantlike",
		waving = 1,
		tiles = {"mars_grass_" .. i .. ".png"},
		inventory_image = "mars_grass_" .. i .. ".png",
		wield_image = "mars_grass_" .. i .. ".png",
		paramtype = "light",
		sunlight_propagates = true,
		walkable = false,
		buildable_to = true,
		drop = "mars:grass_1",
		groups = {
			snappy = 3, flora = 1, attached_node = 1,
			not_in_creative_inventory = 1
		},
		sounds = default.node_sound_leaves_defaults(),
		selection_box = {
			type = "fixed",
			fixed = {-0.5, -0.5, -0.5, 0.5, -5/16, 0.5}
		}
	})
end

-- Crystals

local sbox = {
	type = "fixed",
	fixed = {-5/16, -8/16, -6/16, 5/16, -1/32, 5/16}}

local crystal_list = {
	{"ghost_crystal", "ghost_crystal.png"},
	{"red_crystal", "red_crystal.png"},
	{"rose_quartz", "rose_quartz.png"}}

for i = 1, #crystal_list do -- in ipairs(crystal_list) do

	local name = crystal_list[i][1]
	local texture = crystal_list[i][2]

	minetest.register_node(":crystals:" .. name .. "_1", {
		description = "Glowing Crystal",
		drawtype = "mesh",
		mesh = "crystal_shape01.obj",
		tiles = {"crystals_" .. texture},
		wield_scale = {x = 7, y = 7, z = 7},
		paramtype = "light",
		paramtype2 = "facedir",
		selection_box = sbox,
		walkable = false,
		light_source = 10,
		use_texture_alpha = "blend",
		visual_scale = 10,
		groups = {snappy = 2, choppy = 2, oddly_breakable_by_hand = 3},
		sounds = default.node_sound_glass_defaults()
	})

	minetest.register_node(":crystals:" .. name .. "_2", {
		description = "Glowing Crystal",
		drawtype = "mesh",
		mesh = "crystal_shape02.obj",
		tiles = {"crystals_" .. texture},
		wield_scale = {x = 7, y = 7, z = 7},
		paramtype = "light",
		paramtype2 = "facedir",
		selection_box = sbox,
		walkable = false,
		light_source = 10,
		use_texture_alpha = "blend",
		visual_scale = 10,
		groups = {snappy = 2, choppy = 2, oddly_breakable_by_hand = 3},
		sounds = default.node_sound_glass_defaults()
	})
end
