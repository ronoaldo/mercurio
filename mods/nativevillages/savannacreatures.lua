mobs:register_mob("nativevillages:malelion", {
stepheight = 1,
	type = "monster",
	passive = false,
        attack_type = "dogfight",
	attack_animals = true,
	reach = 2,
        damage = 10,
	hp_min = 45,
	hp_max = 75,
	armor = 100,
	collisionbox = {-0.5, -0.01, -0.5, 0.5, 0.95, 0.5},
	visual = "mesh",
	mesh = "Lionmale.b3d",
	visual_size = {x = 1.0, y = 1.0},
	textures = {
		{"texturelionmale.png"},
	},
	sounds = {
		attack = "nativevillages_lion2",
		random = "nativevillages_lion",
		damage = "nativevillages_lion4",
		death = "nativevillages_lion3",
		distance = 10,
	},
	makes_footstep_sound = true,
sounds = {
		attack = "nativevillages_lion2",
		random = "nativevillages_lion",
		damage = "nativevillages_lion4",
		death = "nativevillages_lion3",
		distance = 10,
	},
	walk_velocity = 1,
	run_velocity = 3,
	runaway = false,
	jump = false,
        jump_height = 2,
	drops = {
	},
	water_damage = 0,
	lava_damage = 4,
	light_damage = 0,
	fear_height = 4,
	animation = {
		speed_normal = 50,
		stand_start = 0,
		stand_end = 100,
		stand2_start = 100,
		stand2_end = 200,
		walk_start = 200,
		walk_end = 300,
                punch_speed = 100,
		punch_start = 300,
		punch_end = 400,
	},

	follow = {
		},
	view_range = 15,

	on_rightclick = function(self, clicker)

		-- feed or tame
		if mobs:feed_tame(self, clicker, 4, false, true) then return end
		if mobs:protect(self, clicker) then return end
		if mobs:capture_mob(self, clicker, 5, 50, 80, false, nil) then return end
	end,
})


if not mobs.custom_spawn_nativevillages then
mobs:spawn({
	name = "nativevillages:malelion",
	neighbors = {"nativevillages:savannacorpse"},
	nodes = {"default:dry_dirt_with_dry_grass"},
	min_light = 0,
	interval = 60,
	active_object_count = 1,
	chance = 1, -- 15000
	min_height = 10,
	max_height = 50,

})
end

mobs:register_egg("nativevillages:malelion", ("Male Lion"), "amalelion.png")

mobs:register_mob("nativevillages:femalelion", {
stepheight = 1,
	type = "monster",
	passive = false,
        attack_type = "dogfight",
	attack_animals = true,
	reach = 2,
        damage = 7,
	hp_min = 45,
	hp_max = 75,
	armor = 100,
	collisionbox = {-0.5, -0.01, -0.5, 0.5, 0.95, 0.5},
	visual = "mesh",
	mesh = "Lionfemale.b3d",
	visual_size = {x = 1.0, y = 1.0},
	textures = {
		{"texturelionfemale.png"},
	},
	sounds = {
		attack = "nativevillages_lion2",
		random = "nativevillages_lion",
		damage = "nativevillages_lion4",
		death = "nativevillages_lion3",
		distance = 10,
	},
	makes_footstep_sound = true,
	walk_velocity = 1,
	run_velocity = 4,
	runaway = false,
	jump = false,
        jump_height = 2,
	drops = {
	},
	water_damage = 0,
	lava_damage = 4,
	light_damage = 0,
	fear_height = 4,
	animation = {
		speed_normal = 50,
		stand_start = 0,
		stand_end = 100,
		stand2_start = 100,
		stand2_end = 200,
		walk_start = 200,
		walk_end = 300,
                punch_speed = 100,
		punch_start = 300,
		punch_end = 400,
	},

	follow = {
		},
	view_range = 15,

	on_rightclick = function(self, clicker)

		-- feed or tame
		if mobs:feed_tame(self, clicker, 4, false, true) then return end
		if mobs:protect(self, clicker) then return end
		if mobs:capture_mob(self, clicker, 5, 50, 80, false, nil) then return end
	end,
})


