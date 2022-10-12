mobs:register_arrow("dmobs:fire", {
	visual = "sprite",
	visual_size = {x = 0.5, y = 0.5},
	textures = {"dmobs_fire.png"},
	velocity = 8,
	tail = 1, -- enable tail
	tail_texture = "fire_basic_flame.png",

	hit_player = function(self, player)

		player:punch(self.object, 1.0, {
			full_punch_interval = 1.0,
			damage_groups = {fleshy = 8},
		}, nil)
	end,

	hit_mob = function(self, player)

		player:punch(self.object, 1.0, {
			full_punch_interval = 1.0,
			damage_groups = {fleshy = 8},
		}, nil)
	end,

	hit_node = function(self, pos, node)
		mobs:explosion(pos, 2, 1, 1)
	end,
})
