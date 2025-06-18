
--butterflies

if core.settings:get_bool("mobs_spawn") ~= false then

	core.register_abm({
		nodenames = {"group:flower"},
		interval = 20,
		chance = 20,
		catch_up = false,
		action = function(pos, node, active_object_count, active_object_count_wider)

			local tod = (core.get_timeofday() or 0) * 24000
			if tod < 5000 or tod > 18500 then return end

			core.add_entity({x = pos.x, y = pos.y + 0.3, z = pos.z}, "dmobs:butterfly")
		end
	})
end

local math_random, math_sin, math_cos, math_pi = math.random, math.sin, math.cos, math.pi

core.register_entity("dmobs:butterfly", {

	initial_properties = {
		visual = "mesh",
		mesh = "butterfly.b3d",
		physical = true, static_save = false, pointable = false,
		collide_with_objects = false,
		textures = {"dmobs_butterfly.png"},
		visual_size = {x = 0.3, y = 0.3},
		collisionbox = {-0.3,-0.3,-0.3,0.3,0.3,0.3}
	},

	on_activate = function(self)

		local num = math_random(4)

		self.object:set_properties({textures = {"dmobs_butterfly" .. num .. ".png"}})
		self.object:set_animation({x = 1, y = 10}, 20, 0)
		self.object:set_yaw(math_pi + num)
	end,

	on_step = function(self, dtime)

		-- remove after 10 seconds
		self.end_timer = (self.end_timer or 0) + dtime

		if self.end_timer > 10 then
			self.object:remove() ; return
		end

		local pos = self.object:get_pos()
		local vec = self.object:get_velocity()
		local num = math_random(-math_pi, math_pi)

		self.object:set_yaw(math_pi + num)

		self.object:set_velocity({
			x = -math_sin(12 * pos.y), y = math_cos(12 * pos.x), z = -math_sin(12 * pos.y)
		})

		self.object:set_acceleration({
			x = -math_sin(6 * vec.y), y = math_cos(6 * vec.x), z = -math_sin(6 * vec.y)
		})
	end
})
