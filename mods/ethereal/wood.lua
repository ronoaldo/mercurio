
local S = minetest.get_translator("ethereal")

-- register wood and placement helper

local function add_wood(name, def)

	if ethereal.wood_rotate then
		def.on_place = minetest.rotate_node
	else
		def.place_param2 = 0
	end

	minetest.register_node(name, def)
end

-- basandra

add_wood("ethereal:basandra_wood", {
	description = S("Basandra Wood"),
	tiles = {"ethereal_basandra_bush_wood.png"},
	paramtype2 = "facedir",
	is_ground_content = false,
	groups = {wood = 1, choppy = 2, oddly_breakable_by_hand = 1},
	sounds = default.node_sound_wood_defaults()
})

minetest.register_craft({
	output = "ethereal:basandra_wood 2",
	recipe = {{"ethereal:basandra_bush_stem"}}
})

-- sakura

minetest.register_node("ethereal:sakura_trunk", {
	description = S("Sakura Trunk"),
	tiles = {
		"ethereal_sakura_trunk_top.png",
		"ethereal_sakura_trunk_top.png",
		"ethereal_sakura_trunk.png"
	},
	groups = {tree = 1, choppy = 2, oddly_breakable_by_hand = 1, flammable = 2},
	sounds = default.node_sound_wood_defaults(),
	paramtype2 = "facedir",
	on_place = minetest.rotate_node
})

add_wood("ethereal:sakura_wood", {
	description = S("Sakura Wood"),
	tiles = {"ethereal_sakura_wood.png"},
	is_ground_content = false,
	groups = {wood = 1, choppy = 2, oddly_breakable_by_hand = 1, flammable = 3},
	sounds = default.node_sound_wood_defaults(),
	paramtype2 = "facedir"
})

minetest.register_craft({
	output = "ethereal:sakura_wood 4",
	recipe = {{"ethereal:sakura_trunk"}}
})

-- willow

minetest.register_node("ethereal:willow_trunk", {
	description = S("Willow Trunk"),
	tiles = {
		"ethereal_willow_trunk_top.png",
		"ethereal_willow_trunk_top.png",
		"ethereal_willow_trunk.png"
	},
	groups = {tree = 1, choppy = 2, oddly_breakable_by_hand = 1, flammable = 2},
	sounds = default.node_sound_wood_defaults(),
	paramtype2 = "facedir",
	on_place = minetest.rotate_node
})

add_wood("ethereal:willow_wood", {
	description = S("Willow Wood"),
	tiles = {"ethereal_willow_wood.png"},
	is_ground_content = false,
	groups = {wood = 1, choppy = 2, oddly_breakable_by_hand = 1, flammable = 3},
	sounds = default.node_sound_wood_defaults(),
	paramtype2 = "facedir"
})

minetest.register_craft({
	output = "ethereal:willow_wood 4",
	recipe = {{"ethereal:willow_trunk"}}
})

-- redwood

minetest.register_node("ethereal:redwood_trunk", {
	description = S("Redwood Trunk"),
	tiles = {
		"ethereal_redwood_trunk_top.png",
		"ethereal_redwood_trunk_top.png",
		"ethereal_redwood_trunk.png"
	},
	groups = {tree = 1, choppy = 2, oddly_breakable_by_hand = 1, flammable = 2},
	sounds = default.node_sound_wood_defaults(),
	paramtype2 = "facedir",
	on_place = minetest.rotate_node
})

add_wood("ethereal:redwood_wood", {
	description = S("Redwood Wood"),
	tiles = {"ethereal_redwood_wood.png"},
	is_ground_content = false,
	groups = {wood = 1, choppy = 2, oddly_breakable_by_hand = 1, flammable = 3},
	sounds = default.node_sound_wood_defaults(),
	paramtype2 = "facedir"
})

minetest.register_craft({
	output = "ethereal:redwood_wood 4",
	recipe = {{"ethereal:redwood_trunk"}}
})

-- frost

