-- are regular animals and monsters enabled
if dmobs.regulars then

	-- friendlies

	mobs:spawn({
		name = "dmobs:nyan",
		nodes = {"air"},
		neighbor = {"group:leaves", "ethereal:mushroom", "nyanland:meseleaves"},
		min_light = 10,
		interval = 300,
		chance = 64000,
		active_object_count = 2,
		min_height = 0,
		max_height = 2000
	})

	mobs:spawn({
		name = "dmobs:hedgehog",
		nodes = {"group:flora", "ethereal:prairie_dirt"},
		max_light = 8,
		interval = 300,
		chance = 8000,
		active_object_count = 3,
		min_height = 0,
		max_height = 2000
	})

	mobs:spawn({
		name = "dmobs:whale",
		nodes = {"default:water_source"},
		neighbor = {"group:sand"},
		interval = 300,
		chance = 16000,
		active_object_count = 2,
		min_height = -100,
		max_height = 0
	})

	mobs:spawn({
		name = "dmobs:owl",
		nodes = {"group:tree"},
		max_light = 7,
		interval = 300,
		chance = 16000,
		active_object_count = 2,
		min_height = 0,
		max_height = 2000
	})

	mobs:spawn({
		name = "dmobs:gnorm",
		nodes = {"default:dirt_with_grass", "ethereal:bamboo_dirt"},
		min_light = 10,
		interval = 300,
		chance = 32000,
		active_object_count = 2,
		min_height = -100,
		max_height = 0
	})

	mobs:spawn({
		name = "dmobs:tortoise",
		nodes = {"default:water_source", "group:sand"},
		min_light = 5,
		max_light = 10,
		interval = 300,
		chance = 8000,
		active_object_count = 2,
		min_height = -100,
		max_height = 500
	})

	mobs:spawn({
		name = "dmobs:elephant",
		nodes = {"default:dirt_with_dry_grass", "ethereal:grove_dirt"},
		min_light = 10,
		interval = 300,
		chance = 16000,
		active_object_count = 2,
		min_height = 0,
		max_height = 2000
	})

	mobs:spawn({
		name = "dmobs:pig",
		nodes = {"default:dirt_with_grass", "ethereal:prairie_dirt", "nyanland:cloudstone"},
		min_light = 10,
		interval = 300,
		chance = 32000,
		active_object_count = 2,
		min_height = 0,
		max_height = 2000
	})

	mobs:spawn({
		name = "dmobs:panda",
		nodes = {"default:dirt_with_grass", "ethereal:bamboo_dirt"},
		min_light = 10,
		interval = 300,
		chance = 32000,
		active_object_count = 2,
		min_height = 0,
		max_height = 2000
	})

	-- baddies

	mobs:spawn({
		name = "dmobs:wasp",
		nodes = {"air"},
		neighbor = {"group:leaves"},
		min_light = 10,
		interval = 300,
		chance = 32000,
		active_object_count = 2,
		min_height = 0,
		max_height = 2000
	})

	mobs:spawn({
		name = "dmobs:wasp",
		nodes = {"dmobs:hive"},
		min_light = 10,
		interval = 300,
		chance = 16000,
		active_object_count = 2,
		min_height = 0,
		max_height = 2000
	})

	mobs:spawn({
		name = "dmobs:wasp_leader",
		nodes = {"group:leaves", "dmobs:hive"},
		min_light = 10,
		interval = 300,
		chance = 64000,
		active_object_count = 2,
		min_height = 0,
		max_height = 2000
	})

	mobs:spawn({
		name = "dmobs:golem",
		nodes = {"group:stone"},
		max_light = 7,
		interval = 300,
		chance = 16000,
		active_object_count = 2,
		max_height = 100
	})

	mobs:spawn({
		name = "dmobs:pig_evil",
		nodes = {"group:leaves", "ethereal:bamboo_leaves"},
		min_light = 10,
		interval = 300,
		chance = 64000,
		active_object_count = 2,
		min_height = 0,
		max_height = 2000
	})

	mobs:spawn({
		name = "dmobs:fox",
		nodes = {"group:leaves"},
		max_light = 10,
		interval = 300,
		chance = 32000,
		active_object_count = 2,
		min_height = 0,
		max_height = 2000
	})

	mobs:spawn({
		name = "dmobs:rat",
		nodes = {"group:stone", "group:sand"},
		max_light = 10,
		interval = 300,
		chance = 32000,
		active_object_count = 2,
		max_height = 100
	})

	mobs:spawn({
		name = "dmobs:treeman",
		nodes = {"group:leaves"},
		min_light = 7,
		interval = 300,
		chance = 16000,
		active_object_count = 2,
		min_height = 0,
		max_height = 2000
	})

	mobs:spawn({
		name = "dmobs:skeleton",
		nodes = {"group:stone","caverealms:stone_with_salt","default:desert_sand"},
		max_light = 10,
		interval = 300,
		chance = 16000,
		active_object_count = 2,
		max_height = -1000
	})

	-- Orcs and ogres spawn more often when dragons are disabled

	mobs:spawn({
		name = "dmobs:orc",
		nodes = {
			"default:snow_block", "default:permafrost_with_moss",
			"default:permafrost_with_stone", "ethereal:cold_dirt"
		},
		max_light = 10,
		interval = 300,
		chance = dmobs.dragons and 8000 or 6000,
		active_object_count = 2,
		min_height = 0,
		max_height = 2000
	})

	mobs:spawn({
		name = "dmobs:ogre",
		nodes = {
			"default:snow_block", "default:permafrost_with_moss",
			"default:permafrost_with_stone", "ethereal:cold_dirt"
		},
		max_light = 10,
		interval = 300,
		chance = dmobs.dragons and 32000 or 16000,
		active_object_count = 2,
		min_height = 0,
		max_height = 2000
	})
