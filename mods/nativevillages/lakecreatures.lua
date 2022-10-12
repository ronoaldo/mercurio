mobs:register_mob("nativevillages:lakecatfish", {
stepheight = 0.0,
	type = "animal",
	passive = true,
        attack_type = "dogfight",
	attack_animals = false,
	reach = 1,
        damage = 1,
	hp_min = 15,
	hp_max = 55,
	armor = 100,
	collisionbox = {-0.4, -0.01, -0.4, 0.4, 0.5, 0.4},
	visual = "mesh",
	mesh = "Lakecatfish.b3d",
	visual_size = {x = 1.0, y = 1.0},
	textures = {
		{"texturelakecatfish.png"},
	},
	sounds = {},
	makes_footstep_sound = false,
	walk_velocity = 1,
	run_velocity = 2,
	fly = true,
	fly_in = "default:water_source", "default:river_water_source", "default:water_flowing", "default:river_water_flowing",
	fall_speed = 0,
	runaway = true,
        runaway_from = {"animalworld:bear", "animalworld:crocodile", "animalworld:tiger", "animalworld:spider", "animalworld:spidermale", "animalworld:shark", "animalworld:hyena", "animalworld:kobra", "animalworld:monitor", "animalworld:snowleopard", "animalworld:volverine", "livingfloatlands:deinotherium", "livingfloatlands:carnotaurus", "livingfloatlands:lycaenops", "livingfloatlands:smilodon", "livingfloatlands:tyrannosaurus", "livingfloatlands:velociraptor", "animalworld:divingbeetle", "animalworld:divingbeetle", "animalworld:scorpion", "player"},
	jump = false,
	stepheight = 0.0,
	drops = {
	},
	water_damage = 0,
        air_damage = 1,
	lava_damage = 4,
	light_damage = 0,
	fear_height = 2,
	animation = {
		speed_normal = 50,
		stand_start = 200,
		stand_end = 300,
		fly_start = 0, 
		fly_end = 100,
		fly2_start = 100, 
		fly2_end = 200,
	},
	fly_in = {"default:water_source", "default:river_water_source", "default:water_flowing", "default:river_water_flowing"},
	floats = 0,
	follow = {},
	view_range = 10,

	on_rightclick = function(self, clicker)

		-- feed or tame
		if mobs:feed_tame(self, clicker, 4, false, true) then return end
		if mobs:protect(self, clicker) then return end
		if mobs:capture_mob(self, clicker, 5, 50, 80, false, nil) then return end
	end,
})

if not mobs.custom_spawn_nativevillages then
mobs:spawn({
	name = "nativevillages:lakecatfish",
	nodes = {"default:water_source"}, {"default:river_water_source"},
	neighbors = {"nativevillages:fishtrap"},
	min_light = 0,
	interval = 60,
	chance = 1, -- 15000
	active_object_count = 3,
	min_height = -10,
	max_height = 30,
})
end

mobs:register_egg("nativevillages:lakecatfish", ("Catfish"), "alakecatfish.png")

mobs.lakevillagerfemale_drops = {
	"nativevillages:catfish_cooked", "farming:string", "bucket:bucket_water", "farming:salt", "nativevillages:pearl"
}

