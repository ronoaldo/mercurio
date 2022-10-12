-- Fox

mobs:register_mob("dmobs:fox", {
	type = "monster",
	attacks_monsters = true,
	reach = 1,
	damage = 2,
	attack_type = "dogfight",
	hp_min = 42,
	hp_max = 52,
	armor = 130,
	collisionbox = {-0.4, -0.6, -0.4, 0.3, 0.3, 0.3},
	runaway = true,
	pathfinding = true,
	visual = "mesh",
	mesh = "fox.b3d",
	textures = {
		{"dmobs_fox.png"},
	},
	blood_texture = "mobs_blood.png",
	visual_size = {x=1.5, y=1.5},
	makes_footstep_sound = true,
	walk_velocity = 1,
	run_velocity = 2.5,
	jump = true,
	drops = {
		{name = "mobs:meat_raw", chance = 1, min = 1, max = 1},
	},
	on_activate = function(self)
		if math.random(1,5) == 1 then
		self.type = "animal"
		end
	end,
	water_damage = 0,
	lava_damage = 2,
	fire_damage = 2,
	light_damage = 0,
	fall_damage = 1,
	fear_height = 4,
	replace_rate = 10,
	replace_what = {
		"farming:wheat_5", "default:fence_wood", "default:grass_5",
		"default:dirt_with_grass"
	},
	replace_with = "air",
	follow = {"mobs:meat_raw"},
	view_range = 14,
	animation = {
		speed_normal = 6,
		speed_run = 15,
		walk_start = 25,
		walk_end = 35,
		stand_start = 51,
		stand_end = 60,
		run_start = 1,
		run_end = 16,
		punch_start = 36,
		punch_end = 51,
	},
	on_rightclick = function(self, clicker)

		if mobs:feed_tame(self, clicker, 8, true, true) then
			return
		end

		mobs:capture_mob(self, clicker, 0, 5, 50, false, nil)
	end,
})


mobs:register_egg("dmobs:fox", "Fox", "wool_orange.png", 1)
