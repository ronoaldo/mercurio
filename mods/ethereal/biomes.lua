
-- helper function

local function add_biome(a, l, m, n, o, p, b, c, d, e, f, g, nd, na, ns)

	if p ~= 1 then return end -- if not 1 then biome disabled

	minetest.register_biome({
		name = a,
		node_dust = b,
		node_top = c,
		depth_top = d,
		node_filler = e,
		depth_filler = f,
		node_stone = g,
--		node_water_top = h,
--		depth_water_top = i,
--		node_water = j,
--		node_river_water = k,
		y_min = l,
		y_max = m,
		heat_point = n,
		humidity_point = o,

		node_dungeon = nd or "default:cobble",
		node_dungeon_alt = (nd and "") or "default:mossycobble",
		node_dungeon_stair = ns or "stairs:stair_cobble"
	})
end

-- always registered biomes

add_biome("mountain", 140, 31000, 50, 50, 1,
	nil, "default:snow", 1, "default:snowblock", 2)

add_biome("grassland", 3, 71, 45, 65, 1,
	nil, "default:dirt_with_grass", 1, "default:dirt", 3)

add_biome("grassland_ocean", -192, 2, 45, 65, 1,
	nil, "default:sand", 1, "default:sand", 3)

minetest.register_biome({
	name = "grassland_under",
	node_cave_liquid = {"default:water_source", "default:lava_source"},
	node_dungeon = "default:cobble",
	node_dungeon_alt = "default:mossycobble",
	node_dungeon_stair = "stairs:stair_cobble",
	y_max = -256,
	y_min = -31000,
	heat_point = 45,
	humidity_point = 65
})

--add_biome("underground", -31000, -192, 50, 50, 1,
--	nil, nil, nil, nil, nil)

-- biomes with disable setting

add_biome("desert", 3, 23, 35, 20, ethereal.desert,
	nil, "default:desert_sand", 1, "default:desert_sand", 3, "default:desert_stone",
	"default:desert_stone", nil, "stairs:stair_desert_stone")

add_biome("desert_ocean", -192, 3, 35, 20, ethereal.desert,
	nil, "default:sand", 1, "default:sand", 2, "default:desert_stone",
	"default:desert_stone", nil, "stairs:stair_desert_stone")

if ethereal.desert then

	minetest.register_biome({
		name = "desert_under",
		node_cave_liquid = {"default:water_source", "default:lava_source"},
		node_dungeon = "default:cobble",
		node_dungeon_alt = "default:mossycobble",
		node_dungeon_stair = "stairs:stair_cobble",
		y_max = -256,
		y_min = -31000,
		heat_point = 35,
		humidity_point = 20
	})
end

add_biome("bamboo", 25, 70, 45, 75, ethereal.bamboo,
	nil, "ethereal:bamboo_dirt", 1, "default:dirt", 3)

add_biome("sakura", 3, 25, 45, 75, ethereal.sakura,
	nil, "ethereal:bamboo_dirt", 1, "default:dirt", 3)

add_biome("sakura_ocean", -192, 2, 45, 75, ethereal.sakura,
	nil, "default:sand", 1, "default:sand", 2)


add_biome("mesa", 1, 71, 25, 28, ethereal.mesa,
	nil, "default:dirt_with_dry_grass", 1, "bakedclay:orange", 15)

add_biome("mesa_ocean", -192, 2, 25, 28, ethereal.mesa,
	nil, "default:sand", 1, "default:sand", 2)

-- was 'snowy' biome
add_biome("coniferous_forest", 5, 40, 10, 40, ethereal.snowy,
	nil, "default:dirt_with_coniferous_litter", 1, "default:dirt", 2)

add_biome("coniferous_forest_ocean", -192, 1, 10, 40, (ethereal.snowy or ethereal.frost),
	nil, "default:silver_sand", 1, "default:sand", 2)

