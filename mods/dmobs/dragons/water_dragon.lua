-- Waterdragon (Hydra)

mobs:register_mob("dmobs:waterdragon", {
	type = "monster",
	passive = false,
	attack_type = "dogshoot",
	dogshoot_switch = 2,
	dogshoot_count = 0,
	dogshoot_count_max =5,
	shoot_interval = 2.5,
	arrow = "dmobs:ice",
	shoot_offset = 0,
	pathfinding = false,
	reach = 5,
	damage = 2,
	hp_min = 100,
	hp_max = 127,
	armor = 100,
	collisionbox = {-0.4, -0.5, -0.4, 0.4, 5, 0.4},
	visual_size = {x = 4, y = 4},
	visual = "mesh",
	mesh = "water_dragon.b3d",
	textures = {
		{"dmobs_waterdragon.png"},
	},
	blood_texture = "mobs_blood.png",
	makes_footstep_sound = true,
	sounds = {
		random = "mobs_dirtmonster",
		shoot_attack = "dmobs_wave"
	},
	view_range = 15,
	rotate = 180,
	walk_velocity = 0.01,
	run_velocity = 0.01,
	jump = false,
	drops = {
		{name = "dmobs:dragon_gem_ice", chance = 1, min = 1, max = 1},
		{name = "dmobs:dragon_gem_fire", chance = 1, min = 1, max = 1},
	},
	water_damage = 0,
	lava_damage = 5,
	fire_damage = 4,
	light_damage = 0,
	floats = 0,
	animation = {
		speed_normal = 15,
		speed_run = 15,
		stand_start = 1,
		stand_end = 20,
		walk_start = 1,
		walk_end = 20,
		run_start = 1,
		run_end = 20,
		punch_start = 40,
		punch_end = 60,
		shoot_start = 20,
		shoot_end = 40,
	},
	do_custom = function(self)

		--follow thanks to TenPlus1 and Byakuren
		if not self.hydra then

			self.hydra = true -- flip switch so this part is done only once

			-- get head position and define a few temp variables
			local pos = self.object:get_pos()
			local obj, obj2, ent

			-- add body and make it follow head
			obj = minetest.add_entity(
					{x=pos.x+1, y=pos.y, z=pos.z}, "dmobs:waterdragon_2")

			ent = obj:get_luaentity()
			ent.following = self.object

			-- add body and make it follow previous body segment
			obj2 = minetest.add_entity(
					{x=pos.x-1, y=pos.y, z=pos.z}, "dmobs:waterdragon_2")

			ent = obj2:get_luaentity()
			ent.following = self.object
		end
	end,
})


mobs:register_mob("dmobs:waterdragon_2", {
	type = "monster",
	passive = false,
	attack_type = "shoot",
	dogshoot_switch = 2,
	dogshoot_count = 0,
	dogshoot_count_max =5,
	shoot_interval = 3,
	arrow = "dmobs:ice",
	shoot_offset = 0,
	pathfinding = false,
	reach = 5,
	damage = 2,
	hp_min = 50,
	hp_max = 60,
	armor = 50,
	collisionbox = {-0.4, -0.2, -0.4, 0.4, 5, 0.4},
	visual_size = {x=3, y=3},
	visual = "mesh",
	mesh = "water_dragon.b3d",
	textures = {
		{"dmobs_waterdragon.png"},
	},
	blood_texture = "mobs_blood.png",
	makes_footstep_sound = true,
	sounds = {
		shoot_attack = "dmobs_wave",
		random = "velociraptor",
	},
	view_range = 15,
	rotate = 180,
	floats = 0,
	walk_velocity = 0.01,
	run_velocity = 0.01,
	jump = false,
	water_damage = 0,
	lava_damage = 5,
	light_damage = 0,
	animation = {
		speed_normal = 15,
		speed_run = 15,
		stand_start = 1,
		stand_end = 20,
		walk_start = 1,
		walk_end = 20,
		run_start = 1,
		run_end = 20,
		punch_start = 40,
		punch_end = 60,
		shoot_start = 20,
		shoot_end = 40,
	},
})
