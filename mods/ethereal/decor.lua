
-- wild cotton added in 5.3.0

if minetest.registered_nodes["farming:cotton_wild"] then

	minetest.register_decoration({
		name = "farming:cotton_wild",
		deco_type = "simple",
		place_on = {"default:dry_dirt_with_dry_grass"},
		sidelen = 16,
		noise_params = {
			offset = -0.1,
			scale = 0.1,
			spread = {x = 50, y = 50, z = 50},
			seed = 4242,
			octaves = 3,
			persist = 0.7
		},
		biomes = {"savanna"},
		y_max = 31000,
		y_min = 1,
		decoration = "farming:cotton_wild"
	})
end

-- water pools in swamp areas

minetest.register_decoration({
	deco_type = "simple",
	place_on = {"default:dirt_with_grass"},
	place_offset_y = -1,
	sidelen = 16,
	fill_ratio = 0.01,
	biomes = {"swamp"},
	y_max = 2,
	y_min = 1,
	flags = "force_placement",
	decoration = "default:water_source",
	spawn_by = "default:dirt_with_grass",
	num_spawn_by = 8
})

minetest.register_decoration({
	deco_type = "simple",
	place_on = {"default:dirt_with_grass"},
	place_offset_y = -1,
	sidelen = 16,
	fill_ratio = 0.1,
	biomes = {"swamp"},
	y_max = 2,
	y_min = 1,
	flags = "force_placement",
	decoration = "default:water_source",
	spawn_by = {"default:dirt_with_grass", "default:water_source"},
	num_spawn_by = 8
})

-- dry dirt patches

minetest.register_decoration({
	deco_type = "simple",
	place_on = {"default:dry_dirt_with_dry_grass"},
	sidelen = 4,
	noise_params = {
		offset = -1.5,
		scale = -1.5,
		spread = {x = 200, y = 200, z = 200},
		seed = 329,
		octaves = 4,
		persist = 1.0
	},
	biomes = {"savanna"},
	y_max = 31000,
	y_min = 1,
	decoration = "default:dry_dirt",
	place_offset_y = -1,
	flags = "force_placement"
})

-- helper string

local tmp

-- decoration helper function

local function add_deco(a, b, c, d, e, f, g, h, i, j)

	if j ~= 1 then return end

	minetest.register_decoration({
		deco_type = "simple",
		place_on = a,
		sidelen = 80,
		fill_ratio = b,
		biomes = c,
		y_min = d,
		y_max = e,
		decoration = f,
		height_max = g,
		spawn_by = h,
		num_spawn_by = i
	})
end

--firethorn shrub

add_deco({"default:snowblock"}, 0.001, {"glacier"}, 1, 30,
	{"ethereal:firethorn"}, nil, nil, nil, ethereal.glacier)

-- scorched tree

add_deco({"ethereal:dry_dirt"}, 0.006, {"plains"}, 1, 100,
	{"ethereal:scorched_tree"}, 6, nil, nil, ethereal.plains)

-- dry shrub

add_deco({"ethereal:dry_dirt"}, 0.015, {"plains"}, 1, 100,
	{"default:dry_shrub"}, nil, nil, nil, ethereal.plains)

add_deco({"default:sand"}, 0.015, {"deciduous_forest_ocean"}, 1, 100,
	{"default:dry_shrub"}, nil, nil, nil, ethereal.grassy)

add_deco({"default:desert_sand"}, 0.015, {"desert"}, 1, 100,
	{"default:dry_shrub"}, nil, nil, nil, ethereal.desert)

add_deco({"default:sandstone"}, 0.015, {"sandstone_desert"}, 1, 100,
	{"default:dry_shrub"}, nil, nil, nil, ethereal.sandstone)

add_deco({"bakedclay:red", "bakedclay:orange"}, 0.015, {"mesa"}, 1, 100,
	{"default:dry_shrub"}, nil, nil, nil, ethereal.mesa)

-- dry grass

add_deco({"default:dry_dirt_with_dry_grass",
	"default:dirt_with_dry_grass"}, 0.25, {"savanna"}, 1, 100,
	{"default:dry_grass_2", "default:dry_grass_3", "default:dry_grass_4",
	"default:dry_grass_5"}, nil, nil, nil, ethereal.savanna)

