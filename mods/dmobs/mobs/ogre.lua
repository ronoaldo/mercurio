-- Ogre

mobs:register_mob("dmobs:ogre", {
	type = "monster",
	passive = false,
	reach = 2,
	damage = 4,
	attack_type = "dogfight",
	hp_min = 22,
	hp_max = 32,
	armor = 130,
	collisionbox = {-0.6, -1.3, -0.6, 0.6, 1.5, 0.6},
	visual = "mesh",
	mesh = "ogre.b3d",
	textures = {
		{"dmobs_ogre.png"},
	},
	blood_texture = "mobs_blood.png",
	visual_size = {x=3.5, y=3.5},
	makes_footstep_sound = true,
	drops = {
		{name = "mobs:meat_raw", chance = 1, min = 1, max = 1},
	},
	walk_velocity = 1,
	run_velocity = 2,
	jump = true,
	rotate = 180,
	water_damage = 0,
	lava_damage = 2,
	fire_damage = 2,
	light_damage = 0,
	fall_damage = 1,
	fall_speed = -14,
	fear_height = 4,
	view_range = 14,
	animation = {
		speed_normal = 10,
		speed_run = 20,
		walk_start = 3,
		walk_end = 38,
		stand_start = 40,
		stand_end = 70,
		run_start = 3,
		run_end = 38,
		punch_start = 70,
		punch_end = 100,
	},
})


mobs:register_egg("dmobs:ogre", "Ogre", "default_desert_sand.png", 1)
