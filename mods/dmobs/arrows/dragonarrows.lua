local base_arrow = {
	visual = "sprite",
	visual_size = {x = 0.5, y = 0.5},
	velocity = 8,
	textures = {},
	tail = 1, -- enable tail
	tail_texture = "dmobs_ice.png",

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
		self.object:remove()
	end,
}

for _,arrowtype in pairs({"ice","lightning","poison"}) do

	base_arrow.textures = {"dmobs_" .. arrowtype .. ".png"}

	mobs:register_arrow("dmobs:" .. arrowtype, dmobs.deepclone(base_arrow))
end