add_deco({"default:dirt_with_dry_grass"}, 0.10, {"mesa"}, 1, 100,
	{"default:dry_grass_2", "default:dry_grass_3", "default:dry_grass_4",
	"default:dry_grass_5"}, nil, nil, nil, ethereal.mesa)

add_deco({"default:desert_stone"}, 0.005, {"caves"}, 5, 40,
	{"default:dry_grass_2", "default:dry_grass_3", "default:dry_shrub"},
	nil, nil, nil, ethereal.caves)

-- flowers & strawberry

add_deco({"default:dirt_with_grass"}, 0.025, {"deciduous_forest"}, 1, 100,
	{"flowers:dandelion_white", "flowers:dandelion_yellow",
	"flowers:geranium", "flowers:rose", "flowers:tulip",
	"flowers:viola", "ethereal:strawberry_7"}, nil, nil, nil,
	ethereal.grassy)

add_deco({"default:dirt_with_grass"}, 0.025, {"grassytwo"}, 1, 100,
	{"flowers:dandelion_white", "flowers:dandelion_yellow",
	"flowers:geranium", "flowers:rose", "flowers:tulip",
	"flowers:viola", "ethereal:strawberry_7"}, nil, nil, nil,
	ethereal.grassytwo)

-- prairie flowers & strawberry

add_deco({"ethereal:prairie_dirt"}, 0.035, {"prairie"}, 1, 100,
	{"flowers:dandelion_white", "flowers:dandelion_yellow",
	"flowers:geranium", "flowers:rose", "flowers:tulip",
	"flowers:viola", "ethereal:strawberry_7",
	"flowers:chrysanthemum_green", "flowers:tulip_black"}, nil, nil, nil,
	ethereal.prairie)

-- crystal spike & crystal grass

add_deco({"ethereal:crystal_dirt"}, 0.02, {"frost", "frost_floatland"}, 1, 1750,
	{"ethereal:crystal_spike", "ethereal:crystalgrass"}, nil, nil, nil,
	ethereal.frost)

-- red shrub

add_deco({"ethereal:fiery_dirt"}, 0.10, {"fiery"}, 1, 100,
	{"ethereal:dry_shrub"}, nil, nil, nil, ethereal.fiery)

-- snowy grass
add_deco({"ethereal:gray_dirt"}, 0.05, {"grayness"}, 1, 100,
	{"ethereal:snowygrass"}, nil, nil, nil, ethereal.grayness)

add_deco({"ethereal:cold_dirt", "default:dirt_with_coniferous_litter"}, 0.05,
	{"coniferous_forest"}, 1, 100, {"ethereal:snowygrass"}, nil, nil, nil, ethereal.snowy)

-- cactus

add_deco({"default:sandstone"}, 0.002, {"sandstone_desert"}, 1, 100,
	{"default:cactus"}, 3, nil, nil, ethereal.sandstone)

add_deco({"default:desert_sand"}, 0.005, {"desert"}, 1, 100,
	{"default:cactus"}, 4, nil, nil, ethereal.desert)

-- spore grass

add_deco({"ethereal:mushroom_dirt"}, 0.1, {"mushroom"}, 1, 100,
	{"ethereal:spore_grass"}, nil, nil, nil, ethereal.mushroom)

-- red and brown mushrooms

minetest.register_decoration({
	deco_type = "simple",
	place_on = {
		"default:dirt_with_rainforest_litter", "default:dirt_with_grass",
		"ethereal:prairie_dirt", "ethereal:mushroom_dirt"
	},
	sidelen = 16,
	fill_ratio = 0.01,
	biomes = {
		"junglee", "deciduous_forest", "grassytwo", "prairie", "swamp", "mushroom"
	},
	y_min = 1,
	y_max = 120,
	decoration = {"flowers:mushroom_brown", "flowers:mushroom_red"}
})

-- jungle grass

add_deco({"ethereal:jungle_dirt", "default:dirt_with_rainforest_litter"},
	0.10, {"junglee"}, 1, 100, {"default:junglegrass"}, nil, nil, nil,
	ethereal.junglee)

