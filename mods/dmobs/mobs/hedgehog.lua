mobs:register_mob("dmobs:hedgehog", {
	type = "animal",
	passive = true,
	hp_min = 12,
	hp_max = 22,
	armor = 130,
	collisionbox = {-0.1, -0.1, -0.2, 0.2, 0.2, 0.2},
	visual = "mesh",
	mesh = "hedgehog.b3d",
	textures = {
		{"dmobs_hedgehog.png"}
	},
	blood_texture = "mobs_blood.png",
	visual_size = {x = 2, y = 2},
	makes_footstep_sound = true,
	walk_velocity = 0.5,
	run_velocity = 1,
	jump = true,
	jump_height = 0.6,
	water_damage = 2,
	lava_damage = 2,
	fire_damage = 2,
	light_damage = 0,
	fall_damage = 1,
	fall_speed = -6,
	fear_height = 4,
	view_range = 14,
	follow = {"farming:bread"},
	drops = {
		{name = "default:grass_1", chance = 1, min = 1, max = 3}
	},
	animation = {
		speed_normal = 5,
		speed_run = 10,
		walk_start = 1,
		walk_end = 10,
		stand_start = 1,
		stand_end = 10,
		run_start = 1,
		run_end = 10
	},

	on_rightclick = function(self, clicker)

		if mobs:feed_tame(self, clicker, 8, true, true) then
			return
		end

		mobs:capture_mob(self, clicker, 0, 5, 50, false, nil)
	end
})


mobs:register_egg("dmobs:hedgehog", "Hedgehog", "wool_brown.png", 1)
