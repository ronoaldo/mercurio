
local path = minetest.get_modpath("ethereal") .. "/schematics/"
local dpath = minetest.get_modpath("default") .. "/schematics/"


-- load schematic tables
dofile(path .. "orange_tree.lua")
dofile(path .. "banana_tree.lua")
dofile(path .. "bamboo_tree.lua")
dofile(path .. "birch_tree.lua")
dofile(path .. "bush.lua")
dofile(path .. "waterlily.lua")
dofile(path .. "volcanom.lua")
dofile(path .. "volcanol.lua")
dofile(path .. "frosttrees.lua")
dofile(path .. "palmtree.lua")
dofile(path .. "pinetree.lua")
dofile(path .. "yellowtree.lua")
dofile(path .. "mushroomone.lua")
dofile(path .. "willow.lua")
dofile(path .. "bigtree.lua")
dofile(path .. "redwood_tree.lua")
dofile(path .. "redwood_small_tree.lua")
dofile(path .. "vinetree.lua")
dofile(path .. "sakura.lua")
dofile(path .. "igloo.lua")
dofile(path .. "lemon_tree.lua")
dofile(path .. "olive_tree.lua")
dofile(path .. "basandra_bush.lua")


-- helper function
local add_schem = function(a, b, c, d, e, f, g, h, i, j, k)

	-- if not 1 then biome disabled, don't add
	if g ~= 1 then return end

	minetest.register_decoration({
		deco_type = "schematic",
		place_on = a,
		sidelen = 80,
		fill_ratio = b,
		biomes = c,
		y_min = d,
		y_max = e,
		schematic = f,
		flags = "place_center_x, place_center_z",
		replacements = h,
		spawn_by = i,
		num_spawn_by = j,
		rotation = k
	})
end


-- igloo
add_schem("default:snowblock", 0.0005, {"glacier"}, 3, 50,
	ethereal.igloo, ethereal.glacier, nil, "default:snowblock", 8, "random")

-- sakura tree
add_schem({"ethereal:bamboo_dirt"}, 0.001, {"sakura"}, 7, 100,
	ethereal.sakura_tree, ethereal.sakura, nil,
	"ethereal:bamboo_dirt", 6)

-- redwood tree
add_schem({"default:dirt_with_dry_grass"}, 0.0025, {"mesa"}, 1, 100,
	ethereal.redwood_tree, ethereal.mesa, nil,
	"default:dirt_with_dry_grass", 8)

-- banana tree
add_schem({"ethereal:grove_dirt"}, 0.015, {"grove"}, 1, 100,
	ethereal.bananatree, ethereal.grove)

-- healing tree
add_schem({"default:dirt_with_snow"}, 0.01, {"taiga"}, 120, 140,
	ethereal.yellowtree, ethereal.alpine, nil, "default:dirt_with_snow", 8)

-- crystal frost tree
add_schem({"ethereal:crystal_dirt"}, 0.01, {"frost", "frost_floatland"}, 1, 1750,
	ethereal.frosttrees, ethereal.frost, nil,
	"ethereal:crystal_dirt", 8)

-- giant mushroom
add_schem("ethereal:mushroom_dirt", 0.02, {"mushroom"}, 1, 100,
	ethereal.mushroomone, ethereal.mushroom, nil,
	"ethereal:mushroom_dirt", 8)

-- small lava crater
add_schem("ethereal:fiery_dirt", 0.01, {"fiery"}, 1, 100,
	ethereal.volcanom, ethereal.fiery, nil, "ethereal:fiery_dirt", 8)

-- large lava crater
add_schem("ethereal:fiery_dirt", 0.003, {"fiery"}, 1, 100,
	ethereal.volcanol, ethereal.fiery, nil, "ethereal:fiery_dirt", 8, "random")

-- basandra bush
add_schem("ethereal:fiery_dirt", 0.03, {"fiery"}, 1, 100,
	ethereal.basandrabush, ethereal.fiery)

-- default jungle tree
add_schem({"ethereal:jungle_dirt", "default:dirt_with_rainforest_litter"},
	0.08, {"junglee"}, 1, 100, dpath .. "jungle_tree.mts", ethereal.junglee)

