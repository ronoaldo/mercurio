mobs:register_mob("nativevillages:cannibalking", {
	type = "monster",
	passive = false,
        attack_type = "shoot",
	shoot_interval = 1,
	arrow = "nativevillages:fireball",
	shoot_offset = 2,
	attack_animals = true,
        damage = 7,
	hp_min = 55,
	hp_max = 85,
	armor = 100,
	collisionbox = {-0.35,-1.0,-0.35, 0.35,0.8,0.35},
	visual = "mesh",
	mesh = "Cannibalking.b3d",
	visual_size = {x = 1.0, y = 1.0},
	textures = {
		{"texturecannibalking.png"},
	},
sounds = {
		random = "nativevillages_cannibalmale",
		shoot = "nativevillages_cannibalmale2",
		damage = "nativevillages_cannibalmale3",
		death = "nativevillages_cannibalmale4",
	},
	makes_footstep_sound = true,
	walk_velocity = 1.5,
	run_velocity = 3,
	runaway = false,
	jump = true,
        jump_height = 2,
        stepheight = 2,
        fear_height = 3,
	drops = {
		{name = "default:copper_lump", chance = 1, min = 1, max = 1},
	},
	water_damage = 5,
	lava_damage = 4,
	light_damage = 0,
	animation = {
		speed_normal = 50,
		stand_start = 0,
		stand_end = 100,
		walk_speed = 75,
		walk_start = 100,
		walk_end = 200,
		shoot_speed = 100,
		shoot_start = 200,
		shoot_end = 300,
	},
	view_range = 15,

	on_rightclick = function(self, clicker)

		-- feed or tame
		if mobs:feed_tame(self, clicker, 4, false, true) then return end
		if mobs:protect(self, clicker) then return end
		if mobs:capture_mob(self, clicker, 5, 50, 80, false, nil) then return end
	end,
})

if not mobs.custom_spawn_nativevillages then
mobs:spawn({
	name = "nativevillages:cannibalking",
	nodes = {"default:junglewood"},
	neighbors = {"nativevillages:cannibalshrine"},
	min_light = 0,
	interval = 60,
	chance = 2, -- 15000
	min_height = 0,
	max_height = 40,
})
end

mobs:register_arrow("nativevillages:fireball", {
	visual = "sprite",
	visual_size = {x=.5, y=.5},
	textures = {"nativevillages_fireball.png"},
	velocity = 12,
	drop = true,

	hit_player = function(self, player)
		player:punch(self.object, 1.0, {
		full_punch_interval=1.0,
		damage_groups = {fleshy=13},
                }, nil)
	end,

	hit_mob = function(self, player)
		player:punch(self.object, 1.0, {
		full_punch_interval=1.0,
		damage_groups = {fleshy=13},
                }, nil)
	end,

	hit_node = function(self, pos, node)
	end,
})


mobs:register_egg("nativevillages:cannibalking", ("Cannibal King"), "acannibalking.png")

mobs:register_mob("nativevillages:cannibalarcher", {
	type = "monster",
	passive = false,
	attack_type = "shoot",
	shoot_interval = 2,
	arrow = "people:bolt",
	shoot_offset = 2,
	attacks_monsters = false,
        damage = 4,
	hp_min = 55,
	hp_max = 85,
	armor = 100,
	collisionbox = {-0.35,-1.0,-0.35, 0.35,0.8,0.35},
	visual = "mesh",
	mesh = "Cannibalarcher.b3d",
	visual_size = {x = 1.0, y = 1.0},
	textures = {
		{"texturecannibalarcher.png"},
	},
sounds = {
		random = "nativevillages_cannibalmale",
		attack = "nativevillages_cannibalmale2",
		damage = "nativevillages_cannibalmale3",
		death = "nativevillages_cannibalmale4",
	},
	makes_footstep_sound = true,
	walk_velocity = 2,
	run_velocity = 3,
	runaway = false,
	jump = true,
        jump_height = 2,
        stepheight = 2,
        fear_height = 3,
	drops = {
		{name = "default:tin_lump", chance = 1, min = 1, max = 1},
	},
	water_damage = 5,
	lava_damage = 4,
	light_damage = 0,
	animation = {
		speed_normal = 50,
		stand_start = 0,
		stand_end = 100,
		walk_speed = 75,
		walk_start = 100,
		walk_end = 200,
		shoot_speed = 50,
		shoot_start = 200,
		shoot_end = 300,
	},
	view_range = 15,

	on_rightclick = function(self, clicker)

		-- feed or tame
		if mobs:feed_tame(self, clicker, 4, false, true) then return end
		if mobs:protect(self, clicker) then return end
		if mobs:capture_mob(self, clicker, 5, 50, 80, false, nil) then return end
	end,
})