end

-- dragons (generic dragon always spawns, even if others are disabled)

mobs:spawn({
	name = "dmobs:dragon",
	nodes = {"group:leaves"},
	min_light = 5,
	interval = 300,
	chance = 16000,
	active_object_count = 2,
	min_height = 0
})

-- are dragons enabled
if dmobs.dragons then

	mobs:spawn({
		name = "dmobs:dragon1",
		nodes = {"ethereal:fiery_dirt", "default:desert_sand"},
		min_light = 5,
		interval = 300,
		chance = 24000,
		active_object_count = 2,
		min_height = 0
	})

	mobs:spawn({
		name = "dmobs:dragon2",
		nodes = {"ethereal:crystal_dirt", "default:dirt_with_dry_grass"},
		min_light = 5,
		interval = 300,
		chance = 24000,
		active_object_count = 2,
		min_height = 0
	})

	mobs:spawn({
		name = "dmobs:dragon3",
		nodes = {"ethereal:jungle_dirt", "default:jungleleaves"},
		max_light = 10,
		interval = 300,
		chance = 24000,
		active_object_count = 2,
		min_height = 0
	})

	mobs:spawn({
		name = "dmobs:dragon4",
		nodes = {
			"default:snow_block", "default:permafrost_with_moss",
			"default:permafrost_with_stone", "ethereal:cold_dirt"
		},
		min_light = 5,
		interval = 300,
		chance = 24000,
		active_object_count = 2,
		min_height = 0
	})

	mobs:spawn({
		name = "dmobs:waterdragon",
		nodes = {"default:water_source"},
		interval = 300,
		chance = 32000,
		active_object_count = 2,
		min_height = -10,
		max_height = 100
	})

	mobs:spawn({
		name = "dmobs:wyvern",
		nodes = {"group:leaves"},
		max_light = 10,
		interval = 300,
		chance = 32000,
		active_object_count = 2,
		min_height = 0
	})

	mobs:spawn({
		name = "dmobs:dragon_great",
		nodes = {
			"ethereal:jungle_dirt", "default:jungleleaves",
			"default:lava_source", "caverealms:glow_mese",
			"caverealms:glow_amethyst", "caverealms:glow_crystal",
			"caverealms:glow_emerald","cavereals:glow_ruby"
		},
		interval = 300,
		chance = 32000,
		active_object_count = 2
	})
end
