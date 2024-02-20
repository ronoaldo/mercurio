
local S = minetest.get_translator("nether_mobs")

-- Nether Man by rael5

mobs:register_mob("nether_mobs:netherman", {
	type = "monster",
	passive = false,
	group_attack = true,
	attack_type = "dogfight",
	pathfinding = false,
	reach = 2,
	damage = 8,
	hp_min = 15,
	hp_max = 25,
	armor = 100,
	collisionbox = {-0.4, -1, -0.4, 0.4, 0.8, 0.4},
	visual = "mesh",
	mesh = "mobs_netherman.b3d",
	textures = {
		{"mobs_netherman.png"},
	},
	blood_texture = "nether_particle.png",
	makes_footstep_sound = true,
	sounds = {
		random = "mobs_netherman",
	},
	walk_velocity = 1.5,
	run_velocity = 5,
	view_range = 8, --15
	jump = true,
	floats = 0,
	drops = {
		{name = "nether:sand", chance = 1, min = 1, max = 5},
		{name = "nether:rack", chance = 3, min = 1, max = 4},
		{name = "nether:brick", chance = 10, min = 1, max = 2},
		{name = "nether:brick_compressed", chance = 80, min = 1, max = 1},
		{name = "nether:glowstone", chance = 5, min = 1, max = 2},
		{name = "nether:glowstone_deep", chance = 10, min = 1, max = 1},
	},
	water_damage = 10,
	lava_damage = 1,
	light_damage = 1,
	fear_height = 4,
	animation = {
		speed_normal = 15,
		speed_run = 15,
		stand_start = 0,
		stand_end = 39,
		walk_start = 41,
		walk_end = 72,
		run_start = 74,
		run_end = 105,
		punch_start = 74,
		punch_end = 105,
	},
	replace_rate = 3,
	replace_what = {
			"default:sand",
			"default:silver_sand",
			"default:dirt_with_grass",
			"default:dirt_with_snow",
			"default:dirt_with_dry_grass",
			"default:dirt_with_rainforest_litter",
			"default:dirt",
                    },
	replace_with = "nether:sand",
	replace_offset = -2,
	immune_to = {

	},
	on_die = function(self, pos)
		pos.y = pos.y + 0.5
		mobs:effect(pos, 30, "nether_particle.png", 0.1, 2, 3, 5)
		pos.y = pos.y + 0.25
		mobs:effect(pos, 30, "nether_particle.png", 0.1, 2, 3, 5)
	end,
})


mobs:spawn({
	max_light = 12, --15 = bright daylight
	name = "nether_mobs:netherman",
	nodes = {"nether:sand","nether:rack","nether:rack_deep"},
	max_height = nethermobs.MAX_HEIGHT_NETHERMAN,
	min_height = nethermobs.MIN_HEIGHT_NETHERMAN,
	interval = 8,
	chance = 50,
	day_toggle = nil,
	active_object_count = 5,
	on_spawn = function(self, pos)
		pos.y = pos.y + 0.5
		mobs:effect(pos, 30, "nether_particle.png", 0.1, 2, 3, 5)
		pos.y = pos.y + 0.25
		mobs:effect(pos, 30, "nether_particle.png", 0.1, 2, 3, 5)
	end,
})


mobs:register_egg("nether_mobs:netherman", S("nether man"), "nether_sand.png", 1)


mobs:alias_mob("mobs:netherman", "nether_mobs:netherman") -- compatibility
