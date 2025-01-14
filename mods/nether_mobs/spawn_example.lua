--[[ Spawn Template, defaults to values shown if line not provided

mobs:spawn({

	name = "",

		- Name of mob, must be provided e.g. "mymod:my_mob"

	nodes = {"group:soil, "group:stone"},

		- Nodes to spawn on top of.

	neighbors = {"air"},

		- Nodes to spawn beside.

	min_light = 0,

		- Minimum light level.

	max_light = 15,

		- Maximum light level, 15 is sunlight only.

	interval = 30,

		- Spawn interval in seconds.

	chance = 5000,

		- Spawn chance, 1 in every 5000 nodes.

	active_object_count = 1,

		- Active mobs of this type in area.

	min_height = -31000,

		- Minimum height level.

	max_height = 31000,

		- Maximum height level.

	day_toggle = nil,

		- Daytime toggle, true to spawn during day, false for night, nil for both

	on_spawn = nil,

		- On spawn function to run when mob spawns in world

	on_map_load = nil,

		- On map load, when true mob only spawns in newly generated map areas
})
]]--

mobs:spawn({
	name = "nether_mobs:dragon",
	nodes = {"nether:rack","nether:rack_deep"},
		neighbours = "air",
	max_light = 14,
	max_height = -5000,
	min_height = -11000,
	interval = 100,
	chance = 64000,
	day_toggle = nil,
	active_object_count = 2,
	on_spawn = function(self, pos)
		pos.y = pos.y + 0.5
		mobs:effect(pos, 30, "nether_particle.png", 0.1, 2, 3, 5)
		pos.y = pos.y + 0.25
		mobs:effect(pos, 30, "nether_particle.png", 0.1, 2, 3, 5)
	end,
})

mobs:spawn({
	max_light = 12,
	name = "nether_mobs:netherman",
	nodes = {"nether:sand","nether:rack","nether:rack_deep"},
	max_height = -5000,
	min_height = -11000,
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