minetest.register_node("ethereal:frost_tree", {
	description = S("Frost Tree"),
	tiles = {
		"ethereal_frost_tree_top.png",
		"ethereal_frost_tree_top.png",
		"ethereal_frost_tree.png"
	},
	groups = {tree = 1, choppy = 2, oddly_breakable_by_hand = 1, puts_out_fire = 1},
	sounds = default.node_sound_wood_defaults(),
	paramtype2 = "facedir",
	on_place = minetest.rotate_node
})

add_wood("ethereal:frost_wood", {
	description = S("Frost Wood"),
	tiles = {"ethereal_frost_wood.png"},
	is_ground_content = false,
	groups = {wood = 1, choppy = 2, oddly_breakable_by_hand = 1},
	sounds = default.node_sound_wood_defaults(),
	paramtype2 = "facedir"
})

minetest.register_craft({
	output = "ethereal:frost_wood 4",
	recipe = {{"ethereal:frost_tree"}}
})

-- healing

minetest.register_node("ethereal:yellow_trunk", {
	description = S("Healing Tree Trunk"),
	tiles = {
		"ethereal_yellow_tree_top.png",
		"ethereal_yellow_tree_top.png",
		"ethereal_yellow_tree.png"
	},
	groups = {tree = 1, choppy = 2, oddly_breakable_by_hand = 1, puts_out_fire = 1},
	sounds = default.node_sound_wood_defaults(),
	paramtype2 = "facedir",
	on_place = minetest.rotate_node
})

add_wood("ethereal:yellow_wood", {
	description = S("Healing Tree Wood"),
	tiles = {"ethereal_yellow_wood.png"},
	is_ground_content = false,
	groups = {wood = 1, choppy = 2, oddly_breakable_by_hand = 1},
	sounds = default.node_sound_wood_defaults(),
	paramtype2 = "facedir"
})

minetest.register_craft({
	output = "ethereal:yellow_wood 4",
	recipe = {{"ethereal:yellow_trunk"}}
})

-- palm (thanks to VanessaE for palm textures)

minetest.register_node("ethereal:palm_trunk", {
	description = S("Palm Trunk"),
	tiles = {
		"moretrees_palm_trunk_top.png",
		"moretrees_palm_trunk_top.png",
		"moretrees_palm_trunk.png"
	},
	groups = {tree = 1, choppy = 2, oddly_breakable_by_hand = 1, flammable = 2},
	sounds = default.node_sound_wood_defaults(),
	paramtype2 = "facedir",
	on_place = minetest.rotate_node
})

add_wood("ethereal:palm_wood", {
	description = S("Palm Wood"),
	tiles = {"moretrees_palm_wood.png"},
	is_ground_content = false,
	groups = {wood = 1, choppy = 2, oddly_breakable_by_hand = 1, flammable = 3},
	sounds = default.node_sound_wood_defaults(),
	paramtype2 = "facedir"
})

minetest.register_craft({
	output = "ethereal:palm_wood 4",
	recipe = {{"ethereal:palm_trunk"}}
})

-- banana

minetest.register_node("ethereal:banana_trunk", {
	description = S("Banana Trunk"),
	tiles = {
		"ethereal_banana_trunk_top.png",
		"ethereal_banana_trunk_top.png",
		"ethereal_banana_trunk.png"
	},
	groups = {tree = 1, choppy = 2, oddly_breakable_by_hand = 1, flammable = 2},
	sounds = default.node_sound_wood_defaults(),
	paramtype2 = "facedir",
	on_place = minetest.rotate_node
})

add_wood("ethereal:banana_wood", {
	description = S("Banana Wood"),
	tiles = {"ethereal_banana_wood.png"},
	is_ground_content = false,
	groups = {wood = 1, choppy = 2, oddly_breakable_by_hand = 1, flammable = 3},
	sounds = default.node_sound_wood_defaults(),
	paramtype2 = "facedir"
})

minetest.register_craft({
	output = "ethereal:banana_wood 4",
	recipe = {{"ethereal:banana_trunk"}}
})

-- scorched

minetest.register_node("ethereal:scorched_tree", {
	description = S("Scorched Tree"),
	tiles = {
		"ethereal_scorched_tree_top.png",
		"ethereal_scorched_tree_top.png",
		"ethereal_scorched_tree.png"
	},
	groups = {tree = 1, choppy = 2, oddly_breakable_by_hand = 1, flammable = 1},
	sounds = default.node_sound_wood_defaults(),
	paramtype2 = "facedir",
	on_place = minetest.rotate_node
})