-- willow tree
add_schem({"ethereal:gray_dirt"}, 0.02, {"grayness"}, 1, 100,
	ethereal.willow, ethereal.grayness, nil,
	"ethereal:gray_dirt", 6)

-- default large pine tree for lower elevation
add_schem({"ethereal:cold_dirt", "default:dirt_with_coniferous_litter"},
	0.025, {"coniferous_forest"}, 10, 40, dpath .. "pine_tree.mts", ethereal.snowy)

-- small pine for higher elevation
add_schem({"default:dirt_with_snow"}, 0.025, {"taiga"}, 40, 140,
	ethereal.pinetree, ethereal.alpine)

-- default apple tree
add_schem({"default:dirt_with_grass"}, 0.025, {"jumble", "deciduous_forest"}, 1, 100,
	dpath .. "apple_tree.mts", ethereal.grassy)

-- big old tree
add_schem({"default:dirt_with_grass"}, 0.001, {"jumble"}, 1, 100,
	ethereal.bigtree, ethereal.jumble, nil,
	"default:dirt_with_grass", 8)

-- default aspen tree
add_schem({"default:dirt_with_grass"}, 0.02, {"grassytwo"}, 1, 50,
	dpath .. "aspen_tree.mts", ethereal.jumble)

-- birch tree
add_schem({"default:dirt_with_grass"}, 0.02, {"grassytwo"}, 50, 100,
	ethereal.birchtree, ethereal.grassytwo)

-- orange tree
add_schem({"ethereal:prairie_dirt"}, 0.01, {"prairie"}, 1, 100,
	ethereal.orangetree, ethereal.prairie)

-- default acacia tree
add_schem({"default:dry_dirt_with_dry_grass",
	"default:dirt_with_dry_grass"}, 0.004, {"savanna"}, 1, 100,
	dpath .. "acacia_tree.mts", ethereal.savanna)

-- palm tree
add_schem("default:sand", 0.0025, {"desert_ocean", "plains_ocean", "sandclay",
	"sandstone_ocean", "mesa_ocean", "grove_ocean", "deciduous_forest_ocean"}, 1, 1,
	ethereal.palmtree, 1)

-- bamboo tree
add_schem({"ethereal:bamboo_dirt"}, 0.025, {"bamboo"}, 1, 100,
	ethereal.bambootree, ethereal.bamboo)

-- bush
add_schem({"ethereal:bamboo_dirt"}, 0.08, {"bamboo"}, 1, 100, ethereal.bush,
	ethereal.bamboo)

-- vine tree
add_schem({"default:dirt_with_grass"}, 0.02, {"swamp"}, 1, 100,
	ethereal.vinetree, ethereal.swamp)

-- lemon tree
add_schem({"ethereal:grove_dirt"}, 0.002, {"mediterranean"}, 5, 50,
	ethereal.lemontree, ethereal.mediterranean)

-- olive tree
add_schem({"ethereal:grove_dirt"}, 0.002, {"mediterranean"}, 5, 35,
	ethereal.olivetree, ethereal.mediterranean)


-- default large cactus
if ethereal.desert == 1 then

	minetest.register_decoration({
		deco_type = "schematic",
		place_on = {"default:desert_sand"},
		sidelen = 80,
		noise_params = {
			offset = -0.0005,
			scale = 0.0015,
			spread = {x = 200, y = 200, z = 200},
			seed = 230,
			octaves = 3,
			persist = 0.6
		},
		biomes = {"desert"},
		y_min = 5,
		y_max = 31000,
		schematic = dpath .. "large_cactus.mts",
		flags = "place_center_x",
		rotation = "random",
	})
end


-- default bush
minetest.register_decoration({
	deco_type = "schematic",
	place_on = {"default:dirt_with_grass", "default:dirt_with_snow"},
	sidelen = 16,
	noise_params = {
		offset = -0.004,
		scale = 0.01,
		spread = {x = 100, y = 100, z = 100},
		seed = 137,
		octaves = 3,
		persist = 0.7,
	},
	biomes = {"deciduous_forest", "grassytwo", "jumble"},
	y_min = 1,
	y_max = 31000,
	schematic = dpath .. "bush.mts",
	flags = "place_center_x, place_center_z"
})


