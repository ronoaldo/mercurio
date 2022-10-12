mobs:register_mob("nativevillages:icedog", {
	stepheight = 1,
	type = "animal",
	passive = false,
	attack_type = "dogfight",
	group_attack = true,
	owner_loyal = true,
	attack_npcs = false,
	reach = 2,
	damage = 6,
	hp_min = 35,
	hp_max = 55,
	armor = 100,
	collisionbox = {-0.5, -0.01, -0.5, 0.5, 0.95, 0.5},
	visual = "mesh",
	mesh = "Icedog.b3d",
	textures = {
		{"textureicedog.png"},
		{"textureicedog2.png"},
		{"textureicedog3.png"},
	},
	makes_footstep_sound = true,
	sounds = {
		random = "nativevillages_dog2",
		attack = "nativevillages_dog",
		damage = "nativevillages_dog4",
		death = "nativevillages_dog5",
	},
	walk_velocity = 1,
	run_velocity = 3,
	jump = true,
	jump_height = 3,
	pushable = true,
        follow = {"mobs:meat_raw", "people:dogfood", "people:dogfood_cooked"},
	view_range = 6,
	drops = {
	},
	water_damage = 2,
	lava_damage = 5,
	light_damage = 0,
	fear_height = 2,
	animation = {
		speed_normal = 80,
		stand_speed = 50,
		stand_start = 0,
		stand_end = 100,
		stand2_start = 100,
		stand2_end = 200,
		walk_start = 200,
		walk_end = 300,
		punch_start = 300,
		punch_end = 400,

		die_start = 1, -- we dont have a specific death animation so we will
		die_end = 2, --   re-use 2 standing frames at a speed of 1 fps and
		die_speed = 1, -- have mob rotate when dying.
		die_loop = false,
		die_rotate = true,
	},
	on_rightclick = function(self, clicker)

		if mobs:feed_tame(self, clicker, 8, true, true) then return end
		if mobs:protect(self, clicker) then return end
		if mobs:capture_mob(self, clicker, 0, 5, 50, false, nil) then return end
	end,
})


if not mobs.custom_spawn_nativevillages then
mobs:spawn({
	name = "nativevillages:icedog",
	nodes = {"default:snowblock"},
	neighbors = {"nativevillages:sledge"},
	min_light = 14,
	interval = 60,
	chance = 8000, -- 15000
	active_object_count = 3,
	min_height = 1,
	max_height = 80,
})
end

mobs:register_egg("nativevillages:icedog", ("Ice Dog"), "aicedog.png")


mobs:alias_mob("nativevillages:icedog", "nativevillages:icedog") -- compatibility

mobs.icesledgetrader_drops = {
	"nativevillages:sledgewithdog", "nativevillages:icedog"
}

