mobs:register_mob("dmobs:owl", {
	type = "animal",
	passive = true,
	hp_min = 12,
	hp_max = 22,
	armor = 130,
	collisionbox = {-0.3, -0.5, -0.3, 0.2, 0.2, 0.2},
	visual = "mesh",
	mesh = "owl.b3d",
	textures = {
		{"dmobs_owl.png"}
	},
	blood_texture = "mobs_blood.png",
	visual_size = {x = 2, y = 2},
	makes_footstep_sound = false,
	walk_velocity = 0,
	run_velocity = 0,
	jump = false,
	drops = {
		{name = "default:dry_grass_1", chance = 1, min = 1, max = 1}
	},
	water_damage = 2,
	lava_damage = 2,
	fire_damage = 2,
	light_damage = 0,
	view_range = 1,
	animation = {
		speed_normal = 1,
		walk_start = 1,
		walk_end = 50
	},

	do_custom = function(self, dtime)

		self.tod_count = (self.tod_count or 0) + dtime

		if self.tod_count < 5 then
			return
		end

		self.tod_count = 0

		local daytime = minetest.get_timeofday() * 24000

		if daytime <= 6000 then

			self.object:set_properties({
				textures = {"dmobs_owl_awake.png"},
				mesh = "owl.b3d"
			})

		elseif daytime >= 6000 then

			self.object:set_properties({
				textures = {"dmobs_owl.png"},
				mesh = "owl.b3d"
			})
		end
	end
})


mobs:register_egg("dmobs:owl", "Owl", "default_tree.png", 1)
