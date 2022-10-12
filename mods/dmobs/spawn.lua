-- spawn.lua rewritten, using this latest function frim mobs_redo :
--
--mobs:spawn({
--            name = "dmobs:dragon",
--            nodes = {"air"},
--            neighbor = {"default:stone"},
--            min_light = 10,
--            max_light = 15,
--            interval = 300,
--            chance = 15000,
--            active_object_count = 2,
--            min_height = -100,
--            max_height = 11000,
--})
--
-- The fonction creates a rule defining how a mob will spawn.
-- Call it several times to create several rules.


-- mobs:spawn() seems to ignore unloaded nodes. So no need checking for loaded mods ?
--local eth = minetest.get_modpath("ethereal")
--local cr = minetest.get_modpath("caverealms")
--local nodes, neighbor = {}, {}

if dmobs.regulars then
	-- friendlies
--	nodes = {"darkage:marble"}
--	neighbor = {"darkage:slate"}
	mobs:spawn({name = "dmobs:nyan", nodes = {"air"}, neighbor = {"group:leaves"},
		min_light = 10, max_light = 15, interval = 300, chance = 64000, active_object_count = 2, min_height = 0, max_height = 2000})
	mobs:spawn({name = "dmobs:nyan", nodes = {"air"}, neighbor = {"ethereal:mushroom", "nyanland:meseleaves"},
		min_light = 10, max_light = 15, interval = 300, chance = 16000, active_object_count = 2, min_height = 0, max_height = 2000})
	mobs:spawn({name = "dmobs:hedgehog", nodes = {"group:flora", "ethereal:prairie_dirt"},
		neighbor = {}, min_light = 0, max_light = 8, interval = 300, chance = 8000, active_object_count = 3, min_height = 0, max_height = 2000})
	mobs:spawn({name = "dmobs:whale", nodes = {"default:water_source"}, neighbor = {"group:sand"},
		min_light = 0, max_light = 15, interval = 300, chance = 16000, active_object_count = 2, min_height = -100, max_height = 0})
	mobs:spawn({name = "dmobs:owl", nodes = {"group:tree"}, neighbor = {},
		min_light = 0, max_light = 7, interval = 300, chance = 16000, active_object_count = 2, min_height = 0, max_height = 2000})
	mobs:spawn({name = "dmobs:gnorm", nodes = {"default:dirt_with_grass", "ethereal:bamboo_dirt"}, neighbor = {},
		min_light = 10, max_light = 15, interval = 300, chance = 32000, active_object_count = 2, min_height = -100, max_height = 0})
	mobs:spawn({name = "dmobs:tortoise", nodes = {"default:water_source", "group:sand"}, neighbor = {},
		min_light = 5, max_light = 10, interval = 300, chance = 8000, active_object_count = 2, min_height = -100, max_height = 500})
	mobs:spawn({name = "dmobs:elephant", nodes = {"default:dirt_with_dry_grass", "ethereal:grove_dirt"}, neighbor = {},
		min_light = 10, max_light = 15, interval = 300, chance = 16000, active_object_count = 2, min_height = 0, max_height = 2000})
	mobs:spawn({name = "dmobs:pig", nodes = {"default:dirt_with_grass", "ethereal:prairie_dirt", "nyanland:cloudstone"}, neighbor = {},
		min_light = 10, max_light = 15, interval = 300, chance = 32000, active_object_count = 2, min_height = 0, max_height = 2000})
	mobs:spawn({name = "dmobs:panda", nodes = {"default:dirt_with_grass", "ethereal:bamboo_dirt"}, neighbor = {},
		min_light = 10, max_light = 15, interval = 300, chance = 32000, active_object_count = 2, min_height = 0, max_height = 2000})


	-- baddies

	mobs:spawn({name = "dmobs:wasp", nodes = {"air"}, neighbor = {"group:leaves"}, min_light = 10, max_light = 15, interval = 300, chance = 32000, active_object_count = 2, min_height = 0, max_height = 2000})
	mobs:spawn({name = "dmobs:wasp", nodes = {"dmobs:hive"}, neighbor = {}, min_light = 10, max_light = 15, interval = 300, chance = 16000, active_object_count = 2, min_height = 0, max_height = 2000})
	mobs:spawn({name = "dmobs:wasp_leader", nodes = {"group:leaves", "dmobs:hive"}, neighbor = {}, min_light = 10, max_light = 15, interval = 300, chance = 64000, active_object_count = 2, min_height = 0, max_height = 2000})

	mobs:spawn({name = "dmobs:golem", nodes = {"group:stone"}, neighbor = {}, min_light = 0,
		max_light = 7, interval = 300, chance = 16000, active_object_count = 2, min_height = -32000, max_height = 100})
	mobs:spawn({name = "dmobs:pig_evil", nodes = {"group:leave", "ethereal:bamboo_leaves"}, neighbor = {},
		min_light = 10, max_light = 15, interval = 300, chance = 64000, active_object_count = 2, min_height = 0, max_height = 2000})
	mobs:spawn({name = "dmobs:fox", nodes = {"group:leaves"}, neighbor = {},
		min_light = 0, max_light = 10, interval = 300, chance = 32000, active_object_count = 2, min_height = 0, max_height = 2000})
	mobs:spawn({name = "dmobs:rat", nodes = {"group:stone", "group:sand"}, neighbor = {},
		min_light = 0, max_light = 10, interval = 300, chance = 32000, active_object_count = 2, min_height = -30000, max_height = 100})
	mobs:spawn({name = "dmobs:treeman", nodes = {"group:leaves"}, neighbor = {},
		min_light = 7, max_light = 15, interval = 300, chance = 16000, active_object_count = 2, min_height = 0, max_height = 2000})
	mobs:spawn({name = "dmobs:skeleton", nodes = {"group:stone","caverealms:stone_with_salt","default:desert_sand"}, neighbor = {},
		min_light = 0, max_light = 10, interval = 300, chance = 16000, active_object_count = 2, min_height = -31000, max_height = -1000})