-- default acacia bush
minetest.register_decoration({
	deco_type = "schematic",
	place_on = {
		"default:dirt_with_dry_grass", "default:dry_dirt_with_dry_grass"},
	sidelen = 16,
	noise_params = {
		offset = -0.004,
		scale = 0.01,
		spread = {x = 100, y = 100, z = 100},
		seed = 90155,
		octaves = 3,
		persist = 0.7,
	},
	biomes = {"savanna", "mesa"},
	y_min = 1,
	y_max = 31000,
	schematic = dpath .. "acacia_bush.mts",
	flags = "place_center_x, place_center_z"
})


-- default pine bush
if minetest.registered_nodes["default:pine_bush"] then

	minetest.register_decoration({
		name = "default:pine_bush",
		deco_type = "schematic",
		place_on = {"default:dirt_with_snow"},
		sidelen = 16,
		noise_params = {
			offset = -0.004,
			scale = 0.01,
			spread = {x = 100, y = 100, z = 100},
			seed = 137,
			octaves = 3,
			persist = 0.7,
		},
		biomes = {"taiga"},
		y_max = 31000,
		y_min = 4,
		schematic = dpath .. "pine_bush.mts",
		flags = "place_center_x, place_center_z"
	})
end


-- default blueberry bush
if minetest.registered_nodes["default:blueberry_bush_leaves"] then

	minetest.register_decoration({
		name = "default:blueberry_bush",
		deco_type = "schematic",
		place_on = {
			"default:dirt_with_coniferous_litter", "default:dirt_with_snow"},
		sidelen = 16,
		noise_params = {
			offset = -0.004,
			scale = 0.01,
			spread = {x = 100, y = 100, z = 100},
			seed = 697,
			octaves = 3,
			persist = 0.7,
		},
		biomes = {"coniferous_forest", "taiga"},
		y_max = 31000,
		y_min = 1,
		place_offset_y = 1,
		schematic = dpath .. "blueberry_bush.mts",
		flags = "place_center_x, place_center_z"
	})
end


-- place waterlily in beach areas
minetest.register_decoration({
	deco_type = "schematic",
	place_on = {"default:sand"},
	sidelen = 16,
	noise_params = {
		offset = -0.12,
		scale = 0.3,
		spread = {x = 200, y = 200, z = 200},
		seed = 33,
		octaves = 3,
		persist = 0.7
	},
	biomes = {"desert_ocean", "plains_ocean", "sandclay",
		"mesa_ocean", "grove_ocean", "deciduous_forest_ocean", "swamp_ocean"},
	y_min = 0,
	y_max = 0,
	schematic = ethereal.waterlily,
	rotation = "random"
})


-- coral reef
if ethereal.reefs == 1 then

	-- override corals so crystal shovel can pick them up intact
	minetest.override_item("default:coral_skeleton", {groups = {crumbly = 3}})
	minetest.override_item("default:coral_orange", {groups = {crumbly = 3}})
	minetest.override_item("default:coral_brown", {groups = {crumbly = 3}})

	minetest.register_decoration({
		deco_type = "schematic",
		place_on = {"default:sand"},
		noise_params = {
			offset = -0.15,
			scale = 0.1,
			spread = {x = 100, y = 100, z = 100},
			seed = 7013,
			octaves = 3,
			persist = 1,
		},
		biomes = {"desert_ocean", "grove_ocean"},
		y_min = -8,
		y_max = -2,
		schematic = path .. "corals.mts",
		flags = "place_center_x, place_center_z",
		rotation = "random"
	})
end


-- tree logs
if ethereal.logs == 1 then