add_deco({"default:dirt_with_grass"}, 0.15, {"jumble"}, 1, 100,
	{"default:junglegrass"}, nil, nil, nil, ethereal.jumble)

add_deco({"default:dirt_with_grass"}, 0.25, {"swamp"}, 1, 100,
	{"default:junglegrass"}, nil, nil, nil, ethereal.swamp)

-- grass

add_deco({"default:dirt_with_grass"}, 0.35, {"deciduous_forest"}, 1, 100,
	{"default:grass_2", "default:grass_3", "default:grass_4",
	"default:grass_5"}, nil, nil, nil, ethereal.grassy)

add_deco({"default:dirt_with_grass"}, 0.35, {"grassytwo"}, 1, 100,
	{"default:grass_2", "default:grass_3", "default:grass_4",
	"default:grass_5"}, nil, nil, nil, ethereal.grassytwo)

add_deco({"default:dirt_with_grass"}, 0.35, {"jumble"}, 1, 100,
	{"default:grass_2", "default:grass_3", "default:grass_4",
	"default:grass_5"}, nil, nil, nil, ethereal.jumble)

add_deco({"ethereal:jungle_dirt", "default:dirt_with_rainforest_litter"},
	0.35, {"junglee"}, 1, 100, {"default:grass_2", "default:grass_3",
	"default:grass_4", "default:grass_5"}, nil, nil, nil, ethereal.junglee)

add_deco({"ethereal:prairie_dirt"}, 0.35, {"prairie"}, 1, 100,
	{"default:grass_2", "default:grass_3", "default:grass_4",
	"default:grass_5"}, nil, nil, nil, ethereal.prairie)

add_deco({"ethereal:grove_dirt"}, 0.35, {"grove"}, 1, 100,
	{"default:grass_2", "default:grass_3", "default:grass_4",
	"default:grass_5"}, nil, nil, nil, ethereal.grove)

add_deco({"ethereal:grove_dirt"}, 0.35, {"mediterranean"}, 1, 100,
	{"default:grass_2", "default:grass_3", "default:grass_4",
	"default:grass_5"}, nil, nil, nil, ethereal.mediterranean)

add_deco({"ethereal:bamboo_dirt"}, 0.35, {"bamboo"}, 1, 100,
	{"default:grass_2", "default:grass_3", "default:grass_4",
	"default:grass_5"}, nil, nil, nil, ethereal.bamboo)

add_deco({"default:dirt_with_grass"}, 0.35, {"grassland", "swamp"},
	1, 100, {"default:grass_3", "default:grass_4"}, nil, nil, nil, 1)

add_deco({"ethereal:bamboo_dirt"}, 0.35, {"sakura"}, 1, 100,
	{"default:grass_2", "default:grass_3", "default:grass_4",
	"default:grass_5"}, nil, nil, nil, ethereal.sakura)

add_deco({"ethereal:bamboo_dirt"}, 0.025, {"sakura"}, 1, 100,
	{"ethereal:lilac"}, nil, nil, nil, ethereal.sakura)

-- marram grass

add_deco({"default:sand"}, 0.25, {"sandclay"}, 3, 4, {"default:marram_grass_1",
	"default:marram_grass_2", "default:marram_grass_3"}, nil, nil, nil,
	ethereal.sandclay)

-- ferns

add_deco({"ethereal:grove_dirt"}, 0.2, {"grove"}, 1, 100, {"ethereal:fern"},
	nil, nil, nil, ethereal.grove)

add_deco({"default:dirt_with_grass"}, 0.1, {"swamp"}, 1, 100,
	{"ethereal:fern"}, nil, nil, nil, ethereal.swamp)

add_deco({"ethereal:crystal_dirt"}, 0.001, {"frost_floatlands"}, 1025, 1750,
	{"ethereal:fern"}, nil, nil, nil, ethereal.frost)

-- snow

add_deco({"ethereal:cold_dirt", "default:dirt_with_coniferous_litter"},
	0.8, {"coniferous_forest"}, 20, 40, {"default:snow"}, nil, nil, nil, ethereal.snowy)

