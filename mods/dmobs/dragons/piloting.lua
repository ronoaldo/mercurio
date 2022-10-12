
if not dmobs.dragon then
	dmobs.dragon = {}
end

dmobs.dragon.step_custom = function(self, dtime)

	if self.driver then

		object_fly(self, dtime, 10, true, "dmobs:fire_plyr", "walk", "stand")

		if self.state == "attack" then
			self.state = nil
		end

		return false
	end

	return true
end


dmobs.dragon.ride = function(self, clicker)

	if self.tamed and self.owner == clicker:get_player_name() then

		local inv = clicker:get_inventory()

		if self.driver and clicker == self.driver then

			object_detach(self, clicker, {x=1, y=0, z=1})

			if inv:room_for_item("main", "mobs:saddle") then
				inv:add_item("main", "mobs:saddle")
			else
				minetest.add_item(clicker:get_pos(), "mobs:saddle")
			end

		elseif not self.driver then

			if clicker:get_wielded_item():get_name() == "mobs:saddle" then

				object_attach(self, clicker, {x=0, y=12, z=4}, {x=0, y=0, z=4})

				inv:remove_item("main", "mobs:saddle")
			end
		end
	end
end


dmobs.dragon.on_rc = function(self, clicker)

	if not clicker or not clicker:is_player() then
		return
	end

	if mobs:feed_tame(self, clicker, 1, false, false) then
		return
	end

	dmobs.dragon.ride(self, clicker)
end


dmobs.dragon.do_custom = function(self, dtime)

	if self.driver then

		object_fly(self, dtime, 10, true, "dmobs:fire_plyr", "walk", "stand")

		if self.state == "attack" then
			self.state = "idle"
		end

		return false
	end

	return true
end
