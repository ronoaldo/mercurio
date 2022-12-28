mobs:register_mob("dmobs:rat", {
	type = "monster",
	reach = 2,
	damage = 2,
	attack_type = "dogfight",
	hp_min = 22,
	hp_max = 42,
	armor = 130,
	collisionbox = {-0.4, 0, -0.4, 0.3, 1, 0.3},
	runaway = true,
	visual = "mesh",
	mesh = "dmobs_rat.b3d",
	textures = {
		{"dmobs_rat.png"}
	},
	blood_texture = "mobs_blood.png",
	visual_size = {x = 1, y = 1},
	makes_footstep_sound = true,
	walk_velocity = 1,
	run_velocity = 2.5,
	jump = true,
	drops = {
		{name = "mobs:meat_raw", chance = 1, min = 1, max = 1}
	},
	water_damage = 0,
	lava_damage = 2,
	fire_damage = 2,
	light_damage = 0,
	fall_damage = 1,
	fear_height = 5,
	replace_rate = 10,
	replace_what = {
		"farming:wheat_5", "farming:wheat_4", "farming:wheat_2", "farming:wheat_3"
	},
	replace_with = "air",
	follow = {"group:food_cheese"},
	view_range = 14,
	animation = {
		speed_normal = 10,
		speed_run = 18,
		walk_start = 43,
		walk_end = 63,
		stand_start = 1,
		stand_end = 20,
		run_start = 43,
		run_end = 63,
		punch_start = 20,
		punch_end = 40
	}
})


mobs:register_egg("dmobs:rat", "Giant Rat", "wool_grey.png", 1)
