
-- add lucky blocks

if minetest.get_modpath("lucky_block") then



lucky_block:add_blocks({
	{"dro", "ethereal:etherium_dust", 1},
	{"nod", "etherium_stuff:crystal_water_source"},
	{"dro", {"etherium_stuff:bucket_crystal_water"}, 3},
	{"dro", {"etherium_stuff:crystal_glass"}, 3},
	{"dro", {"etherium_stuff:glass"}, 3},
	{"nod", "etherium_stuff:glass"},
	{"nod", "etherium_stuff:crystal_glass"},
	{"dro", {"etherium_stuff:sand"}, 10},
	{"dro", {"etherium_stuff:sandstone"}, 10},
	{"dro", {"etherium_stuff:sandstone_brick"}, 10},
	{"dro", {"etherium_stuff:sandstone_block"}, 10},
	{"dro", {"etherium_stuff:sandstone_light_block"}, 5},
	{"dro", {"etherium_stuff:torch"}, 8},

	{"fal", {"etherium_stuff:sand", "etherium_stuff:sand", "etherium_stuff:sand", "etherium_stuff:sand"}, 0, true, 6},
	{"fal", {"etherium_stuff:sand", "etherium_stuff:sand", "etherium_stuff:sand", "etherium_stuff:sand","etherium_stuff:sand","etherium_stuff:sand"}, 1, true, 7},
	{"tro", "etherium_stuff:crystal_glass", "tnt_ignite", true},
	{"tro", "tnt:tnt_burning", "tnt_ignite", false},
	{"lig", "etherium_stuff:sand"},
	{"flo", 3, {"etherium_stuff:sand", "default:sand", "default:desert_sand", "default:silver_sand"}, 2},
	{"tel", 5, 50},
	{"tel", 5, 80},
	{"tel", 50, 50},
	{"exp", 9},
	{"sch", "acaciatree", 0, true, {{"default:acacia_tree", "etherium_stuff:sandstone"},{"default:acacia_leaves", "etherium_stuff:crystal_glass"} }},
	{"sch", "defpinetree", 0, true, {{"default:pine_tree", "etherium_stuff:sandstone"},{"default:pine_needles", "etherium_stuff:crystal_glass"} }},
	{"sch", "aspentree", 0, true, {{"default:aspen_tree", "lucky_block:lucky_block"},{"default:aspen_leaves", "lucky_block:super_lucky_block"} }},
	{"sch", "largecactus", 0, true, {{"default:cactus", "etherium_stuff:sandstone_brick"}}},

	{"sch", "sandtrap", 1, true, {{"default:sand", "etherium_stuff:sand"}} },
	{"fal", {"etherium_stuff:crystal_water_source", "etherium_stuff:crystal_water_source", "etherium_stuff:crystal_water_source", "etherium_stuff:crystal_water_source","etherium_stuff:crystal_water_source","etherium_stuff:crystal_water_source"}, 1, true, 10},


	
	})

lucky_block:add_chest_items({
	{name = "ethereal:etherium_dust", max = 2, chance = 5},
	{name = "etherium_stuff:bucket_crystal_water", max = 1},
	{name = "etherium_stuff:crystal_glass", max = 3, chance = 4},
	{name = "etherium_stuff:glass", max = 3, chance = 3},
	{name = "etherium_stuff:sand", max = 4},
	{name = "etherium_stuff:sandstone", max = 4},
	{name = "etherium_stuff:sandstone_brick", max = 4},
	{name = "etherium_stuff:sandstone_block", max = 4},
	{name = "etherium_stuff:sandstone_light_block", max = 4},
	{name = "etherium_stuff:torch", max = 4},
	})

end
