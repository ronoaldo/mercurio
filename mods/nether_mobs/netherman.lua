
local S = mobs.intllib


-- custom particle effects

local effect = function(pos, amount, texture, min_size, max_size, radius, gravity, glow)

	radius = radius or 2
	min_size = min_size or 0.5
	max_size = max_size or 1
	gravity = gravity or -10
	glow = glow or 0

	minetest.add_particlespawner({
		amount = amount,
		time = 0.25,
		minpos = pos,
		maxpos = pos,
		minvel = {x = -radius, y = -radius, z = -radius},
		maxvel = {x = radius, y = radius, z = radius},
		minacc = {x = 0, y = gravity, z = 0},
		maxacc = {x = -20, y = gravity, z = 15},
		minexptime = 0.1,
		maxexptime = 1,
		minsize = min_size,
		maxsize = max_size,
		texture = texture,
		glow = glow,
	})
end


-- Nether Man by rael5

mobs:register_mob("nether_mobs:netherman", {
	type = "monster",
	passive = false,
	group_attack = true,
	attack_type = "dogfight",
	pathfinding = false,
	reach = 2,
	damage = 1,
	hp_min = 10,
	hp_max = 20,
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
		{name = "nether:sand", chance = 1, min = 3, max = 5},
		{name = "nether:rack", chance = 3, min = 2, max = 4},
		{name = "nether:brick", chance = 5, min = 1, max = 2},
	},
	water_damage = 10,
	lava_damage = 2,
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
	replace_rate = 1/1000,
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
		effect(pos, 30, "nether_particle.png", 0.1, 2, 3, 5)
		pos.y = pos.y + 0.25
		effect(pos, 30, "nether_particle.png", 0.1, 2, 3, 5)
	end,
})


mobs:spawn({
	max_light = 15,
	name = "nether_mobs:netherman",
	nodes = {"nether:sand", "nether:rack"},
	interval = 2,
	chance = 2,
	day_toggle = nil,
	active_object_count = 2,
	on_spawn = function(self, pos)
		pos.y = pos.y + 0.5
		effect(pos, 30, "nether_particle.png", 0.1, 2, 3, 5)
		pos.y = pos.y + 0.25
		effect(pos, 30, "nether_particle.png", 0.1, 2, 3, 5)
	end,
})


mobs:register_egg("nether_mobs:netherman", S("nether man"), "nether_sand.png", 1)


mobs:alias_mob("mobs:netherman", "nether_mobs:netherman") -- compatibility
