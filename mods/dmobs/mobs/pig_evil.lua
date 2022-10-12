local pigdef = {
	type = "monster",
	passive = true,
	reach = 3,
	damage = 2,
	attack_type = "dogfight",
	explosion_radius = 2,
	hp_min = 12,
	hp_max = 22,
	armor = 130,
	collisionbox = {-0.4, 0, -0.4, 0.4, 1, 0.4},
	visual = "mesh",
	mesh = "flying_pig.b3d",
	textures = {
		{"dmobs_flying_pig_mean.png"},
	},
	jump = true,
	fly = true,
	fall_speed = 0,
	stepheight = 1.5,
	blood_texture = "mobs_blood.png",
	visual_size = {x=1, y=1},
	makes_footstep_sound = true,
	runaway = false,
	walk_velocity = 2,
	run_velocity = 3,
	run_chance = 20,
	jump = true,
	drops = {
		{name = "mobs:meat_raw", chance = 2, min = 1, max = 1},
	},
	sounds = {
		random = "mobs_pig",
	},
	water_damage = 0,
	lava_damage = 2,
	fire_damage = 2,
	light_damage = 0,
	follow = {"default:apple"},
	view_range = 14,
	animation = {
		speed_normal = 10,
		speed_run = 15,
		walk_start = 1,
		walk_end = 20,
		stand_start = 1,
		stand_end = 20,
		run_start = 22,
		run_end = 28,
	},

	do_custom = function(self)

		if self.state == "attack" then
			self.fly = false
			self.fall_speed = -4
		end
	end,

	on_rightclick = function(self, clicker)

		if mobs:feed_tame(self, clicker, 8, true, true) then
			return
		end

		mobs:capture_mob(self, clicker, 0, 5, 50, false, nil)
	end,
}

if dmobs.destructive then
	pigdef.sounds.explode = "tnt_explode"
	pigdef.attack_type = "explode"
end

mobs:register_mob("dmobs:pig_evil", pigdef)

mobs:register_egg("dmobs:pig_evil", "Kamikaze Pig", "wool_pink.png", 1)