if not mobs.custom_spawn_nativevillages then
mobs:spawn({
	name = "nativevillages:cannibalarcher",
	nodes = {"default:junglewood"},
	neighbors = {"nativevillages:cannibalshrine"},
	min_light = 0,
	interval = 60,
	chance = 2, -- 15000
	active_object_count = 2,
	min_height = 0,
	max_height = 40,
})
end

mobs:register_egg("nativevillages:cannibalarcher", ("Cannibal Hunter"), "acannibalarcher.png")

mobs:register_mob("nativevillages:cannibalmurderer", {
	type = "monster",
	passive = false,
        attack_type = "dogfight",
	attack_animals = true,
	reach = 2,
        damage = 6,
	hp_min = 55,
	hp_max = 85,
	armor = 100,
	collisionbox = {-0.35,-1.0,-0.35, 0.35,0.8,0.35},
	visual = "mesh",
	mesh = "Cannibalmurderer.b3d",
	visual_size = {x = 1.0, y = 1.0},
	textures = {
		{"texturecannibalmurderer.png"},
	},
sounds = {
		random = "nativevillages_cannibalfemale",
		attack = "nativevillages_cannibalfemale2",
		damage = "nativevillages_cannibalfemale3",
		death = "nativevillages_cannibalfemale4",
	},
	makes_footstep_sound = true,
	walk_velocity = 2,
	run_velocity = 3,
	runaway = false,
	jump = true,
        jump_height = 2,
        stepheight = 2,
        fear_height = 3,
	drops = {
		{name = "default:copper_lump", chance = 1, min = 1, max = 1},
	},
	water_damage = 5,
	lava_damage = 4,
	light_damage = 0,
	animation = {
		speed_normal = 50,
		stand_start = 0,
		stand_end = 100,
		walk_speed = 75,
		walk_start = 100,
		walk_end = 200,
		punch_speed = 100,
		punch_start = 200,
		punch_end = 300,
	},
	view_range = 15,

	on_rightclick = function(self, clicker)

		-- feed or tame
		if mobs:feed_tame(self, clicker, 4, false, true) then return end
		if mobs:protect(self, clicker) then return end
		if mobs:capture_mob(self, clicker, 5, 50, 80, false, nil) then return end
	end,
})

if not mobs.custom_spawn_nativevillages then
mobs:spawn({
	name = "nativevillages:cannibalmurderer",
	nodes = {"default:junglewood"},
	neighbors = {"nativevillages:driedpeople"},
	min_light = 0,
	interval = 60,
	active_object_count = 2,
	chance = 2, -- 15000
	min_height = 0,
	max_height = 40,
})
end

mobs:register_egg("nativevillages:cannibalmurderer", ("Cannibal Murderer"), "acannibalmurderer.png")

mobs:register_mob("nativevillages:cannibalchild", {
	type = "monster",
	passive = false,
        attack_type = "dogfight",
	attack_animals = true,
	reach = 2,
        damage = 6,
	hp_min = 15,
	hp_max = 35,
	armor = 100,
	collisionbox = {-0.35,-1.0,-0.35, 0.35,0.8,0.35},
	visual = "mesh",
	mesh = "Cannibalchild.b3d",
	visual_size = {x = 1, y = 1},
	textures = {
		{"texturecannibalchild.png"},
	},
sounds = {
		random = "nativevillages_cannibalchild3",
		attack = "nativevillages_cannibalchild2",
		damage = "nativevillages_cannibalchild",
	},
	makes_footstep_sound = true,
	walk_velocity = 3,
	run_velocity = 5,
	runaway = false,
        stepheight = 4,
        fear_height = 6,
	jump = true,
        jump_height = 4,
        stepheight = 2,
        fear_height = 5,
	drops = {
		{name = "default:iron_lump", chance = 1, min = 1, max = 1},
	},
	water_damage = 5,
	lava_damage = 4,
	light_damage = 0,
	animation = {
		speed_normal = 100,
		stand_start = 0,
		stand_end = 100,
		walk_speed = 150,
		walk_start = 100,
		walk_end = 200,
		punch_speed = 100,
		punch_start = 200,
		punch_end = 300,
	},
	view_range = 15,

	on_rightclick = function(self, clicker)

		-- feed or tame
		if mobs:feed_tame(self, clicker, 4, false, true) then return end
		if mobs:protect(self, clicker) then return end
		if mobs:capture_mob(self, clicker, 5, 50, 80, false, nil) then return end
	end,
})

if not mobs.custom_spawn_nativevillages then
mobs:spawn({
	name = "nativevillages:cannibalchild",
	nodes = {"default:junglewood"},
	neighbors = {"nativevillages:driedpeople"},
	min_light = 0,
	interval = 60,
	chance = 2, -- 15000
	active_object_count = 2,
	min_height = 0,
	max_height = 40,
})
end

mobs:register_egg("nativevillages:cannibalchild", ("Cannibal Child"), "acannibalchild.png")