if ethereal.snowy then

	minetest.register_biome({
		name = "coniferous_forest_under",
		node_cave_liquid = {"default:water_source", "default:lava_source"},
		node_dungeon = "default:cobble",
		node_dungeon_alt = "default:mossycobble",
		node_dungeon_stair = "stairs:stair_cobble",
		y_max = -256,
		y_min = -31000,
		heat_point = 10,
		humidity_point = 40
	})
end

add_biome("taiga", 40, 140, 10, 40, ethereal.alpine,
	nil, "default:dirt_with_snow", 1, "default:dirt", 2)

if ethereal.alpine then

	minetest.register_biome({
		name = "taiga_under",
		node_cave_liquid = {"default:water_source", "default:lava_source"},
		node_dungeon = "default:cobble",
		node_dungeon_alt = "default:mossycobble",
		node_dungeon_stair = "stairs:stair_cobble",
		y_max = -256,
		y_min = -31000,
		heat_point = 10,
		humidity_point = 40
	})
end

add_biome("frost_floatland", 1025, 1750, 10, 40, ethereal.frost,
	nil, "ethereal:crystal_dirt", 1, "default:dirt", 1)

add_biome("frost", 1, 71, 10, 40, ethereal.frost,
	nil, "ethereal:crystal_dirt", 1, "default:dirt", 3)


add_biome("deciduous_forest", 3, 91, 13, 40, ethereal.grassy,
	nil, "default:dirt_with_grass", 1, "default:dirt", 3)

add_biome("deciduous_forest_ocean", -31000, 3, 13, 40, ethereal.grassy,
	nil, "default:sand", 2, "default:gravel", 1)

if ethereal.grassy then

	minetest.register_biome({
		name = "deciduous_forest_under",
		node_cave_liquid = {"default:water_source", "default:lava_source"},
		node_dungeon = "default:cobble",
		node_dungeon_alt = "default:mossycobble",
		node_dungeon_stair = "stairs:stair_cobble",
		y_max = -256,
		y_min = -31000,
		heat_point = 13,
		humidity_point = 40
	})
end

add_biome("caves", 4, 41, 15, 25, ethereal.caves,
	nil, "default:desert_stone", 3, "air", 8)

add_biome("grayness", 2, 41, 15, 30, ethereal.grayness,
	nil, "ethereal:gray_dirt", 1, "default:dirt", 3)

add_biome("grayness_ocean", -18, 2, 15, 30, ethereal.grayness,
	nil, "default:silver_sand", 2, "default:sand", 2, "ethereal:blue_marble")

if ethereal.grayness then

	minetest.register_biome({
		name = "grayness_under",
		node_cave_liquid = {"default:water_source", "default:lava_source"},
		node_dungeon = "default:cobble",
		node_dungeon_alt = "default:mossycobble",
		node_dungeon_stair = "stairs:stair_cobble",
		y_max = -256,
		y_min = -31000,
		heat_point = 15,
		humidity_point = 30
	})
end

add_biome("grassytwo", 1, 91, 15, 40, ethereal.grassytwo,
	nil, "default:dirt_with_grass", 1, "default:dirt", 3)

add_biome("grassytwo_ocean", -192, 2, 15, 40, ethereal.grassytwo,
	nil, "default:sand", 1, "default:sand", 2)


add_biome("prairie", 3, 26, 20, 40, ethereal.prairie,
	nil, "ethereal:prairie_dirt", 1, "default:dirt", 3)

add_biome("prairie_ocean", -192, 2, 20, 40, ethereal.prairie,
	nil, "default:sand", 1, "default:sand", 2)


add_biome("jumble", 1, 71, 25, 50, ethereal.jumble,
	nil, "default:dirt_with_grass", 1, "default:dirt", 3)

add_biome("jumble_ocean", -192, 1, 25, 50, ethereal.jumble,
	nil, "default:sand", 1, "default:sand", 2)

add_biome("junglee", 1, 71, 30, 60, ethereal.junglee,
	nil, "default:dirt_with_rainforest_litter", 1, "default:dirt", 3)