minetest.register_craft({
	output = "ethereal:scorched_tree 8",
	recipe = {
		{"group:tree", "group:tree", "group:tree"},
		{"group:tree", "default:torch", "group:tree"},
		{"group:tree", "group:tree", "group:tree"}
	}
})

-- mushroom

minetest.register_node("ethereal:mushroom_trunk", {
	description = S("Mushroom"),
	tiles = {
		"ethereal_mushroom_trunk_top.png",
		"ethereal_mushroom_trunk_top.png",
		"ethereal_mushroom_trunk.png"
	},
	groups = {tree = 1, choppy = 2, oddly_breakable_by_hand = 1, flammable = 2},
	sounds = default.node_sound_wood_defaults(),
	paramtype2 = "facedir",
	on_place = minetest.rotate_node
})

-- birch (thanks to VanessaE for birch textures)

minetest.register_node("ethereal:birch_trunk", {
	description = S("Birch Trunk"),
	tiles = {
		"moretrees_birch_trunk_top.png",
		"moretrees_birch_trunk_top.png",
		"moretrees_birch_trunk.png"
	},
	groups = {tree = 1, choppy = 2, oddly_breakable_by_hand = 1, flammable = 2},
	sounds = default.node_sound_wood_defaults(),
	paramtype2 = "facedir",
	on_place = minetest.rotate_node
})

add_wood("ethereal:birch_wood", {
	description = S("Birch Wood"),
	tiles = {"moretrees_birch_wood.png"},
	is_ground_content = false,
	groups = {wood = 1, choppy = 2, oddly_breakable_by_hand = 1, flammable = 3},
	sounds = default.node_sound_wood_defaults(),
	paramtype2 = "facedir"
})

minetest.register_craft({
	output = "ethereal:birch_wood 4",
	recipe = {{"ethereal:birch_trunk"}}
})

-- Bamboo

minetest.register_node("ethereal:bamboo", {
	description = S("Bamboo"),
	drawtype = "plantlike",
	tiles = {"ethereal_bamboo_trunk.png"},
	inventory_image = "ethereal_bamboo_trunk.png",
	wield_image = "ethereal_bamboo_trunk.png",
	paramtype = "light",
	sunlight_propagates = true,
	walkable = true,
	selection_box = {
		type = "fixed", fixed = {-0.15, -0.5, -0.15, 0.15, 0.5, 0.15}
	},
	collision_box = {
		type = "fixed", fixed = {-0.15, -0.5, -0.15, 0.15, 0.5, 0.15}
	},
	groups = {choppy = 3, oddly_breakable_by_hand = 1, flammable = 2},
	sounds = default.node_sound_leaves_defaults(),

	after_dig_node = function(pos, node, metadata, digger)
		default.dig_up(pos, node, digger)
	end
})

minetest.register_craft({
	type = "fuel",
	recipe = "ethereal:bamboo",
	burntime = 2
})

-- olive

minetest.register_node("ethereal:olive_trunk", {
	description = S("Olive Trunk"),
	tiles = {
		"ethereal_olive_trunk_top.png",
		"ethereal_olive_trunk_top.png",
		"ethereal_olive_trunk.png"
	},
	groups = {tree = 1, choppy = 2, oddly_breakable_by_hand = 1, flammable = 2},
	sounds = default.node_sound_wood_defaults(),
	paramtype2 = "facedir",
	on_place = minetest.rotate_node
})

add_wood("ethereal:olive_wood", {
	description = S("Olive Wood"),
	tiles = {"ethereal_olive_wood.png"},
	is_ground_content = false,
	groups = {wood = 1, choppy = 2, oddly_breakable_by_hand = 1, flammable = 3},
	sounds = default.node_sound_wood_defaults(),
	paramtype2 = "facedir"
})

minetest.register_craft({
	output = "ethereal:olive_wood 4",
	recipe = {{"ethereal:olive_trunk"}}
})
