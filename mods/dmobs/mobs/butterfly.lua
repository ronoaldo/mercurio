
--butterflies

minetest.register_abm({
	nodenames = {
		"flowers:flower_rose", "flowers:flower_tulip",
		"flowers:flower_dandelion_yellow", "flowers:flower_viola",
		"flowers:flower_dandelion_white", "flowers:flower_geranium"
	},
	interval = 10,
	chance = 10,
	action = function(pos, node, active_object_count, active_object_count_wider)
		minetest.add_entity({x = pos.x, y = pos.y + 0.3, z = pos.z}, "dmobs:butterfly")
	end
})


minetest.register_entity("dmobs:butterfly", {
	visual = "mesh",
	mesh = "butterfly.b3d",
	physical = true,
	textures = {"dmobs_butterfly.png"},
	visual_size = {x = 0.3, y = 0.3},
	collisionbox = {0,0,0,0,0.1,0},
	on_activate = function(self)

		local num = math.random(4)

		self.object:set_properties({textures = {"dmobs_butterfly" .. num .. ".png"}})
		self.object:set_animation({x = 1, y = 10}, 20, 0)
		self.object:set_yaw(math.pi + num)

		minetest.after(10, function()
			self.object:remove()
		end)
	end,

	on_step = function(self)

		local pos = self.object:get_pos()
		local vec = self.object:get_velocity()
		local num = math.random(-math.pi, math.pi)

		self.object:set_yaw(math.pi+num)

		self.object:set_velocity({
			x = -math.sin(12 * pos.y),
			y = math.cos(12 * pos.x),
			z = -math.sin(12 * pos.y)
		})

		self.object:set_acceleration({
			x = -math.sin(6 * vec.y),
			y = math.cos(6 * vec.x),
			z = -math.sin(6 * vec.y)
		})
	end
})
