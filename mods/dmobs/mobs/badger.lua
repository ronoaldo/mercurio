mobs:register_mob("dmobs:badger", {
	type = "animal",
	passive = false,
	reach = 1,
	damage = 2,
	attack_type = "dogfight",
	hp_min = 12,
	hp_max = 22,
	armor = 130,
	collisionbox = {-0.3, -0.15, -0.3, 0.3, 0.4, 0.3},
	visual = "mesh",
	mesh = "badger.b3d",
	textures = {
		{"dmobs_badger.png"},
	},
	blood_texture = "mobs_blood.png",
	visual_size = {x=2, y=2},
	makes_footstep_sound = true,
	walk_velocity = 0.7,
	run_velocity = 1,
	jump = true,
	drops = {
		{name = "mobs:meat_raw", chance = 1, min = 1, max = 1},
	},
	water_damage = 0,
	lava_damage = 2,
	fire_damage = 2,
	light_damage = 0,
	fall_damage = 1,
	fall_speed = -8,
	fear_height = 4,
	follow = {"mobs:meat_raw"},
	view_range = 14,
	animation = {
		speed_normal = 12,
		speed_run = 18,
		walk_start = 34,
		walk_end = 58,
		stand_start = 1,
		stand_end = 30,
		run_start = 34,
		run_end = 58,
		punch_start = 60,
		punch_end = 80,
	},
	on_rightclick = function(self, clicker)

		if mobs:feed_tame(self, clicker, 8, true, true) then
			return
		end

		mobs:capture_mob(self, clicker, 0, 5, 50, false, nil)
	end,
})


mobs:register_egg("dmobs:badger", "Badger", "default_obsidian.png", 1)
