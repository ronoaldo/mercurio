-- Lightning dragon

local dragondef = {
	type = "monster",
	passive = false,
	attacks_monsters = true,
	damage = 4,
	reach = 3,
	attack_type = "dogshoot",
	shoot_interval = 2.5,
	dogshoot_switch = 2,
	dogshoot_count = 0,
	dogshoot_count_max = 5,
	arrow = "dmobs:lightning",
	shoot_offset = 1,
	hp_min = 70,
	hp_max = 100,
	armor = 100,
	collisionbox = {-0.6, -1.2, -0.6, 0.6, 0.6, 0.6},
	visual = "mesh",
	mesh = "dragon.b3d",
	textures = {
		{"dmobs_dragon2.png"},
	},
	blood_texture = "mobs_blood.png",
	visual_size = {x = 2, y = 2},
	makes_footstep_sound = true,
	runaway = false,
	jump_chance = 30,
	walk_chance = 80,
	fall_speed = 0,
	follow = {"dmobs:dragon_gem"},
	pathfinding = true,
	fall_damage = 0,
	sounds = {
		shoot_attack = "dmobs_thunder",
	},
	walk_velocity = 3,
	run_velocity = 5,
	jump = true,
	fly = true,
	fly_in = {"air","default:water_source","default:water_flowing"},
	drops = {
		{name = "dmobs:egg", chance = 1, min = 1, max = 1},
		{name = "dmobs:dragon_gem", chance = 1, min = 1, max = 1},
	},
	fall_speed = 0,
	stepheight = 10,
	water_damage = 2,
	lava_damage = 0,
	fire_damage = 0,
	light_damage = 0,
	view_range = 20,
	animation = {
		speed_normal = 10,
		speed_run = 20,
		walk_start = 1,
		walk_end = 22,
		stand_start = 1,
		stand_end = 22,
		run_start = 1,
		run_end = 22,
		punch_start = 22,
		punch_end = 47,
	},
	knock_back = 2,
	do_custom = dmobs.dragon.step_custom,
	on_rightclick = dmobs.dragon.on_rc
}


mobs:register_mob("dmobs:dragon2", dmobs.deepclone(dragondef))

dragondef.type = "npc"
dragondef.attacks_monsters = true
dragondef.on_rightclick = dmobs.dragon.ride
dragondef.do_custom = dmobs.dragon.do_custom

mobs:register_mob("dmobs:dragon_black", dmobs.deepclone(dragondef))