add_deco({"default:dirt_with_snow"}, 0.8, {"taiga"}, 40, 140,
	{"default:snow"}, nil, nil, nil, ethereal.alpine)

-- Check onion setting

local abundant = minetest.settings:get_bool("ethereal.abundant_onions") ~= false
local onion_rate = abundant and 0.025 or 0.005

-- wild onion

add_deco({"default:dirt_with_grass", "ethereal:prairie_dirt"}, onion_rate,
	{"deciduous_forest", "grassytwo", "jumble", "prairie"}, 1, 100,
	{"ethereal:onion_4"}, nil, nil, nil, 1)

-- papyrus

add_deco({"default:dirt_with_grass"}, 0.1, {"deciduous_forest"}, 1, 1,
	{"default:papyrus"}, 4, "default:water_source", 1, ethereal.grassy)

add_deco({"ethereal:jungle_dirt", "default:dirt_with_rainforest_litter"},
	0.1, {"junglee"}, 1, 1, {"default:papyrus"}, 4, "default:water_source",
	1, ethereal.junglee)

add_deco({"default:dirt_with_grass"}, 0.1, {"swamp"}, 1, 1,
	{"default:papyrus"}, 4, "default:water_source", 1, ethereal.swamp)

--= Farming Redo plants

if farming and farming.mod and farming.mod == "redo" then

print ("[MOD] Ethereal - Farming Redo detected and in use")

-- potato

add_deco({"ethereal:jungle_dirt", "default:dirt_with_rainforest_litter"},
	0.002, {"junglee"}, 1, 100, {"farming:potato_3"}, nil, nil, nil,
	ethereal.junglee)

-- carrot, cucumber, potato, tomato, corn, coffee, raspberry, rhubarb

add_deco({"default:dirt_with_grass"}, 0.002, {"grassytwo"}, 1, 100,
	{"farming:carrot_7", "farming:cucumber_4", "farming:potato_3", "farming:vanilla_7",
	"farming:tomato_7", "farming:corn_8", "farming:coffee_5", "farming:blackberry_4",
	"farming:raspberry_4", "farming:rhubarb_3", "farming:blueberry_4",
	"farming:cabbage_6", "farming:lettuce_5", "farming:sunflower_8",
	"farming:asparagus"}, nil, nil, nil,
	ethereal.grassytwo)

add_deco({"default:dirt_with_grass"}, 0.002, {"deciduous_forest"}, 1, 100,
	{"farming:carrot_7", "farming:cucumber_4", "farming:potato_3", "farming:vanilla_7",
	"farming:tomato_7", "farming:corn_8", "farming:coffee_5", "farming:blackberry_4",
	"farming:raspberry_4", "farming:rhubarb_3", "farming:blueberry_4",
	"farming:beetroot_5", "farming:sunflower_8",
	"farming:eggplant_3"}, nil, nil, nil, ethereal.grassy)

add_deco({"default:dirt_with_grass"}, 0.002, {"jumble"}, 1, 100,
	{"farming:carrot_7", "farming:cucumber_4", "farming:potato_3", "farming:vanilla_7",
	"farming:tomato_7", "farming:corn_8", "farming:coffee_5", "farming:blackberry_4",
	"farming:raspberry_4", "farming:rhubarb_3", "farming:blueberry_4",
	"farming:cabbage_6", "farming:lettuce_5",
	"farming:spinach_3"}, nil, nil, nil, ethereal.jumble)

add_deco({"ethereal:prairie_dirt"}, 0.025, {"prairie"}, 1, 100,
	{"farming:carrot_7", "farming:cucumber_4", "farming:potato_3", "farming:parsley_3",
	"farming:tomato_7", "farming:corn_8", "farming:coffee_5", "farming:blackberry_4",
	"farming:raspberry_4", "farming:rhubarb_3", "farming:blueberry_4",
	"farming:pea_5", "farming:beetroot_5", "farming:sunflower_8"}, nil, nil, nil,
	ethereal.prairie)

add_deco({"ethereal:grove_dirt"}, 0.002, {"mediterranean"}, 1, 100,
	{"farming:parsley_3"}, nil, nil, nil, ethereal.mediterranean)