-- Orcs and ogres spawn more often when dragons are disabled
	if not dmobs.dragons then
		mobs:spawn({name = "dmobs:orc",
			nodes = {"default:snow_block", "default:permafrost_with_moss", "default:permafrost_with_stone", "ethereal:cold_dirt"},
			neighbor = {}, min_light = 0, max_light = 10, interval = 300, chance = 6000,
			active_object_count = 2, min_height = 0, max_height = 2000})
		mobs:spawn({name = "dmobs:ogre",
			nodes = {"default:snow_block", "default:permafrost_with_moss", "default:permafrost_with_stone", "ethereal:cold_dirt"},
			neighbor = {}, min_light = 0, max_light = 10, interval = 300, chance = 16000,
			active_object_count = 2, min_height = 0, max_height = 2000})
	else
		mobs:spawn({name = "dmobs:orc",
			nodes = {"default:snow_block", "default:permafrost_with_moss", "default:permafrost_with_stone", "ethereal:cold_dirt"},
			neighbor = {}, min_light = 0, max_light = 10, interval = 300, chance = 8000,
			active_object_count = 2, min_height = 0, max_height = 2000})
		mobs:spawn({name = "dmobs:ogre",
			nodes = {"default:snow_block", "default:permafrost_with_moss", "default:permafrost_with_stone", "ethereal:cold_dirt"},
			neighbor = {}, min_light = 0, max_light = 10, interval = 300, chance = 32000,
			active_object_count = 2, min_height = 0, max_height = 2000})
	end
end


-------------
-- dragons --
-------------

-- Generic dragon always spawn, the others only if enabled
mobs:spawn({name = "dmobs:dragon", nodes = {"group:leaves"}, neighbor = {},
	min_light = 5, max_light = 15, interval = 300, chance = 16000, active_object_count = 2, min_height = 0, max_height = 30000})

if dmobs.dragons then
	mobs:spawn({name = "dmobs:dragon1", nodes = {"ethereal:fiery_dirt", "default:desert_sand"}, neighbor = {},
		min_light = 5, max_light = 15, interval = 300, chance = 24000, active_object_count = 2, min_height = 0, max_height = 30000})
	mobs:spawn({name = "dmobs:dragon2", nodes = {"ethereal:crystal_dirt", "default:dirt_with_dry_grass"}, neighbor = {},
		min_light = 5, max_light = 15, interval = 300, chance = 24000, active_object_count = 2, min_height = 0, max_height = 30000})
	mobs:spawn({name = "dmobs:dragon3", nodes = {"ethereal:jungle_dirt", "default:jungleleaves"}, neighbor = {},
		min_light = 0, max_light = 10, interval = 300, chance = 24000, active_object_count = 2, min_height = 0, max_height = 30000})
	mobs:spawn({name = "dmobs:dragon4",
		nodes = {"default:snow_block", "default:permafrost_with_moss", "default:permafrost_with_stone", "ethereal:cold_dirt"}, neighbor = {},
		min_light = 5, max_light = 15, interval = 300, chance = 24000, active_object_count = 2, min_height = 0, max_height = 30000})
	mobs:spawn({name = "dmobs:waterdragon", nodes = {"default:water_source"}, neighbor = {"air"},
		min_light = 0, max_light = 15, interval = 300, chance = 32000, active_object_count = 2, min_height = -10, max_height = 100})
	mobs:spawn({name = "dmobs:wyvern", nodes = {"group:leaves"}, neighbor = {},
		min_light = 0, max_light = 10, interval = 300, chance = 32000, active_object_count = 2, min_height = 0, max_height = 30000})
	mobs:spawn({name = "dmobs:dragon_great",
		nodes = {"ethereal:jungle_dirt", "default:jungleleaves", "default:lava_source", "caverealms:glow_mese",
			"caverealms:glow_amethyst", "caverealms:glow_crystal", "caverealms:glow_emerald","cavereals:glow_ruby"}, neighbor = {},
		min_light = 0, max_light = 15, interval = 300, chance = 32000, active_object_count = 2, min_height = -30000, max_height = 30000})
end
