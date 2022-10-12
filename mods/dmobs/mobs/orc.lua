
-- Orc

mobs:register_mob("dmobs:orc", {
	type = "monster",
	passive = false,
	reach = 1,
	damage = 2,
	attack_type = "dogfight",
	hp_min = 12,
	hp_max = 22,
	armor = 130,
	collisionbox = {-0.4, -1.3, -0.4, 0.4, 1, 0.4},
	visual = "mesh",
	mesh = "orc.b3d",
	textures = {
		{"dmobs_orc.png"},
	},
	blood_texture = "mobs_blood.png",
	visual_size = {x=3, y=3},
	makes_footstep_sound = true,
	drops = {
		{name = "mobs:meat_raw", chance = 1, min = 1, max = 1},
	},
	walk_velocity = 1,
	run_velocity = 2,
	jump = true,
	water_damage = 0,
	lava_damage = 2,
	fire_damage = 2,
	light_damage = 0,
	fall_damage = 1,
	fall_speed = -13,
	fear_height = 4,
	view_range = 14,
	animation = {
		speed_normal = 10,
		speed_run = 20,
		walk_start = 2,
		walk_end = 18,
		stand_start = 30,
		stand_end = 40,
		run_start = 2,
		run_end = 18,
		punch_start = 20,
		punch_end = 30,
	},
})


-- Orc (Redesign)
mobs:register_mob("dmobs:orc2", {
	type = "monster",
	passive = false,
	reach = 1,
	damage = 2,
	attack_type = "dogfight",
	hp_min = 12,
	hp_max = 22,
	armor = 130,
	collisionbox = {-0.4, -0, -0.4, 0.4, 2, 0.4},
	visual = "mesh",
	mesh = "orc_redesign.b3d",
	textures = {
		{"dmobs_orc_redesign.png"},
	},
	blood_texture = "mobs_blood.png",
	visual_size = {x=1.5, y=1.5},
	makes_footstep_sound = true,
	drops = {
		{name = "mobs:meat_raw", chance = 1, min = 1, max = 1},
	},
	walk_velocity = 1,
	run_velocity = 2,
	jump = true,
	water_damage = 0,
	lava_damage = 2,
	light_damage = 0,
	fall_damage = 1,
	fall_speed = -13,
	fear_height = 4,
	view_range = 14,
	animation = {
		speed_normal = 12,
		speed_run = 20,
		walk_start = 20,
		walk_end = 40,
		stand_start = 60,
		stand_end = 80,
		run_start = 20,
		run_end = 40,
		punch_start = 1,
		punch_end = 15,
	},
})


mobs:register_egg("dmobs:orc", "Orc", "default_desert_sand.png", 1)
-- new and improved, hey
mobs:register_egg("dmobs:orc2", "Morgul Orc", "default_desert_sand.png", 1)