mobs:register_mob("nativevillages:lakevillagerfemale", {
	type = "npc",
	passive = false,
	damage = 3,
	attack_type = "dogfight",
	attacks_monsters = true,
	attack_npcs = false,
	owner_loyal = true,
	pathfinding = true,
	hp_min = 40,
	hp_max = 60,
	armor = 100,
	collisionbox = {-0.35,-1.0,-0.35, 0.35,0.8,0.35},
	visual = "mesh",
	mesh = "Lakevillagerfemale.b3d",
	drawtype = "front",
	textures = {
		{"texturelakevillagerfemale.png"},
		{"texturelakevillagerfemale2.png"},
		{"texturelakevillagerfemale3.png"},

	},
	makes_footstep_sound = true,
sounds = {
		random = "nativevillages_lakefemale",
		attack = "nativevillages_lakefemale2",
		damage = "nativevillages_lakefemale4",
		death = "nativevillages_lakefemale3",
	},
	walk_velocity = 1,
        walk_chance = 15,
	run_velocity = 3,
	jump = false,
        jump_height = 1,
        stepheight = 0,
        fear_height = 1,
	drops = {
	},
	water_damage = 200,
	lava_damage = 2,
	light_damage = 0,
	follow = {},
        stay_near = "nativevillages:hangingfish",
	view_range = 15,
	owner = "",
	order = "follow",
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

		-- right clicking with gold lump drops random item from mobs.lakevillagerfemale_drops
		if item:get_name() == "ethereal:banana" or item:get_name() == "farming:sugar" or item:get_name() == "group:food_cocoa" or item:get_name() == "farming:banana" then

			if not mobs.is_creative(name) then
				item:take_item()
				clicker:set_wielded_item(item)
			end

			local pos = self.object:get_pos()

			pos.y = pos.y + 0.5

			local drops = self.npc_drops or mobs.lakevillagerfemale_drops

			minetest.add_item(pos, {
				name = drops[math.random(1, #drops)]
			})

			minetest.chat_send_player(name, ("Lake Villager dropped you an item for fruit!"))

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

				minetest.chat_send_player(name, ("Lake Villager stands still."))
			else
				self.order = "follow"

				minetest.chat_send_player(name, ("Lake Villager will follow you."))
			end
		end
	end,
})

if not mobs.custom_spawn_nativevillages then
mobs:spawn({
	name = "nativevillages:lakevillagerfemale",
	nodes = {"default:pine_wood"},
	neighbors = {"nativevillages:hangingfish"},
	min_light = 0,
	interval = 60,
	active_object_count = 2,
	chance = 1, -- 15000
	min_height = 0,
	max_height = 120,
})
end

mobs:register_egg("nativevillages:lakevillagerfemale", ("Female Lake Villager"), "alakevillagerfemale.png")

mobs.lakevillagerfisher_drops = {
	"nativevillages:tamecatfish", "nativevillages:pearl"
}

mobs:register_mob("nativevillages:lakevillagerfisher", {
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
	mesh = "Lakevillagerfisher.b3d",
	drawtype = "front",
	textures = {
		{"texturelakevillagerfisher.png"},

	},
	makes_footstep_sound = true,
sounds = {
		random = "nativevillages_lakemale",
		attack = "nativevillages_lakemale2",
		damage = "nativevillages_lakemale4",
		death = "nativevillages_lakemale3",
	},
	walk_velocity = 1,
        walk_chance = 15,
	run_velocity = 3,
	jump = false,
        jump_height = 1,
        stepheight = 0,
        fear_height = 1,
	drops = {
	},
	water_damage = 200,
	lava_damage = 2,
	light_damage = 0,
	follow = {},
        stay_near = "nativevillages:fishtrap",
	view_range = 15,
	owner = "",
	order = "follow",
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

		-- right clicking with gold lump drops random item from mobs.lakevillagerfisher_drops
		if item:get_name() == "default:gold_lump" then

			if not mobs.is_creative(name) then
				item:take_item()
				clicker:set_wielded_item(item)
			end

			local pos = self.object:get_pos()

			pos.y = pos.y + 0.5

			local drops = self.npc_drops or mobs.lakevillagerfisher_drops

			minetest.add_item(pos, {
				name = drops[math.random(1, #drops)]
			})

			minetest.chat_send_player(name, ("Fisher bred you a catfish for gold!"))

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

				minetest.chat_send_player(name, ("Fisher stands still."))
			else
				self.order = "follow"

				minetest.chat_send_player(name, ("Fisher will follow you."))
			end
		end
	end,
})

if not mobs.custom_spawn_nativevillages then
mobs:spawn({
	name = "nativevillages:lakevillagerfisher",
	nodes = {"default:pine_wood"},
	neighbors = {"nativevillages:fishtrap"},
	min_light = 0,
	interval = 60,
	active_object_count = 1,
	chance = 1, -- 15000
	min_height = 0,
	max_height = 120,
})
end

mobs:register_egg("nativevillages:lakevillagerfisher", ("Fisher"), "alakevillagerfisher.png")


mobs.lakevillagermale_drops = {
	"nativevillages:catfish_cooked", "farming:string", "bucket:bucket_water", "farming:salt", "nativevillages:pearl"
}

mobs:register_mob("nativevillages:lakevillagermale", {
	type = "npc",
	passive = false,
	damage = 3,
	attack_type = "dogfight",
	attacks_monsters = true,
	attack_npcs = false,
	owner_loyal = true,
	pathfinding = true,
	hp_min = 40,
	hp_max = 90,
	armor = 100,
	collisionbox = {-0.35,-1.0,-0.35, 0.35,0.8,0.35},
	visual = "mesh",
	mesh = "Lakevillagermale.b3d",
	drawtype = "front",
	textures = {
		{"texturelakevillagermale.png"},
		{"texturelakevillagermale2.png"},
		{"texturelakevillagermale3.png"},

	},
	makes_footstep_sound = true,
sounds = {
		random = "nativevillages_lakemale",
		attack = "nativevillages_lakemale2",
		damage = "nativevillages_lakemale4",
		death = "nativevillages_lakemale3",
	},
	walk_velocity = 1,
        walk_chance = 15,
	run_velocity = 3,
	jump = false,
        jump_height = 1,
        stepheight = 0,
        fear_height = 1,
	drops = {
	},
	water_damage = 200,
	lava_damage = 2,
	light_damage = 0,
	follow = {},
        stay_near = "nativevillages:fishtrap",
	view_range = 15,
	owner = "",
	order = "follow",
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

				-- right clicking with gold lump drops random item from mobs.lakevillagermale_drops
		if item:get_name() == "ethereal:banana" or item:get_name() == "farming:sugar" or item:get_name() == "group:food_cocoa" or item:get_name() == "farming:banana" then

			if not mobs.is_creative(name) then
				item:take_item()
				clicker:set_wielded_item(item)
			end

			local pos = self.object:get_pos()

			pos.y = pos.y + 0.5

			local drops = self.npc_drops or mobs.lakevillagermale_drops

			minetest.add_item(pos, {
				name = drops[math.random(1, #drops)]
			})

			minetest.chat_send_player(name, ("Lake Villager dropped you an item for fruit!"))

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
	name = "nativevillages:lakevillagermale",
	nodes = {"default:pine_wood"},
	neighbors = {"nativevillages:hangingfish"},
	min_light = 0,
	interval = 60,
	active_object_count = 1,
	chance = 1, -- 15000
	min_height = 0,
	max_height = 120,
})
end

mobs:register_egg("nativevillages:lakevillagermale", ("Male Lake Villager"), "alakevillagermale.png")

