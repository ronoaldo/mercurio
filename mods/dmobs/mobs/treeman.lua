-- Treeman

mobs:register_mob("dmobs:treeman", {
	type = "monster",
	reach = 3,
	damage = 2,
	attack_type = "dogfight",
	hp_min = 62,
	hp_max = 72,
	armor = 130,
	collisionbox = {-0.4, 0, -0.4, 0.4, 3, 0.4},
	visual = "mesh",
	mesh = "treeman.b3d",
	textures = {
		{"dmobs_treeman.png"},
		{"dmobs_treeman2.png"},
	},
	blood_texture = "default_tree.png",
	visual_size = {x=1, y=1},
	makes_footstep_sound = true,
	walk_velocity = 1,
	run_velocity = 2.5,
	jump = true,
	drops = {
		{name = "default:tree", chance = 5, min = 3, max = 6},
	},
	water_damage = 0,
	lava_damage = 4,
	fire_damage = 3,
	light_damage = 0,
	fall_damage = 1,
	fear_height = 10,
	view_range = 14,
	animation = {
		speed_normal = 10,
		speed_run = 13,
		walk_start = 46,
		walk_end = 66,
		stand_start = 1,
		stand_end = 20,
		run_start = 46,
		run_end = 66,
		punch_start = 20,
		punch_end = 45,
	},
})


mobs:register_egg("dmobs:treeman", "Treeman", "default_tree.png", 1)
