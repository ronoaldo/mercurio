local S = minetest.get_translator("people")

-- Load support for intllib.
local MP = minetest.get_modpath(minetest.get_current_modname())
local S = minetest.get_translator and minetest.get_translator("people") or
		dofile(MP .. "/intllib.lua")

-- 0.4.17 or 5.0 check
local y_off = 20
if minetest.features.object_independent_selectionbox then
	y_off = 10
end

-- horse shoes (speed, jump, break, overlay texture)
local shoes = {
	["people:horseshoe_steel"] = {7, 4, 2, "people_horseshoe_steelo.png"},
	["people:horseshoe_bronze"] = {7, 4, 4, "people_horseshoe_bronzeo.png"},
	["people:horseshoe_mese"] = {9, 5, 8, "people_horseshoe_meseo.png"},
	["people:horseshoe_diamond"] = {10, 6, 6, "people_horseshoe_diamondo.png"}
}

-- rideable horse
mobs:register_mob("people:rideox", {
	type = "animal",
	visual = "mesh",
	visual_size = {x = 1, y = 1},
	mesh = "Rideox.b3d",
	collisionbox = {-0.4, -0.01, -0.4, 0.4, 1.25, 0.4},
	animation = {
		speed_normal = 50,
		run_speed = 100,
		stand_start = 0,
		stand_end = 100,
		walk_speed = 75,
		walk_start = 100,
		walk_end = 200,
		run_start = 100,
		run_end = 200,
		die_start = 200,
		die_end = 300,
		die_speed = 50,
		die_loop = false,
		die_rotate = true,
	},
	textures = {
		{"texturerideox.png"}, 

	},
	fear_height = 3,
	runaway = true,
	fly = false,
	walk_chance = 60,
        walk_velocity = 1.5,
	view_range = 10,
        knock_back = false,
        stay_near = {{"people:feeder", "marinara:reed_bundle", "naturalbiomes:reed_bundle", "farming:straw"}, 5},
	follow = {
		"farming:wheat", "default:apple", "farming:oat",
		"farming:barley", "farming:corn", "ethereal:banana_single", "farming:corn_cob", "farming:cabbage", "default:dry_grass_1", "default:dry_grass_2", "default:dry_grass_3", "default:grass_1", "default:grass_2", "default:grass_3", "default:grass_4", "default:grass_5", "default:marram_grass_1", "default:marram_grass_2", "default:marram_grass_3", "default:coldsteppe_grass_1", "default:coldsteppe_grass_2", "default:coldsteppe_grass_3", "default:coldsteppe_grass_4", "default:coldsteppe_grass_5", "default:coldsteppe_grass_6", "naturalbiomes:savanna_grass1", "naturalbiomes:savanna_grass2", "naturalbiomes:savanna_grass3", "naturalbiomes:outback_grass1", "naturalbiomes:outback_grass2", "naturalbiomes:outback_grass3", "naturalbiomes:outback_grass4", "naturalbiomes:outback_grass5", "naturalbiomes:outback_grass6", "naturalbiomes:med_grass1", "naturalbiomes:med_grass2", "naturalbiomes:heath_grass1", "naturalbiomes:heath_grass2", "naturalbiomes:heath_grass3", "naturalbiomes:alpine_grass1", "naturalbiomes:alpine_grass2", "naturalbiomes:heath_grass2", "naturalbiomes:heath_grass3", "naturalbiomes:", "naturalbiomes:", "naturalbiomes:bushland_grass", "naturalbiomes:bushland_grass2", "naturalbiomes:bushland_grass3", "naturalbiomes:bushland_grass4", "naturalbiomes:bushland_grass5", "naturalbiomes:bushland_grass6", "naturalbiomes:bushland_grass7", "group:grass", "group:normal_grass"},
	passive = true,
	hp_min = 100,
	hp_max = 250,
	armor = 100,
	lava_damage = 5,
	fall_damage = 5,
	water_damage = 1,
	makes_footstep_sound = true,
	sounds = {
		random = "people_ox3",
		damage = "people_ox",
		death = "people_ox2",
		distance = 15,
},
	drops = {
		{name = "mobs:leather", chance = 1, min = 0, max = 2}
	},

	do_custom = function(self, dtime)

		-- set needed values if not already present
		if not self.v2 then
			self.v2 = 0
			self.max_speed_forward = 4
			self.max_speed_reverse = 1
			self.accel = 6
			self.terrain_type = 3
			self.driver_attach_at = {x = 0, y = 9, z = -13}
			self.driver_eye_offset = {x = 0, y = 9, z = -10}
		end

		-- if driver present allow control of horse
		if self.driver then

			mobs.drive(self, "walk", "stand", false, dtime)

			return false -- skip rest of mob functions
		end

		return true
	end,

	on_die = function(self, pos)

		-- drop saddle when horse is killed while riding
		-- also detach from horse properly
		if self.driver then

			minetest.add_item(pos, "mobs:saddle")

			mobs.detach(self.driver, {x = 1, y = 0, z = 1})

			self.saddle = nil
		end

		-- drop any horseshoes added
		if self.shoed then
			minetest.add_item(pos, self.shoed)
		end

	end,

	do_punch = function(self, hitter)

		-- don't cut the branch you're... ah, that's not about that
		if hitter ~= self.driver then
			return true
		end
	end,

	on_rightclick = function(self, clicker)

		-- make sure player is clicking
		if not clicker or not clicker:is_player() then
			return
		end

		-- feed, tame or heal horse
		if mobs:feed_tame(self, clicker, 10, true, true) then
			return
		end

		-- applying protection rune
		if mobs:protect(self, clicker) then
			return
		end

		local player_name = clicker:get_player_name()

		-- make sure tamed horse is being clicked by owner only
		if self.tamed and self.owner == player_name then

			local inv = clicker:get_inventory()
			local tool = clicker:get_wielded_item()
			local item = tool:get_name()

			-- detatch player already riding horse
			if self.driver and clicker == self.driver then

				mobs.detach(clicker, {x = 1, y = 0, z = 1})

				-- add saddle back to inventory
				if inv:room_for_item("main", "mobs:saddle") then
					inv:add_item("main", "mobs:saddle")
				else
					minetest.add_item(clicker:get_pos(), "mobs:saddle")
				end

				self.saddle = nil

			-- attach player to horse
			elseif (not self.driver and not self.child
			and clicker:get_wielded_item():get_name() == "mobs:saddle")
			or self.saddle then

				self.object:set_properties({stepheight = 1.1})
				mobs.attach(self, clicker)

				-- take saddle from inventory
				if not self.saddle then
					inv:remove_item("main", "mobs:saddle")
				end

				self.saddle = true
			end

			-- apply horseshoes
			if item:find("people:horseshoe") then

				-- drop any existing shoes
				if self.shoed then
					minetest.add_item(self.object:get_pos(), self.shoed)
				end

				local speed = shoes[item][1]
				local jump = shoes[item][2]
				local reverse = shoes[item][3]
				local overlay = shoes[item][4]

				self.max_speed_forward = speed
				self.jump_height = jump
				self.max_speed_reverse = reverse
				self.accel = speed
				self.shoed = item

				-- apply horseshoe overlay to current horse texture
				if overlay then
					self.texture_mods = "^" .. overlay
					self.object:set_texture_mod(self.texture_mods)
				end

				-- show horse speed and jump stats with shoes fitted
				minetest.chat_send_player(player_name,
						S("Horse shoes fitted -")
						.. S(" speed: ") .. speed
						.. S(" , jump height: ") .. jump
						.. S(" , stop speed: ") .. reverse)

				tool:take_item()

				clicker:set_wielded_item(tool)

				return
			end
		end

		-- used to capture horse with magic lasso
		if mobs:capture_mob(self, clicker, 25, 0, 25, false, nil) then return end
	end,
})


mobs:register_egg("people:rideox", S("Ridable Ox"), "arideox.png")