add_biome("junglee_ocean", -192, 2, 30, 60, ethereal.junglee,
	nil, "default:sand", 1, "default:sand", 2)

if ethereal.junglee then

	minetest.register_biome({
		name = "junglee_under",
		node_cave_liquid = {"default:water_source", "default:lava_source"},
		node_dungeon = "default:cobble",
		node_dungeon_alt = "default:mossycobble",
		node_dungeon_stair = "stairs:stair_cobble",
		y_max = -256,
		y_min = -31000,
		heat_point = 30,
		humidity_point = 60
	})
end

add_biome("grove", 3, 23, 45, 35, ethereal.grove,
	nil, "ethereal:grove_dirt", 1, "default:dirt", 3)

add_biome("grove_ocean", -192, 2, 45, 35, ethereal.grove,
	nil, "default:sand", 1, "default:sand", 2)


add_biome("mediterranean", 3, 50, 20, 45, ethereal.mediterranean,
	nil, "ethereal:grove_dirt", 1, "default:dirt", 3)


add_biome("mushroom", 3, 50, 45, 55, ethereal.mushroom,
	nil, "ethereal:mushroom_dirt", 1, "default:dirt", 3)

add_biome("mushroom_ocean", -192, 2, 45, 55, ethereal.mushroom,
	nil, "default:sand", 1, "default:sand", 2)


add_biome("sandstone_desert", 3, 23, 50, 20, ethereal.sandstone,
	nil, "default:sandstone", 1, "default:sandstone", 1, "default:sandstone",
	"default:sandstone", nil, "stairs:stair_sandstone")

add_biome("sandstone_desert_ocean", -192, 2, 50, 20, ethereal.sandstone,
	nil, "default:sand", 1, "default:sand", 2, "default:sandstone",
	"default:sandstone", nil, "stairs:stair_sandstone")

if ethereal.sandstone then

	minetest.register_biome({
		name = "sandstone_desert_under",
		node_cave_liquid = {"default:water_source", "default:lava_source"},
		node_dungeon = "default:cobble",
		node_dungeon_alt = "default:mossycobble",
		node_dungeon_stair = "stairs:stair_cobble",
		y_max = -256,
		y_min = -31000,
		heat_point = 50,
		humidity_point = 20
	})
end

add_biome("quicksand", 1, 1, 50, 38, ethereal.quicksand,
	nil, "ethereal:quicksand2", 3, "default:gravel", 1)


add_biome("plains", 3, 25, 65, 25, ethereal.plains,
	nil, "ethereal:dry_dirt", 1, "default:dirt", 3)

add_biome("plains_ocean", -192, 2, 55, 25, ethereal.plains,
	nil, "default:sand", 1, "default:sand", 2)

add_biome("savanna", 3, 50, 55, 25, ethereal.savanna,
	nil, "default:dry_dirt_with_dry_grass", 1, "default:dry_dirt", 3)

add_biome("savanna_ocean", -192, 2, 55, 25, ethereal.savanna,
	nil, "default:sand", 1, "default:sand", 2)

if ethereal.savanna then

	minetest.register_biome({
		name = "savanna_under",
		node_cave_liquid = {"default:water_source", "default:lava_source"},
		node_dungeon = "default:cobble",
		node_dungeon_alt = "default:mossycobble",
		node_dungeon_stair = "stairs:stair_cobble",
		y_max = -256,
		y_min = -31000,
		heat_point = 55,
		humidity_point = 25
	})
end

add_biome("fiery", 5, 20, 75, 10, ethereal.fiery,
	nil, "ethereal:fiery_dirt", 1, "default:dirt", 3)

add_biome("fiery_beach", 1, 4, 75, 10, ethereal.fiery,
	nil, "default:desert_sand", 1, "default:sand", 2)

add_biome("fiery_ocean", -192, 2, 75, 10, ethereal.fiery,
	nil, "default:sand", 1, "default:sand", 2)

