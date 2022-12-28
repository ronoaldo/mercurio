mobs:register_mob("dmobs:gnorm", {
	type = "npc",
	can_dig = true,
	passive = true,
	reach = 1,
	damage = 1,
	attack_type = "dogfight",
	hp_min = 32,
	hp_max = 42,
	armor = 130,
	collisionbox = {-0.4, -0.3, -0.4, 0.4, 0.8, 0.4},
	visual = "mesh",
	mesh = "gnorm.b3d",
	textures = {
		{"dmobs_gnorm.png"}
	},
	blood_texture = "mobs_blood.png",
	visual_size = {x = 1, y = 1},
	makes_footstep_sound = true,
	runaway = true,
	walk_velocity = 0.5,
	run_velocity = 4,
	jump = true,
	water_damage = 0,
	lava_damage = 2,
	fire_damage = 2,
	light_damage = 0,
	fall_damage = 1,
	fall_speed = -6,
	fear_height = 4,
	drops = {
		{name = "default:wood", chance = 1, min = 1, max = 1},
		{name = "default:apple", chance = 1, min = 0, max = 1}
	},
	replace_rate = 10,
	replace_what = {
		"default:apple", "default:stone", "default:stone_with_coal",
		"default:fence_wood"
	},
	replace_with = "air",
	follow = {"default:apple"},
	view_range = 14,
	animation = {
		speed_normal = 8,
		speed_run = 30,
		walk_start = 62,
		walk_end = 81,
		stand_start = 2,
		stand_end = 9,
		run_start = 62,
		run_end = 81,
		punch_start = 1,
		punch_end = 1
	},

	on_rightclick = function(self, clicker)

		if mobs:feed_tame(self, clicker, 8, true, true) then
			return
		end

		mobs:capture_mob(self, clicker, 0, 5, 50, false, nil)
	end
})


mobs:register_egg("dmobs:gnorm", "Gnorm", "default_dirt.png", 1)