if not mobs.custom_spawn_nativevillages then
mobs:spawn({
	name = "nativevillages:femalelion",
	neighbors = {"nativevillages:savannacorpse"},
	nodes = {"default:dry_dirt_with_dry_grass"},
	min_light = 0,
	interval = 60,
	active_object_count = 1,
	chance = 1, -- 15000
	min_height = 10,
	max_height = 50,

})
end

mobs:register_egg("nativevillages:femalelion", ("Female Lion"), "afemalelion.png")

mobs.savannadoctor_drops = {
	"nativevillages:zombietame"
}

mobs:register_mob("nativevillages:savannadoctor", {
	type = "npc",
	passive = false,
	damage = 3,
        range = 4,
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
	mesh = "Savannadoctor.b3d",
	drawtype = "front",
	textures = {
		{"texturesavannadoctor.png"},

	},
	makes_footstep_sound = true,
sounds = {
		random = "nativevillages_witchdoctor",
		attack = "nativevillages_witchdoctor2",
		damage = "nativevillages_savannamale4",
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
        stay_near = "nativevillages:savannashrine",
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

		-- right clicking with gold lump drops random item from mobs.savannadoctor_drops
		if item:get_name() == "people:warriorgrave" or item:get_name() == "people:doctorgrave" or item:get_name() == "people:minergrave" or item:get_name() == "people:farmergrave" or item:get_name() == "people:villagergrave" or item:get_name() == "people:instructorgrave" or item:get_name() == "people:smithgrave" then

			if not mobs.is_creative(name) then
				item:take_item()
				clicker:set_wielded_item(item)
			end

			local pos = self.object:get_pos()

			pos.y = pos.y + 0.5

			local drops = self.npc_drops or mobs.savannadoctor_drops

			minetest.add_item(pos, {
				name = drops[math.random(1, #drops)]
			})

			minetest.chat_send_player(name, ("Witch Doctor created a tame Zombie!"))

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

				minetest.chat_send_player(name, ("Witch Doctor stands still."))
			else
				self.order = "follow"

				minetest.chat_send_player(name, ("Witch Doctor will follow you."))
			end
		end
	end,
})

if not mobs.custom_spawn_nativevillages then
mobs:spawn({
	name = "nativevillages:savannadoctor",
	nodes = {"default:dry_dirt_with_dry_grass", "default:clay"},
	neighbors = {"nativevillages:savannashrine"},
	min_light = 0,
	interval = 60,
	active_object_count = 1,
	chance = 1, -- 15000
	min_height = 0,
	max_height = 120,
})
end

mobs:register_egg("nativevillages:savannadoctor", ("Witch Doctor"), "asavannadoctor.png")

mobs.savannaqueen_drops = {
	"default:goldblock"
}

mobs:register_mob("nativevillages:savannaqueen", {
	type = "npc",
	passive = false,
	damage = 3,
	attack_type = "dogfight",
	attacks_monsters = true,
	attack_npcs = false,
	owner_loyal = true,
	pathfinding = true,
	hp_min = 50,
	hp_max = 100,
	armor = 100,
	collisionbox = {-0.35,-1.0,-0.35, 0.35,0.8,0.35},
	visual = "mesh",
	mesh = "Savannaqueen.b3d",
	drawtype = "front",
	textures = {
		{"texturesavannaqueen.png"},

	},
	makes_footstep_sound = true,
sounds = {
		random = "nativevillages_savannafemale",
		attack = "nativevillages_savannafemale3",
		damage = "nativevillages_savannafemale4",
		death = "nativevillages_savannafemale2",
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
        stay_near = "nativevillages:savannashrine",
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

		-- right clicking with gold lump drops random item from mobs.savannaqueen_drops
		if item:get_name() == "default:diamond" then

			if not mobs.is_creative(name) then
				item:take_item()
				clicker:set_wielded_item(item)
			end

			local pos = self.object:get_pos()

			pos.y = pos.y + 0.5

			local drops = self.npc_drops or mobs.savannaqueen_drops

			minetest.add_item(pos, {
				name = drops[math.random(1, #drops)]
			})

			minetest.chat_send_player(name, ("Royalty dropped you an item for gold!"))

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

				minetest.chat_send_player(name, ("Royalty stands still."))
			else
				self.order = "follow"

				minetest.chat_send_player(name, ("Royalty will follow you."))
			end
		end
	end,
})

if not mobs.custom_spawn_nativevillages then
mobs:spawn({
	name = "nativevillages:savannaqueen",
	nodes = {"default:dry_dirt_with_dry_grass", "default:clay"},
	neighbors = {"nativevillages:savannathrone"},
	min_light = 0,
	interval = 60,
	active_object_count = 1,
	chance = 1, -- 15000
	min_height = 0,
	max_height = 120,
})
end

mobs:register_egg("nativevillages:savannaqueen", ("Savanna Queen"), "asavannaqueen.png")

mobs.savannamale_drops = {
	"farming:vanilla", "farming:pumpkin", "farming:potato", "farming:pineapple", "farming:pepper", "farming:onion", "farming:peas", "farming:melon", "farming:cucumber", "farming:coffee_beans"
}

mobs:register_mob("nativevillages:savannamale", {
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
	mesh = "Savannamale.b3d",
	drawtype = "front",
	textures = {
		{"texturesavannamale.png"},
		{"texturesavannamale2.png"},
		{"texturesavannamale3.png"},
		{"texturesavannamale4.png"},

	},
	makes_footstep_sound = true,
sounds = {
		random = "nativevillages_savannamale",
		attack = "nativevillages_savannamale3",
		damage = "nativevillages_savannamale4",
		death = "nativevillages_savannamale2",
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
        stay_near = "nativevillages:savannavessels",
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

		-- right clicking with gold lump drops random item from mobs.savannamale_drops
		if item:get_name() == "nativevillages:pearl" then

			if not mobs.is_creative(name) then
				item:take_item()
				clicker:set_wielded_item(item)
			end

			local pos = self.object:get_pos()

			pos.y = pos.y + 0.5

			local drops = self.npc_drops or mobs.savannamale_drops

			minetest.add_item(pos, {
				name = drops[math.random(1, #drops)]
			})

			minetest.chat_send_player(name, ("Savanna Villager dropped you an item for a pearl!"))

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

				minetest.chat_send_player(name, ("Savanna Villager stands still."))
			else
				self.order = "follow"

				minetest.chat_send_player(name, ("Savanna Villager will follow you."))
			end
		end
	end,
})

if not mobs.custom_spawn_nativevillages then
mobs:spawn({
	name = "nativevillages:savannamale",
	nodes = {"default:dry_dirt_with_dry_grass", "default:clay"},
	neighbors = {"nativevillages:savannavessels"},
	min_light = 0,
	interval = 60,
	active_object_count = 2,
	chance = 1, -- 15000
	min_height = 0,
	max_height = 120,
})
end

mobs:register_egg("nativevillages:savannamale", ("Male Savanna Villager"), "asavannamale.png")

mobs.savannaking_drops = {
	"default:goldblock"
}

mobs:register_mob("nativevillages:savannaking", {
	type = "npc",
	passive = false,
	damage = 3,
	attack_type = "dogfight",
	attacks_monsters = true,
	attack_npcs = false,
	owner_loyal = true,
	pathfinding = true,
	hp_min = 50,
	hp_max = 120,
	armor = 100,
	collisionbox = {-0.35,-1.0,-0.35, 0.35,0.8,0.35},
	visual = "mesh",
	mesh = "Savannaking.b3d",
	drawtype = "front",
	textures = {
		{"texturesavannaking.png"},

	},
	makes_footstep_sound = true,
sounds = {
		random = "nativevillages_savannamale",
		attack = "nativevillages_savannamale3",
		damage = "nativevillages_savannamale4",
		death = "nativevillages_savannamale2",
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
        stay_near = "nativevillages:savannathrone",
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

				-- right clicking with gold lump drops random item from mobs.savannaking_drops
		if item:get_name() == "default:diamond" then

			if not mobs.is_creative(name) then
				item:take_item()
				clicker:set_wielded_item(item)
			end

			local pos = self.object:get_pos()

			pos.y = pos.y + 0.5

			local drops = self.npc_drops or mobs.savannaking_drops

			minetest.add_item(pos, {
				name = drops[math.random(1, #drops)]
			})

			minetest.chat_send_player(name, ("Royalty dropped you an item for gold!"))

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

				minetest.chat_send_player(name, ("Royalty stands still."))
			else
				self.order = "follow"

				minetest.chat_send_player(name, ("Royalty will follow you."))
			end
		end
	end,
})

if not mobs.custom_spawn_nativevillages then
mobs:spawn({
	name = "nativevillages:savannaking",
	nodes = {"default:dry_dirt_with_dry_grass", "default:clay"},
	neighbors = {"nativevillages:savannathrone"},
	min_light = 0,
	interval = 60,
	active_object_count = 1,
	chance = 1, -- 15000
	min_height = 0,
	max_height = 120,
})
end

mobs:register_egg("nativevillages:savannaking", ("Savanna King"), "asavannaking.png")

mobs.savannafemale_drops = {
	"farming:vanilla", "farming:pumpkin", "farming:potato", "farming:pineapple", "farming:pepper", "farming:onion", "farming:peas", "farming:melon", "farming:cucumber", "farming:coffee_beans"
}

mobs:register_mob("nativevillages:savannafemale", {
	type = "npc",
	passive = false,
	damage = 3,
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
	mesh = "Savannafemale.b3d",
	drawtype = "front",
	textures = {
		{"texturesavannafemale.png"},
		{"texturesavannafemale2.png"},
		{"texturesavannafemale3.png"},

	},
	makes_footstep_sound = true,
sounds = {
		random = "nativevillages_savannafemale",
		attack = "nativevillages_savannafemale3",
		damage = "nativevillages_savannafemale4",
		death = "nativevillages_savannafemale2",
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
        stay_near = "nativevillages:savannavessels",
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

		-- right clicking with gold lump drops random item from mobs.savannafemale_drops
		if item:get_name() == "nativevillages:pearl" then

			if not mobs.is_creative(name) then
				item:take_item()
				clicker:set_wielded_item(item)
			end

			local pos = self.object:get_pos()

			pos.y = pos.y + 0.5

			local drops = self.npc_drops or mobs.savannafemale_drops

			minetest.add_item(pos, {
				name = drops[math.random(1, #drops)]
			})

			minetest.chat_send_player(name, ("Savanna Villager dropped you an item for a pearl!"))

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

				minetest.chat_send_player(name, ("Savanna Villager stands still."))
			else
				self.order = "follow"

				minetest.chat_send_player(name, ("Savanna Villager will follow you."))
			end
		end
	end,
})

if not mobs.custom_spawn_nativevillages then
mobs:spawn({
	name = "nativevillages:savannafemale",
	nodes = {"default:dry_dirt_with_dry_grass", "default:clay"},
	neighbors = {"nativevillages:savannavessels"},
	min_light = 0,
	interval = 60,
	active_object_count = 2,
	chance = 1, -- 15000
	min_height = 0,
	max_height = 120,
})
end

mobs:register_egg("nativevillages:savannafemale", ("Female Savanna Villager"), "asavannafemale.png")

