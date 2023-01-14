local S = minetest.get_translator("nativevillages")

mobs:register_mob("nativevillages:grasslandcow", {
	stepheight = 1,
	type = "animal",
	passive = false,
	attack_type = "dogfight",
	group_attack = true,
	owner_loyal = true,
	attack_npcs = false,
	reach = 2,
	damage = 4,
	hp_min = 20,
	hp_max = 60,
	armor = 100,
	collisionbox = {-0.25, -0.01, -0.25, 0.25, 1.5, 0.25},
	visual = "mesh",
	mesh = "Grasslandcow.b3d",
	textures = {
		{"texturegrasslandcow.png"},
		{"texturegrasslandcow2.png"},
		{"texturegrasslandcow3.png"},
	},
	makes_footstep_sound = true,
	sounds = {
		random = "nativevillages_cow",
		attack = "nativevillages_cow2",
		damage = "nativevillages_cow3",
	},
	walk_velocity = 1,
	run_velocity = 3,
	runaway = false,
	jump = false,
	jump_height = 3,
	pushable = true,
	follow = {},
	view_range = 10,
        stay_near = {{"nativevillages:cowdropping"}, 5},
	drops = {
	},
	water_damage = 0,
	lava_damage = 5,
	light_damage = 0,
	fear_height = 2,
	animation = {
		speed_normal = 50,
		stand_start = 0,
		stand_end = 100,
		stand2_start = 100,
		stand2_end = 200,
		walk_start = 200,
		walk_end = 300,
		punch_start = 300,
		punch_end = 400,
		die_start = 300,
		die_end = 400,
		die_speed = 50,
		die_loop = false,
		die_rotate = true,
	},
	on_rightclick = function(self, clicker)

		if mobs:feed_tame(self, clicker, 8, true, true) then return end
		if mobs:protect(self, clicker) then return end
		if mobs:capture_mob(self, clicker, 0, 0, 25, false, nil) then return end
	end,
})


if not mobs.custom_spawn_nativevillages then
mobs:spawn({
	name = "nativevillages:grasslandcow",
	nodes = {"default:dirt_with_grass", "default:dirt_with_coniferous_litter", "default:clay"},
	neighbors = {"nativevillages:cowdropping"},
	min_light = 0,
	interval = 60,
	active_object_count = 3,
	chance = 1, -- 15000
	min_height = 0,
	max_height = 120,
})
end

mobs:register_egg("nativevillages:grasslandcow", S("Grassland Cow"), "agrasslandcow.png")


mobs:alias_mob("nativevillages:grasslandcow", "nativevillages:grasslandcow") -- compatibility





mobs.grasslandfemale_drops = {
	"nativevillages:bucket_milk", "nativevillages:cheese", "default:iron_lump",
	"default:copper_lump", "default:tin_lump", "mobs:meat"
}