if ethereal.fiery then

	minetest.register_biome({
		name = "fiery_under",
		node_cave_liquid = {"default:lava_source"},
		node_dungeon = "default:cobble",
		node_dungeon_alt = "default:mossycobble",
		node_dungeon_stair = "stairs:stair_cobble",
		y_max = -256,
		y_min = -31000,
		heat_point = 75,
		humidity_point = 10
	})
end

add_biome("sandclay", 1, 11, 65, 2, ethereal.sandclay,
	nil, "default:sand", 3, "default:clay", 2)


add_biome("swamp", 1, 7, 80, 90, ethereal.swamp,
	nil, "default:dirt_with_grass", 1, "default:dirt", 3)

add_biome("swamp_ocean", -192, 2, 80, 90, ethereal.swamp,
	nil, "default:sand", 2, "default:clay", 2)


if ethereal.glacier == 1 then

	minetest.register_biome({
		name = "glacier",
		node_dust = "default:snowblock",
		node_top = "default:snowblock",
		depth_top = 1,
		node_filler = "default:snowblock",
		depth_filler = 3,
		node_stone = "default:ice",
		node_water_top = "default:ice",
		depth_water_top = 10,
		node_river_water = "default:ice",
		node_riverbed = "default:gravel",
		depth_riverbed = 2,
		node_dungeon = "ethereal:icebrick",
		node_dungeon_stair = "stairs:stair_ice",
		y_min = -8,
		y_max = 31000,
		heat_point = 0,
		humidity_point = 50
	})

	minetest.register_biome({
		name = "glacier_ocean",
		node_dust = "default:snowblock",
		node_top = "default:sand",
		depth_top = 1,
		node_filler = "default:sand",
		depth_filler = 3,
		y_min = -112,
		y_max = -9,
		heat_point = 0,
		humidity_point = 50
	})

	minetest.register_biome({
		name = "glacier_under",
		node_cave_liquid = {"default:water_source", "default:lava_source"},
		node_dungeon = "default:cobble",
		node_dungeon_alt = "default:mossycobble",
		node_dungeon_stair = "stairs:stair_cobble",
		y_max = -256,
		y_min = -31000,
		heat_point = 0,
		humidity_point = 50
	})
end


if ethereal.tundra == 1 then

	minetest.register_biome({
		name = "tundra_highland",
		node_dust = "default:snow",
		node_riverbed = "default:gravel",
		depth_riverbed = 2,
		y_max = 180,
		y_min = 47,
		heat_point = 0,
		humidity_point = 40
	})

	minetest.register_biome({
		name = "tundra",
		node_top = "default:permafrost_with_stones",
		depth_top = 1,
		node_filler = "default:permafrost",
		depth_filler = 1,
		node_riverbed = "default:gravel",
		depth_riverbed = 2,
		vertical_blend = 4,
		y_max = 46,
		y_min = 2,
		heat_point = 0,
		humidity_point = 40
	})

	minetest.register_biome({
		name = "tundra_beach",
		node_top = "default:gravel",
		depth_top = 1,
		node_filler = "default:gravel",
		depth_filler = 2,
		node_riverbed = "default:gravel",
		depth_riverbed = 2,
		vertical_blend = 1,
		y_max = 1,
		y_min = -3,
		heat_point = 0,
		humidity_point = 40
	})

	minetest.register_biome({
		name = "tundra_ocean",
		node_top = "default:sand",
		depth_top = 1,
		node_filler = "default:sand",
		depth_filler = 3,
		node_riverbed = "default:gravel",
		depth_riverbed = 2,
		vertical_blend = 1,
		y_max = -4,
		y_min = -112,
		heat_point = 0,
		humidity_point = 40
	})

	minetest.register_biome({
		name = "tundra_under",
		node_cave_liquid = {"default:water_source", "default:lava_source"},
		node_dungeon = "default:cobble",
		node_dungeon_alt = "default:mossycobble",
		node_dungeon_stair = "stairs:stair_cobble",
		y_max = -256,
		y_min = -31000,
		heat_point = 0,
		humidity_point = 40
	})
end