-- melon and pumpkin

add_deco({"ethereal:jungle_dirt", "default:dirt_with_rainforest_litter"},
	0.001, {"junglee"}, 1, 1, {"farming:melon_8", "farming:pumpkin_8"},
	nil, "default:water_source", 1, ethereal.junglee)

add_deco({"default:dirt_with_grass"}, 0.001, {"deciduous_forest"}, 1, 1,
	{"farming:melon_8", "farming:pumpkin_8"}, nil, "default:water_source",
	1, ethereal.grassy)

add_deco({"default:dirt_with_grass"}, 0.001, {"grassytwo"}, 1, 1,
	{"farming:melon_8", "farming:pumpkin_8"}, nil, "default:water_source",
	1, ethereal.grassytwo)

add_deco({"default:dirt_with_grass"}, 0.001, {"jumble"}, 1, 1,
	{"farming:melon_8", "farming:pumpkin_8"}, nil, "default:water_source",
	1, ethereal.jumble)

-- mint

add_deco({"default:dirt_with_grass", "default:dirt_with_coniferous_litter",
	"ethereal:bamboo_dirt"}, 0.005, nil, 1, 75, "farming:mint_4", nil,
	{"group:water", "group:sand"}, 1, 1)

-- green beans

add_deco({"default:dirt_with_grass"}, 0.001, {"grassytwo"}, 1, 100,
	{"farming:beanbush"}, nil, nil, nil, ethereal.grassytwo)

-- grape bushel

add_deco({"default:dirt_with_grass"}, 0.001, {"grassytwo"}, 1, 100,
	{"farming:grapebush"}, nil, nil, nil, ethereal.grassytwo)

add_deco({"default:dirt_with_grass"}, 0.001, {"deciduous_forest"}, 1, 100,
	{"farming:grapebush"}, nil, nil, nil, ethereal.grassy)

add_deco({"ethereal:prairie_dirt"}, 0.001, {"prairie"}, 1, 100,
	{"farming:grapebush"}, nil, nil, nil, ethereal.prairie)

-- chili, garlic, pepper, onion, hemp, soy, ginger

minetest.register_decoration({
	deco_type = "simple",
	place_on = {"default:dirt_with_grass", "ethereal:prairie_dirt",
			"default:dirt_with_rainforest_litter"},
	sidelen = 16,
	noise_params = {
		offset = 0,
		scale = 0.002,
		spread = {x = 100, y = 100, z = 100},
		seed = 760,
		octaves = 3,
		persist = 0.6
	},
	y_min = 5,
	y_max = 35,
	decoration = {
		"farming:chili_8", "farming:garlic_5", "farming:pepper_5", "farming:pepper_6",
		"farming:onion_5", "farming:hemp_7", "farming:pepper_7", "farming:soy_5",
		"farming:ginger"
	},
	spawn_by = "group:tree",
	num_spawn_by = 1
})

-- pineapple,soy

minetest.register_decoration({
	deco_type = "simple",
	place_on = {"default:dirt_with_dry_grass"},
	sidelen = 16,
	noise_params = {
		offset = 0,
		scale = 0.002,
		spread = {x = 100, y = 100, z = 100},
		seed = 917,
		octaves = 3,
		persist = 0.6
	},
	y_min = 18,
	y_max = 30,
	decoration = {"farming:pineapple_8", "farming:soy_5"}
})

-- artichoke

minetest.register_decoration({
	deco_type = "simple",
	place_on = {"ethereal:grove_dirt"},
	sidelen = 16,
	noise_params = {
		offset = 0,
		scale = 0.002,
		spread = {x = 100, y = 100, z = 100},
		seed = 448,
		octaves = 3,
		persist = 0.6
	},
	y_min = 15,
	y_max = 40,
	decoration = {"farming:artichoke_5"},
	spawn_by = "group:tree",
	num_spawn_by = 1
})
end

-- new flowers from baked clay mod

if minetest.get_modpath("bakedclay") then