mobs:register_mob("nativevillages:grasslandfemale", {
	type = "npc",
	passive = false,
	damage = 3,
	attack_type = "dogfight",
	attacks_monsters = true,
	attack_npcs = false,
	owner_loyal = true,
	pathfinding = true,
	hp_min = 40,
	hp_max = 70,
	armor = 100,
	collisionbox = {-0.35,-1.0,-0.35, 0.35,0.8,0.35},
	visual = "mesh",
	mesh = "Grasslandfemale.b3d",
	drawtype = "front",
	textures = {
		{"texturegrasslandfemale.png"},
		{"texturegrasslandfemale2.png"},
		{"texturegrasslandfemale3.png"},
		{"texturegrasslandfemale4.png"},

	},
	child_texture = {
		{"texturegrasslandbabyf.png"}, 
	},
	makes_footstep_sound = true,
sounds = {
		attack = "nativevillages_grasslandfemale2",
		random = "nativevillages_grasslandfemale",
		damage = "nativevillages_grasslandfemale3",
		death = "nativevillages_grasslandfemale3",
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
        stay_near = {{"nativevillages:grasslandbarrel"}, 5},
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
		die_start = 200,
		die_end = 300,
		die_speed = 50,
		die_loop = false,
		die_rotate = true,
	},

	on_rightclick = function(self, clicker)

		-- feed to heal npc
		if mobs:feed_tame(self, clicker, 8, true, true) then return end

		-- capture npc with net or lasso
		if mobs:capture_mob(self, clicker, 0, 15, 25, false, nil) then return end

		-- protect npc with mobs:protector
		if mobs:protect(self, clicker) then return end

		local item = clicker:get_wielded_item()
		local name = clicker:get_player_name()

		-- right clicking with gold lump drops random item from mobs.grasslandfemale_drops
		if item:get_name() == "farming:bread" or item:get_name() == "farming:garlic_bread" or item:get_name() == "ethereal:banana_bread" then

			if not mobs.is_creative(name) then
				item:take_item()
				clicker:set_wielded_item(item)
			end

			local pos = self.object:get_pos()

			pos.y = pos.y + 0.5

			local drops = self.npc_drops or mobs.grasslandfemale_drops

			minetest.add_item(pos, {
				name = drops[math.random(1, #drops)]
			})

			minetest.chat_send_player(name, S("Grasslander dropped you an item for bread!"))

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

				minetest.chat_send_player(name, S("Grasslander stands still."))
			else
				self.order = "follow"

				minetest.chat_send_player(name, S("Grasslander will follow you."))
			end
		end
	end,
})

if not mobs.custom_spawn_nativevillages then
mobs:spawn({
	name = "nativevillages:grasslandfemale",
	nodes = {"default:dirt_with_grass", "default:cobble", "default:dirt_with_coniferous_litter", "default:clay"},
	neighbors = {"nativevillages:grasslandbarrel"},
	min_light = 0,
	interval = 60,
	active_object_count = 2,
	chance = 1, -- 15000
	min_height = 0,
	max_height = 120,
})
end

mobs:register_egg("nativevillages:grasslandfemale", S("Female Grasslander"), "agrasslandfemale.png")

-- compatibility
mobs:alias_mob("nativevillages:grasslandfemale", "nativevillages:grasslandfemale")

mobs.grasslandmale_drops = {
	"nativevillages:bucket_milk", "nativevillages:cheese", "default:iron_lump",
	"default:copper_lump", "default:tin_lump", "mobs:meat"
}

mobs:register_mob("nativevillages:grasslandmale", {
	type = "npc",
	passive = false,
	damage = 5,
	attack_type = "dogfight",
	attacks_monsters = true,
	attack_npcs = false,
	owner_loyal = true,
	pathfinding = true,
	hp_min = 70,
	hp_max = 90,
	armor = 100,
	collisionbox = {-0.35,-1.0,-0.35, 0.35,0.8,0.35},
	visual = "mesh",
	mesh = "Grasslandmale.b3d",
	drawtype = "front",
	textures = {
		{"texturegrasslandmale.png"},
		{"texturegrasslandmale2.png"},
		{"texturegrasslandmale3.png"},
		{"texturegrasslandmale4.png"},

	},
	child_texture = {
		{"texturegrasslandbabym.png"},
	},
	makes_footstep_sound = true,
sounds = {
		attack = "nativevillages_grasslandmale2",
		random = "nativevillages_grasslandmale",
		damage = "nativevillages_grasslandmale3",
		death = "nativevillages_grasslandmale3",
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
        stay_near = {{"nativevillages:grasslandbarrel"}, 5},
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
		die_start = 200,
		die_end = 300,
		die_speed = 50,
		die_loop = false,
		die_rotate = true,
	},

	on_rightclick = function(self, clicker)

		-- feed to heal npc
		if mobs:feed_tame(self, clicker, 8, true, true) then return end

		-- capture npc with net or lasso
		if mobs:capture_mob(self, clicker, 0, 15, 25, false, nil) then return end

		-- protect npc with mobs:protector
		if mobs:protect(self, clicker) then return end

		local item = clicker:get_wielded_item()
		local name = clicker:get_player_name()

		-- right clicking with gold lump drops random item from mobs.grasslandmale_drops
		if item:get_name() == "farming:bread" or item:get_name() == "farming:garlic_bread" or item:get_name() == "ethereal:banana_bread" then

			if not mobs.is_creative(name) then
				item:take_item()
				clicker:set_wielded_item(item)
			end

			local pos = self.object:get_pos()

			pos.y = pos.y + 0.5

			local drops = self.npc_drops or mobs.grasslandmale_drops

			minetest.add_item(pos, {
				name = drops[math.random(1, #drops)]
			})

			minetest.chat_send_player(name, S("Grasslander dropped you an item for bread!"))

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

				minetest.chat_send_player(name, S("Grasslander stands still."))
			else
				self.order = "follow"

				minetest.chat_send_player(name, S("Grasslander will follow you."))
			end
		end
	end,
})

if not mobs.custom_spawn_nativevillages then
mobs:spawn({
	name = "nativevillages:grasslandmale",
	nodes = {"default:dirt_with_grass", "default:cobble", "default:dirt_with_coniferous_litter", "default:clay"},
	neighbors = {"nativevillages:grasslandbarrel"},
	min_light = 0,
	interval = 60,
	active_object_count = 2,
	chance = 1, -- 15000
	min_height = 0,
	max_height = 120,
})
end

mobs:register_egg("nativevillages:grasslandmale", S("Male Grasslander"), "agrasslandmale.png")

-- compatibility
mobs:alias_mob("nativevillages:grasslandmale", "nativevillages:grasslandmale")


mobs.grasslandwitch_drops = {
	"nativevillages:grasslandcat", "nativevillages:toadbag"
}


mobs:register_mob("nativevillages:grasslandwitch", {
	type = "npc",
	passive = false,
        attack_type = "shoot",
	shoot_interval = 1,
	arrow = "nativevillages:fireball",
	shoot_offset = 2,
	attack_animals = false,
        damage = 7,
	attacks_monsters = true,
	attack_npcs = false,
	owner_loyal = true,
	pathfinding = true,
	hp_min = 20,
	hp_max = 60,
	armor = 100,
	collisionbox = {-0.35,-1.0,-0.35, 0.35,0.8,0.35},
	visual = "mesh",
	mesh = "Grasslandwitch.b3d",
	drawtype = "front",
	textures = {
		{"texturegrasslandwitch.png"},
		{"texturegrasslandwitch2.png"},

	},
	makes_footstep_sound = true,
sounds = {
		shoot = "nativevillages_witch2",
		random = "nativevillages_witch",
		damage = "nativevillages_witch4",
		death = "nativevillages_witch3",
		distance = 10,
	},
	walk_velocity = 1,
        walk_chance = 15,
	run_velocity = 3,
	jump = true,
	drops = {
		{name = "default:coal_lump", chance = 1, min = 1, max = 3},
	},
	water_damage = 0,
	lava_damage = 2,
	light_damage = 0,
	follow = {},
        stay_near = {{"nativevillages:grasslandalta"}, 4},
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
                shoot_speed = 100,
		shoot_start = 200,
		shoot_end = 300,
		die_start = 200,
		die_end = 300,
		die_speed = 50,
		die_loop = false,
		die_rotate = true,
	},

	on_rightclick = function(self, clicker)

		-- feed to heal npc
		if mobs:feed_tame(self, clicker, 8, true, true) then return end

		-- capture npc with net or lasso
		if mobs:capture_mob(self, clicker, 0, 15, 25, false, nil) then return end

		-- protect npc with mobs:protector
		if mobs:protect(self, clicker) then return end

		local item = clicker:get_wielded_item()
		local name = clicker:get_player_name()

		-- right clicking with gold lump drops random item from mobs.grasslandwitch_drops
		if item:get_name() == "default:diamond" then

			if not mobs.is_creative(name) then
				item:take_item()
				clicker:set_wielded_item(item)
			end

			local pos = self.object:get_pos()

			pos.y = pos.y + 0.5

			local drops = self.npc_drops or mobs.grasslandwitch_drops

			minetest.add_item(pos, {
				name = drops[math.random(1, #drops)]
			})

			minetest.chat_send_player(name, S("Witch dropped you an item for diamond!"))

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

				minetest.chat_send_player(name, S("Witch stands still."))
			else
				self.order = "follow"

				minetest.chat_send_player(name, S("Witch will follow you."))
			end
		end
	end,
})

if not mobs.custom_spawn_nativevillages then
mobs:spawn({
	name = "nativevillages:grasslandwitch",
	nodes = {"default:dirt_with_grass", "default:clay"},
	neighbors = {"nativevillages:grasslandaltar"},
	min_light = 0,
	interval = 60,
	active_object_count = 1,
	chance = 1, -- 15000
	min_height = 0,
	max_height = 120,
})
end

mobs:register_egg("nativevillages:grasslandwitch", S("Grassland Witch"), "agrasslandwitch.png")

-- compatibility
mobs:alias_mob("nativevillages:grasslandwitch", "nativevillages:grasslandwitch")