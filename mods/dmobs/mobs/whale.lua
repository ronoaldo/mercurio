mobs:register_mob("dmobs:whale", {
	type = "animal",
	passive = false,
	reach = 1,
	damage = 2,
	attack_type = "dogfight",
	hp_min = 52,
	hp_max = 82,
	armor = 230,
	collisionbox = {-0.9, -1.2, -0.9, 0.9, 0.9, 0.9},
	visual = "mesh",
	mesh = "whale.b3d",
	textures = {
		{"dmobs_whale.png"}
	},
	blood_texture = "mobs_blood.png",
	visual_size = {x = 2.5, y = 2.5},
	makes_footstep_sound = true,
	walk_velocity = 0.5,
	run_velocity = 1,
	jump = false,
	stepheight = 1.5,
	fall_damage = 0,
	fall_speed = -6,
	fly = true,
	fly_in = "default:water_source",
	water_damage = 0,
	lava_damage = 2,
	fire_damage = 2,
	light_damage = 0,
	follow = {"fishing:fish_cooked"},
	view_range = 14,
	drops = {
		{name = "mobs:meat_raw", chance = 1, min = 1, max = 1}
	},
	sounds = {
		random = "whale_1",
		death = "whale_1",
		distance = 128
	},
	animation = {
		speed_normal = 5,
		speed_run = 10,
		walk_start = 2,
		walk_end = 39,
		stand_start = 2,
		stand_end = 39,
		run_start = 2,
		run_end = 39
	},

	on_rightclick = function(self, clicker)

		if mobs:feed_tame(self, clicker, 8, true, true) then
			return
		end

		mobs:capture_mob(self, clicker, 0, 5, 50, false, nil)
	end
})


mobs:register_egg("dmobs:whale", "Whale", "default_water.png", 1)