minetest.register_decoration({
	deco_type = "simple",
	place_on = {
		"ethereal:prairie_dirt", "default:dirt_with_grass", "ethereal:grove_dirt"
	},
	sidelen = 16,
	noise_params = {
		offset = 0,
		scale = 0.004,
		spread = {x = 100, y = 100, z = 100},
		seed = 7133,
		octaves = 3,
		persist = 0.6
	},
	y_min = 10,
	y_max = 90,
	decoration = "bakedclay:delphinium"
})

minetest.register_decoration({
	deco_type = "simple",
	place_on = {
		"ethereal:prairie_dirt", "default:dirt_with_grass",
		"ethereal:grove_dirt", "ethereal:bamboo_dirt"
	},
	sidelen = 16,
	noise_params = {
		offset = 0,
		scale = 0.004,
		spread = {x = 100, y = 100, z = 100},
		seed = 7134,
		octaves = 3,
		persist = 0.6
	},
	y_min = 15,
	y_max = 90,
	decoration = "bakedclay:thistle"
})

minetest.register_decoration({
	deco_type = "simple",
	place_on = {"ethereal:jungle_dirt", "default:dirt_with_rainforest_litter"},
	sidelen = 16,
	noise_params = {
		offset = 0,
		scale = 0.01,
		spread = {x = 100, y = 100, z = 100},
		seed = 7135,
		octaves = 3,
		persist = 0.6
	},
	y_min = 1,
	y_max = 90,
	decoration = "bakedclay:lazarus",
	spawn_by = "default:jungletree",
	num_spawn_by = 1
})

minetest.register_decoration({
	deco_type = "simple",
	place_on = {"default:dirt_with_grass", "default:sand"},
	sidelen = 16,
	noise_params = {
		offset = 0,
		scale = 0.009,
		spread = {x = 100, y = 100, z = 100},
		seed = 7136,
		octaves = 3,
		persist = 0.6
	},
	y_min = 1,
	y_max = 15,
	decoration = "bakedclay:mannagrass",
	spawn_by = "group:water",
	num_spawn_by = 1
})
end

-- blue agave from wine mod

if ethereal.desert == 1 and minetest.get_modpath("wine") then

	minetest.register_decoration({
		deco_type = "simple",
		place_on = {"default:desert_sand"},
		sidelen = 16,
		fill_ratio = 0.001,
		biomes = {"desert"},
		decoration = {"wine:blue_agave"}
	})
end


if ethereal.snowy == 1 then

	local function register_fern_decoration(seed, length)

		minetest.register_decoration({
			name = "default:fern_" .. length,
			deco_type = "simple",
			place_on = {
				"ethereal:cold_dirt", "default:dirt_with_coniferous_litter"},
			sidelen = 16,
			noise_params = {
				offset = 0,
				scale = 0.2,
				spread = {x = 100, y = 100, z = 100},
				seed = seed,
				octaves = 3,
				persist = 0.7
			},
			y_max = 31000,
			y_min = 6,
			decoration = "default:fern_" .. length
		})
	end

	register_fern_decoration(14936, 3)
	register_fern_decoration(801, 2)
	register_fern_decoration(5, 1)
end

-- Tundra moss and stones

if ethereal.tundra == 1 then

	-- Tundra moss

	minetest.register_decoration({
		deco_type = "simple",
		place_on = {"default:permafrost_with_stones"},
		sidelen = 4,
		noise_params = {
			offset = -0.8,
			scale = 2.0,
			spread = {x = 100, y = 100, z = 100},
			seed = 53995,
			octaves = 3,
			persist = 1.0
		},
		biomes = {"tundra"},
		y_max = 50,
		y_min = 2,
		decoration = "default:permafrost_with_moss",
		place_offset_y = -1,
		flags = "force_placement"
	})

	-- Tundra patchy snow

	minetest.register_decoration({
		deco_type = "simple",
		place_on = {
			"default:permafrost_with_moss",
			"default:permafrost_with_stones",
			"default:stone",
			"default:gravel"
		},
		sidelen = 4,
		noise_params = {
			offset = 0,
			scale = 1.0,
			spread = {x = 100, y = 100, z = 100},
			seed = 172555,
			octaves = 3,
			persist = 1.0
		},
		biomes = {"tundra", "tundra_beach"},
		y_max = 50,
		y_min = 1,
		decoration = "default:snow"
	})