if ethereal.grassy == 1 or ethereal.prairie == 1 then
minetest.register_decoration({
		name = "default:apple_log",
		deco_type = "schematic",
		place_on = {"default:dirt_with_grass", "ethereal:prairie_dirt"},
		place_offset_y = 1,
		sidelen = 16,
		fill_ratio = 0.001,
		biomes = {"deciduous_forest", "jumble", "swamp", "prairie"},
		y_max = 100,
		y_min = 1,
		schematic = dpath .. "apple_log.mts",
		flags = "place_center_x",
		rotation = "random",
		spawn_by = {"default:dirt_with_grass", "ethereal:prairie_dirt"},
		num_spawn_by = 8
	})
end

if ethereal.junglee == 1 then
	minetest.register_decoration({
		name = "default:jungle_log",
		deco_type = "schematic",
		place_on = {"default:dirt_with_rainforest_litter"},
		place_offset_y = 1,
		sidelen = 80,
		fill_ratio = 0.005,
		biomes = {"junglee"},
		y_max = 100,
		y_min = 1,
		schematic = dpath .. "jungle_log.mts",
		flags = "place_center_x",
		rotation = "random",
		spawn_by = "default:dirt_with_rainforest_litter",
		num_spawn_by = 8
	})
end

if ethereal.snowy == 1 then
	minetest.register_decoration({
		name = "default:pine_log",
		deco_type = "schematic",
		place_on = {"default:dirt_with_snow", "default:dirt_with_coniferous_litter"},
		place_offset_y = 1,
		sidelen = 80,
		fill_ratio = 0.0018,
		biomes = {"taiga", "coniferous_forest"},
		y_max = 100,
		y_min = 4,
		schematic = dpath .. "pine_log.mts",
		flags = "place_center_x",
		rotation = "random",
		spawn_by = {"default:dirt_with_snow", "default:dirt_with_coniferous_litter"},
		num_spawn_by = 8
	})
end

if ethereal.savanna == 1 then
	minetest.register_decoration({
		name = "default:acacia_log",
		deco_type = "schematic",
		place_on = {"default:dry_dirt_with_dry_grass"},
		place_offset_y = 1,
		sidelen = 16,
		noise_params = {
			offset = 0,
			scale = 0.001,
			spread = {x = 250, y = 250, z = 250},
			seed = 2,
			octaves = 3,
			persist = 0.66
		},
		biomes = {"savanna"},
		y_max = 100,
		y_min = 1,
		schematic = dpath .. "acacia_log.mts",
		flags = "place_center_x",
		rotation = "random",
		spawn_by = "default:dry_dirt_with_dry_grass",
		num_spawn_by = 8
	})
end

if ethereal.plains == 1 then
	minetest.register_decoration({
		name = "ethereal:scorched_log",
		deco_type = "schematic",
		place_on = {"ethereal:dry_dirt"},
		place_offset_y = 1,
		sidelen = 80,
		fill_ratio = 0.0018,
		biomes = {"plains"},
		y_max = 100,
		y_min = 4,

		schematic = {
			size = {x = 3, y = 1, z = 1},
			data = {
				{name = "ethereal:scorched_tree", param1 = 201, param2 = 16},
				{name = "ethereal:scorched_tree", param1 = 255, param2 = 16},
				{name = "ethereal:scorched_tree", param1 = 255, param2 = 16}
			}
		},
		flags = "place_center_x",
		rotation = "random",
		spawn_by = "ethereal:dry_dirt",
		num_spawn_by = 8
	})
end

if ethereal.grove == 1 then
	minetest.register_decoration({
		name = "ethereal:banana_log",
		deco_type = "schematic",
		place_on = {"ethereal:grove_dirt"},
		place_offset_y = 1,
		sidelen = 80,
		fill_ratio = 0.0018,
		biomes = {"grove"},
		y_max = 100,
		y_min = 4,

		schematic = {
			size = {x = 3, y = 1, z = 1},
			data = {
				{name = "ethereal:banana_trunk", param1 = 255, param2 = 16},
				{name = "ethereal:banana_trunk", param1 = 255, param2 = 16},
				{name = "ethereal:banana_trunk", param1 = 201, param2 = 16}
			}
		},
		flags = "place_center_x",
		rotation = "random",
		spawn_by = "ethereal:grove_dirt",
		num_spawn_by = 8
	})
end

end

