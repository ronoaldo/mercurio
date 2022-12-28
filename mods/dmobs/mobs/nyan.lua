mobs:register_mob("dmobs:nyan", {
	type = "animal",
	passive = true,
	reach = 4,
	damage = 2,
	hp_min = 12,
	hp_max = 22,
	armor = 130,
	collisionbox = {-0.2, 0, -0.2, 0.2, 0.6, 0.2},
	visual = "mesh",
	mesh = "nyancat.b3d",
	textures = {
		{"dmobs_nyancat.png"}
	},
	jump = true,
	fly = true,
	fall_speed = 0,
	stepheight = 1.5,
	blood_texture = "mobs_blood.png",
	visual_size = {x = 1, y = 1},
	makes_footstep_sound = true,
	runaway = false,
	walk_velocity = 2,
	run_velocity = 3,
	run_chance = 20,
	jump = true,
	drops = {
		{name = "default:nyan_cat", chance = 2, min = 1, max = 1}
	},
	water_damage = 0,
	lava_damage = 2,
	light_damage = 0,
	follow = {"default:mese"},
	view_range = 14,
	animation = {
		speed_normal = 4,
		speed_run = 5,
		walk_start = 1,
		walk_end = 7,
		stand_start = 1,
		stand_end = 7,
		run_start = 1,
		run_end = 7
	},

	do_custom = function(self, dtime)

		self.rb_count = (self.rb_count or 0) + dtime

		if self.rb_count < .2 then
			return
		end

		self.rb_count = 0

		local apos = self.object:get_pos() ; if not apos then return end
		local vec = self.object:get_velocity()

		minetest.add_particlespawner({
			amount = 5,
			time = 0.3,
			minpos = {x = apos.x - 0.1, y = apos.y + 0.3, z = apos.z - 0.1},
			maxpos = {x = apos.x + 0.1, y = apos.y + 0.4, z = apos.z + 0.1},
			minvel = {x = -0, y = -0, z = -0},
			maxvel = {x = 0, y = 0, z = 0},
			minacc = {x = 0, y = 0, z = 0},
			maxacc = {x = -vec.x, y = 0, z = -vec.z},
			minexptime = 0.5,
			maxexptime = 1.5,
			minsize = 3,
			maxsize = 5,
			collisiondetection = false,
			texture = "dmobs_rainbow.png",
			glow = 10
		})
	end,

	on_rightclick = function(self, clicker)

		if mobs:feed_tame(self, clicker, 8, true, true) then
			return
		end

		mobs:capture_mob(self, clicker, 0, 5, 50, false, nil)
	end
})


mobs:register_egg("dmobs:nyan", "Nyan Cat", "wool_pink.png", 1)
