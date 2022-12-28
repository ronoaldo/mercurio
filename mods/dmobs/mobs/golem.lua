-- stone golem

mobs:register_mob("dmobs:golem", {
	type = "monster",
	reach = 3,
	damage = 2,
	attack_type = "dogfight",
	hp_min = 62,
	hp_max = 72,
	armor = 100,
	collisionbox = {-0.4, 0, -0.4, 0.4, 2.5, 0.4},
	visual = "mesh",
	mesh = "golem.b3d",
	textures = {
		{"dmobs_golem.png"}
	},
	blood_texture = "default_stone.png",
	visual_size = {x = 1, y = 1},
	makes_footstep_sound = true,
	walk_velocity = 1,
	run_velocity = 2.5,
	jump = true,
	drops = {
		{name = "default:stone", chance = 1, min = 1, max = 5},
		{name = "dmobs:golemstone", chance = 30, min = 1, max = 1}
	},
	water_damage = 0,
	lava_damage = 2,
	fire_damage = 2,
	light_damage = 1,
	fall_damage = 0,
	fear_height = 10,
	view_range = 14,
	animation = {
		speed_normal = 10,
		speed_run = 14,
		walk_start = 46,
		walk_end = 66,
		stand_start = 1,
		stand_end = 20,
		run_start = 46,
		run_end = 66,
		punch_start = 20,
		punch_end = 45
	}
})


mobs:register_egg("dmobs:golem", "Stone Golem", "default_stone.png", 1)
