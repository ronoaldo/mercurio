mobs:register_arrow("dmobs:sting", {
	visual = "sprite",
	visual_size = {x = 0.5, y = 0.5},
	textures = {"dmobs_sting.png"},
	velocity = 8,
	tail = 0, -- enable tail
	tail_texture = "fire_basic_flame.png",

	hit_player = function(self, player)

		player:punch(self.object, 1.0, {
			full_punch_interval = 1.0,
			damage_groups = {fleshy = 1},
		}, nil)
	end,

	hit_mob = function(self, player)
	end,

	hit_node = function(self, pos, node)
		self.object:remove()
	end,
})