end

-- butterflies mod

if minetest.get_modpath("butterflies") then

	minetest.register_decoration({
		name = "butterflies:butterfly",
		deco_type = "simple",
		place_on = {"default:dirt_with_grass", "ethereal:prairie_dirt"},
		place_offset_y = 2,
		sidelen = 80,
		fill_ratio = 0.005,
		biomes = {"deciduous_forest", "grassytwo", "prairie", "jumble"},
		y_max = 31000,
		y_min = 1,
		decoration = {
			"butterflies:butterfly_white",
			"butterflies:butterfly_red",
			"butterflies:butterfly_violet"
		},
		spawn_by = "group:flower",
		num_spawn_by = 1
	})

	-- restart butterfly timers
	minetest.register_lbm({
		name = ":butterflies:butterfly_timer",
		nodenames = {
			"butterflies:butterfly_white", "butterflies:butterfly_red",
			"butterflies:butterfly_violet"
		},
		run_at_every_load = true,

		action = function(pos) minetest.get_node_timer(pos):start(5) end
	})
end

-- fireflies mod

if minetest.get_modpath("fireflies") then

	minetest.register_decoration({
		name = "fireflies:firefly_low",
		deco_type = "simple",
		place_on = {
			"default:dirt_with_grass",
			"default:dirt_with_coniferous_litter",
			"default:dirt_with_rainforest_litter",
			"default:dirt",
			"ethereal:cold_dirt", "prairie"
		},
		place_offset_y = 2,
		sidelen = 80,
		fill_ratio = 0.0005,
		biomes = {
			"deciduous_forest", "grassytwo", "coniferous_forest", "junglee", "swamp"},
		y_max = 31000,
		y_min = -1,
		decoration = "fireflies:hidden_firefly"
	})

	-- restart firefly timers
	minetest.register_lbm({
		name = ":fireflies:firefly_timer",
		nodenames = {"fireflies:firefly", "fireflies:hidden_firefly"},
		run_at_every_load = true,

		action = function(pos) minetest.get_node_timer(pos):start(5) end
	})
end

-- Coral Reef

minetest.register_decoration({
	name = "default:corals",
	deco_type = "simple",
	place_on = {"default:sand"},
	place_offset_y = -1,
	sidelen = 4,
	noise_params = {
		offset = -4,
		scale = 4,
		spread = {x = 50, y = 50, z = 50},
		seed = 7013,
		octaves = 3,
		persist = 0.7,
	},
	biomes = {"desert_ocean", "savanna_ocean", "junglee_ocean"},
	y_max = -2,
	y_min = -8,
	flags = "force_placement",
	decoration = {
		"default:coral_green", "default:coral_pink",
		"default:coral_cyan", "default:coral_brown",
		"default:coral_orange", "default:coral_skeleton"
	}
})

-- Kelp

minetest.register_decoration({
	name = "default:kelp",
	deco_type = "simple",
	place_on = {"default:sand"},
	place_offset_y = -1,
	sidelen = 16,
	noise_params = {
		offset = -0.04,
		scale = 0.1,
		spread = {x = 200, y = 200, z = 200},
		seed = 87112,
		octaves = 3,
		persist = 0.7
	},
	biomes = {
		"frost_ocean", "deciduous_forest_ocean", "sandstone_ocean", "swamp_ocean"},
	y_max = -5,
	y_min = -10,
	flags = "force_placement",
	decoration = "default:sand_with_kelp",
	param2 = 48,
	param2_max = 96
})

-- illumishrooms using underground decoration placement

local function add_illumishroom(low, high, nodename)

	minetest.register_decoration({
		deco_type = "simple",
		place_on = {"default:stone_with_coal"},
		sidelen = 16,
		fill_ratio = 0.5,
		y_max = high,
		y_min = low,
		flags = "force_placement, all_floors",
		decoration = nodename
	})
end

add_illumishroom(-1000, -30, "ethereal:illumishroom")
add_illumishroom(-2000, -1000, "ethereal:illumishroom2")
add_illumishroom(-3000, -2000, "ethereal:illumishroom3")