mobs:register_mob("nativevillages:icesledgetrader", {
	type = "npc",
	passive = false,
	damage = 3,
	attack_type = "dogfight",
	attacks_monsters = true,
	attack_npcs = false,
	owner_loyal = true,
	pathfinding = true,
	hp_min = 40,
	hp_max = 80,
	armor = 100,
	collisionbox = {-0.35,-1.0,-0.35, 0.35,0.8,0.35},
	visual = "mesh",
	mesh = "Icesledgetrader.b3d",
	drawtype = "front",
	textures = {
		{"textureicesledgetrader.png"},

	},
	makes_footstep_sound = true,
sounds = {
		attack = "nativevillages_icevillagermale2",
		random = "nativevillages_icevillagermale",
		damage = "nativevillages_icevillagermale4",
		death = "nativevillages_icevillagermale3",
		distance = 10,
	},
	walk_velocity = 1,
        walk_chance = 15,
	run_velocity = 3,
	jump = true,
	drops = {
	},
	water_damage = 0,
	lava_damage = 2,
	light_damage = 0,
	follow = {},
        stay_near = "nativevillages:sledge",
	view_range = 15,
	owner = "",
	order = "follow",
	fear_height = 3,
	animation = {
		speed_normal = 50,
		stand_start = 0,
		stand_end = 100,
		walk_start = 100,
		walk_end = 200,
                punch_speed = 100,
		punch_start = 200,
		punch_end = 300,
	},

	on_rightclick = function(self, clicker)

		-- feed to heal npc
		if mobs:feed_tame(self, clicker, 8, true, true) then return end

		-- capture npc with net or lasso
		if mobs:capture_mob(self, clicker, nil, 5, 80, false, nil) then return end

		-- protect npc with mobs:protector
		if mobs:protect(self, clicker) then return end

		local item = clicker:get_wielded_item()
		local name = clicker:get_player_name()

		-- right clicking with gold lump drops random item from mobs.icesledgetrader_drops
		if item:get_name() == "default:steel_ingot" then

			if not mobs.is_creative(name) then
				item:take_item()
				clicker:set_wielded_item(item)
			end

			local pos = self.object:get_pos()

			pos.y = pos.y + 0.5

			local drops = self.npc_drops or mobs.icesledgetrader_drops

			minetest.add_item(pos, {
				name = drops[math.random(1, #drops)]
			})

			minetest.chat_send_player(name, ("Trader dropped you an item for steel!"))

			return
		end

		-- by right-clicking owner can switch npc between follow and stand
		if self.owner and self.owner == name then

			if self.order == "follow" then

				self.attack = nil
				self.order = "stand"
				self.state = "stand"
				self:set_animation("stand")
				self:set_velocity(0)

				minetest.chat_send_player(name, ("NPC stands still."))
			else
				self.order = "follow"

				minetest.chat_send_player(name, ("NPC will follow you."))
			end
		end
	end,
})

if not mobs.custom_spawn_nativevillages then
mobs:spawn({
	name = "nativevillages:icesledgetrader",
	nodes = {"default:snowblock"},
	neighbors = {"nativevillages:sledge"},
	min_light = 0,
	interval = 60,
	active_object_count = 1,
	chance = 1, -- 15000
	min_height = 0,
	max_height = 120,
})
end

mobs:register_egg("nativevillages:icesledgetrader", ("Sledge Trader"), "aicesledgetrader.png")

mobs.icevillagerfemale_drops = {
	"mobs:meat", "mobs:leather", "wool:brown", "wool:white"
}

mobs:register_mob("nativevillages:icevillagerfemale", {
	type = "npc",
	passive = false,
	damage = 1,
	attack_type = "dogfight",
	attacks_monsters = true,
	attack_npcs = false,
	owner_loyal = true,
	pathfinding = true,
	hp_min = 30,
	hp_max = 60,
	armor = 100,
	collisionbox = {-0.35,-1.0,-0.35, 0.35,0.8,0.35},
	visual = "mesh",
	mesh = "Icevillagerfemale.b3d",
	drawtype = "front",
	textures = {
		{"textureicevillagerfemale.png"},

	},
	child_texture = {
		{"textureicevillagerfemalebaby.png"}, 
	},
	makes_footstep_sound = true,
sounds = {
		attack = "nativevillages_icevillagerfemale2",
		random = "nativevillages_icevillagerfemale",
		damage = "nativevillages_icevillagerfemale4",
		death = "nativevillages_icevillagerfemale3",
		distance = 10,
	},
	walk_velocity = 1,
        walk_chance = 15,
	run_velocity = 3,
	jump = true,
	drops = {
	},
	water_damage = 0,
	lava_damage = 2,
	light_damage = 0,
	follow = {},
        stay_near = "nativevillages:blanket",
	view_range = 15,
	owner = "",
	order = "follow",
	fear_height = 3,
	animation = {
		speed_normal = 50,
		stand_start = 0,
		stand_end = 100,
		walk_start = 100,
		walk_end = 200,
                punch_speed = 100,
		punch_start = 200,
		punch_end = 300,
	},

	on_rightclick = function(self, clicker)

		-- feed to heal npc
		if mobs:feed_tame(self, clicker, 8, true, true) then return end

		-- capture npc with net or lasso
		if mobs:capture_mob(self, clicker, nil, 5, 80, false, nil) then return end

		-- protect npc with mobs:protector
		if mobs:protect(self, clicker) then return end

		local item = clicker:get_wielded_item()
		local name = clicker:get_player_name()

		-- right clicking with gold lump drops random item from mobs.icevillagerfemale_drops
		if item:get_name() == "default:iron_lump" then

			if not mobs.is_creative(name) then
				item:take_item()
				clicker:set_wielded_item(item)
			end

			local pos = self.object:get_pos()

			pos.y = pos.y + 0.5

			local drops = self.npc_drops or mobs.icevillagerfemale_drops

			minetest.add_item(pos, {
				name = drops[math.random(1, #drops)]
			})

			minetest.chat_send_player(name, ("Icelander dropped you an item for iron!"))

			return
		end

		-- by right-clicking owner can switch npc between follow and stand
		if self.owner and self.owner == name then

			if self.order == "follow" then

				self.attack = nil
				self.order = "stand"
				self.state = "stand"
				self:set_animation("stand")
				self:set_velocity(0)

				minetest.chat_send_player(name, ("Icelander stands still."))
			else
				self.order = "follow"

				minetest.chat_send_player(name, ("Icelander will follow you."))
			end
		end
	end,
})

if not mobs.custom_spawn_nativevillages then
mobs:spawn({
	name = "nativevillages:icevillagerfemale",
	nodes = {"default:snowblock", "wool:brown"},
	neighbors = {"nativevillages:blanket"},
	min_light = 0,
	interval = 60,
	active_object_count = 2,
	chance = 1, -- 15000
	min_height = 0,
	max_height = 120,
})
end

mobs:register_egg("nativevillages:icevillagerfemale", ("Female Icelander"), "aicevillagerfemale.png")

mobs.icevillagermale_drops = {
	"mobs:meat", "mobs:leather", "wool:brown", "wool:white"
}

mobs:register_mob("nativevillages:icevillagermale", {
	type = "npc",
	passive = false,
	damage = 3,
	attack_type = "dogfight",
	attacks_monsters = true,
	attack_npcs = false,
	owner_loyal = true,
	pathfinding = true,
	hp_min = 30,
	hp_max = 70,
	armor = 100,
	collisionbox = {-0.35,-1.0,-0.35, 0.35,0.8,0.35},
	visual = "mesh",
	mesh = "Icevillagermale.b3d",
	drawtype = "front",
	textures = {
		{"textureicevillagermale.png"},

	},
	child_texture = {
		{"textureicevillagermalebaby.png"}, 
	},
	makes_footstep_sound = true,
sounds = {
		attack = "nativevillages_icevillagermale2",
		random = "nativevillages_icevillagermale",
		damage = "nativevillages_icevillagermale4",
		death = "nativevillages_icevillagermale3",
		distance = 10,
	},
	walk_velocity = 1,
        walk_chance = 15,
	run_velocity = 3,
	jump = true,
	drops = {
	},
	water_damage = 0,
	lava_damage = 2,
	light_damage = 0,
	follow = {},
        stay_near = "nativevillages:blanket",
	view_range = 15,
	owner = "",
	order = "follow",
	fear_height = 3,
	animation = {
		speed_normal = 50,
		stand_start = 0,
		stand_end = 100,
		walk_start = 100,
		walk_end = 200,
                punch_speed = 100,
		punch_start = 200,
		punch_end = 300,
	},

	on_rightclick = function(self, clicker)

		-- feed to heal npc
		if mobs:feed_tame(self, clicker, 8, true, true) then return end

		-- capture npc with net or lasso
		if mobs:capture_mob(self, clicker, nil, 5, 80, false, nil) then return end

		-- protect npc with mobs:protector
		if mobs:protect(self, clicker) then return end

		local item = clicker:get_wielded_item()
		local name = clicker:get_player_name()

		-- right clicking with gold lump drops random item from mobs.icevillagermale_drops
		if item:get_name() == "default:iron_lump" then

			if not mobs.is_creative(name) then
				item:take_item()
				clicker:set_wielded_item(item)
			end

			local pos = self.object:get_pos()

			pos.y = pos.y + 0.5

			local drops = self.npc_drops or mobs.icevillagermale_drops

			minetest.add_item(pos, {
				name = drops[math.random(1, #drops)]
			})

			minetest.chat_send_player(name, ("Icelander dropped you an item for iron!"))

			return
		end

		-- by right-clicking owner can switch npc between follow and stand
		if self.owner and self.owner == name then

			if self.order == "follow" then

				self.attack = nil
				self.order = "stand"
				self.state = "stand"
				self:set_animation("stand")
				self:set_velocity(0)

				minetest.chat_send_player(name, ("Icelander stands still."))
			else
				self.order = "follow"

				minetest.chat_send_player(name, ("Icelander will follow you."))
			end
		end
	end,
})

if not mobs.custom_spawn_nativevillages then
mobs:spawn({
	name = "nativevillages:icevillagermale",
	nodes = {"default:snowblock", "wool:brown"},
	neighbors = {"nativevillages:blanket"},
	min_light = 0,
	interval = 60,
	active_object_count = 2,
	chance = 1, -- 15000
	min_height = 0,
	max_height = 120,
})
end

mobs:register_egg("nativevillages:icevillagermale", ("Male Icelander"), "aicevillagermale.png")


-- Load support for intllib.
local MP = minetest.get_modpath(minetest.get_current_modname())
local S = minetest.get_translator and minetest.get_translator("nativevillages") or
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

-- rideable sledge
mobs:register_mob("nativevillages:sledgewithdog", {
	type = "animal",
	visual = "mesh",
	visual_size = {x = 1, y = 1},
	mesh = "Sledgewithdog.b3d",
	collisionbox = {-0.4, -0.01, -0.4, 0.4, 1.25, 0.4},
	animation = {
		speed_normal = 50,
		run_speed = 125,
		stand_start = 0,
		stand_end = 100,
		stand2_start = 200,
		stand2_end = 300,
		walk_speed = 85,
		walk_start = 100,
		walk_end = 200,
		run_start = 100,
		run_end = 200,
	},
	textures = {
		{"texturesledgewithdog.png"}, 

	},
	fear_height = 3,
	runaway = true,
	fly = false,
	walk_chance = 0.1,
        walk_velocity = 1.5,
	view_range = 10,
	follow = {"mobs:meat_raw", "people:dogfood", "people:dogfood_cooked"},
	passive = true,
	hp_min = 100,
	hp_max = 250,
	armor = 100,
	lava_damage = 5,
	fall_damage = 5,
	water_damage = 1,
	makes_footstep_sound = true,
	sounds = {
		random = "nativevillages_dog2",
		attack = "nativevillages_dog",
		damage = "nativevillages_dog4",
		death = "nativevillages_dog5",
	},
	drops = {
		{name = "mobs:leather", chance = 1, min = 0, max = 2}
	},

	do_custom = function(self, dtime)

		-- set needed values if not already present
		if not self.v2 then
			self.v2 = 0
			self.max_speed_forward = 7
			self.max_speed_reverse = 2
			self.accel = 6
			self.terrain_type = 3
			self.driver_attach_at = {x = 0, y = 6, z = -17}
			self.driver_eye_offset = {x = 0, y = 5, z = -14}
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
		mobs:capture_mob(self, clicker, 0, 0, 80, false, nil)
	end,
})


mobs:register_egg("nativevillages:sledgewithdog", S("Sledge with Dog"), "asledwithdog.png")

