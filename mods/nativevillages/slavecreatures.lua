mobs.slavechickenbreeder_drops = {
	"nativevillages:desertchickentame"
}

mobs:register_mob("nativevillages:slavechickenbreeder", {
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
	mesh = "Slavechickenbreeder.b3d",
	drawtype = "front",
	textures = {
		{"textureslavechickenbreeder.png"},
		{"textureslavechickenbreeder2.png"},
		{"textureslavechickenbreeder3.png"},

	},
	makes_footstep_sound = true,
sounds = {
		attack = "nativevillages_desertfemale2",
		random = "nativevillages_desertfemale",
		damage = "nativevillages_desertfemale4",
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
	follow = {"farming:turkish_delight", "farming:garlic_bread", "farming:donut", "farming:donut_chocolate", "farming:donut_apple", "farming:porridge", "farming:jaffa_cake", "farming:apple_pie", "farming:spaghetti", "farming:burger", "farming:bibimbap"},
	view_range = 15,
	owner = "singleplayer",
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

		-- right clicking with gold lump drops random item from mobs.slavechickenbreeder_drops
		if item:get_name() == "farming:seed_wheat" then

			if not mobs.is_creative(name) then
				item:take_item()
				clicker:set_wielded_item(item)
			end

			local pos = self.object:get_pos()

			pos.y = pos.y + 0.5

			local drops = self.npc_drops or mobs.slavechickenbreeder_drops

			minetest.add_item(pos, {
				name = drops[math.random(1, #drops)]
			})

			minetest.chat_send_player(name, ("Chicken hatched!"))

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

				minetest.chat_send_player(name, ("Chicken Breeder stands still."))
			else
				self.order = "follow"

				minetest.chat_send_player(name, ("Chicken Breeder will follow you."))
			end
		end
	end,
})


mobs:register_egg("nativevillages:slavechickenbreeder", ("Chicken Breeder"), "aslavechickenbreeder.png")

mobs.slavecowherder_drops = {
	"nativevillages:domesticcow"
}

mobs:register_mob("nativevillages:slavecowherder", {
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
	mesh = "Slavecowherder.b3d",
	drawtype = "front",
	textures = {
		{"textureslavecowherder.png"},
		{"textureslavecowherder2.png"},

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
	follow = {"farming:turkish_delight", "farming:garlic_bread", "farming:donut", "farming:donut_chocolate", "farming:donut_apple", "farming:porridge", "farming:jaffa_cake", "farming:apple_pie", "farming:spaghetti", "farming:burger", "farming:bibimbap"},
	view_range = 15,
	owner = "singleplayer",
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

		-- right clicking with gold lump drops random item from mobs.slavecowherder_drops
		if item:get_name() == "farming:wheat" then

			if not mobs.is_creative(name) then
				item:take_item()
				clicker:set_wielded_item(item)
			end

			local pos = self.object:get_pos()

			pos.y = pos.y + 0.5

			local drops = self.npc_drops or mobs.slavecowherder_drops

			minetest.add_item(pos, {
				name = drops[math.random(1, #drops)]
			})

			minetest.chat_send_player(name, ("Cow has been raised!"))

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

				minetest.chat_send_player(name, ("Cow Herder stands still."))
			else
				self.order = "follow"

				minetest.chat_send_player(name, ("Cow Herder will follow you."))
			end
		end
	end,
})


mobs:register_egg("nativevillages:slavecowherder", ("Cow Herder"), "aslavecowherder.png")

mobs.slaveliontrainer_drops = {
	"nativevillages:femaleliontame", "nativevillages:maleliontame"
}

mobs:register_mob("nativevillages:slaveliontrainer", {
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
	mesh = "Slaveliontrainer.b3d",
	drawtype = "front",
	textures = {
		{"textureslaveliontrainer.png"},
		{"textureslaveliontrainer2.png"},
		{"textureslaveliontrainer3.png"},

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
	follow = {"farming:turkish_delight", "farming:garlic_bread", "farming:donut", "farming:donut_chocolate", "farming:donut_apple", "farming:porridge", "farming:jaffa_cake", "farming:apple_pie", "farming:spaghetti", "farming:burger", "farming:bibimbap"},
	view_range = 15,
	owner = "singleplayer",
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

		-- right clicking with gold lump drops random item from mobs.slaveliontrainer_drops
		if item:get_name() == "default:gold_lump" then

			if not mobs.is_creative(name) then
				item:take_item()
				clicker:set_wielded_item(item)
			end

			local pos = self.object:get_pos()

			pos.y = pos.y + 0.5

			local drops = self.npc_drops or mobs.slaveliontrainer_drops

			minetest.add_item(pos, {
				name = drops[math.random(1, #drops)]
			})

			minetest.chat_send_player(name, ("Lion has been raised!"))

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

				minetest.chat_send_player(name, ("Lion Trainer stands still."))
			else
				self.order = "follow"

				minetest.chat_send_player(name, ("Lion Trainer will follow you."))
			end
		end
	end,
})


mobs:register_egg("nativevillages:slaveliontrainer", ("Lion Trainer"), "aslaveliontrainer.png")



mobs:register_mob("nativevillages:slavefemaledancer", {
	type = "npc",
	passive = false,
	damage = 3,
	attack_type = "dogfight",
	attacks_monsters = true,
	attack_npcs = false,
	owner_loyal = true,
	pathfinding = true,
	hp_min = 40,
	hp_max = 50,
	armor = 100,
	collisionbox = {-0.35,-1.0,-0.35, 0.35,0.8,0.35},
	visual = "mesh",
	mesh = "Slavefemaledancer.b3d",
	drawtype = "front",
	textures = {
		{"textureslavefemaledancer.png"},
		{"textureslavefemaledancer2.png"},
		{"textureslavefemaledancer3.png"},
		{"textureslavefemaledancer4.png"},
		{"textureslavefemaledancer5.png"},

	},
	makes_footstep_sound = true,
sounds = {
		random = "nativevillages_dancefermale",
		attack = "nativevillages_dancefermale2",
		damage = "nativevillages_dancefermale3",
		death = "nativevillages_dancefermale4",
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
	follow = {"farming:turkish_delight", "farming:garlic_bread", "farming:donut", "farming:donut_chocolate", "farming:donut_apple", "farming:porridge", "farming:jaffa_cake", "farming:apple_pie", "farming:spaghetti", "farming:burger", "farming:bibimbap"},
	view_range = 15,
	owner = "singleplayer",
	order = "follow",
	fear_height = 3,
	animation = {
		speed_normal = 50,
		stand_start = 0,
		stand_end = 100,
		stand2_start = 100,
		stand2_end = 200,
		stand3_start = 200,
		stand3_end = 300,
		walk_start = 300,
		walk_end = 400,
                punch_speed = 100,
		punch_start = 400,
		punch_end = 500,
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

		-- right clicking with gold lump drops random item from mobs.npc_drops
		if item:get_name() == "default:gold_lump" then

			if not mobs.is_creative(name) then
				item:take_item()
				clicker:set_wielded_item(item)
			end

			local pos = self.object:get_pos()

			pos.y = pos.y + 0.5

			local drops = self.npc_drops or mobs.npc_drops

			minetest.add_item(pos, {
				name = drops[math.random(1, #drops)]
			})

			minetest.chat_send_player(name, ("NPC dropped you an item for gold!"))

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

				minetest.chat_send_player(name, ("Dancer will dance!."))
			else
				self.order = "follow"

				minetest.chat_send_player(name, ("Dancer will follow you."))
			end
		end
	end,
})


mobs:register_egg("nativevillages:slavefemaledancer", ("Female Dancer"), "aslavefemaledancer.png")


mobs:register_mob("nativevillages:slaveloyalcannibal", {
	type = "npc",
	passive = false,
	damage = 6,
        reach = 4,
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
	mesh = "Slaveloyalcannibal.b3d",
	drawtype = "front",
	textures = {
		{"textureslaveloyalcannibal.png"},
		{"textureslaveloyalcannibal2.png"},
		{"textureslaveloyalcannibal3.png"},

	},
	makes_footstep_sound = true,
	sounds = {
		random = "nativevillages_cannibalmale",
		attack = "nativevillages_cannibalmale2",
		damage = "nativevillages_cannibalmale3",
		death = "nativevillages_cannibalmale4",
	},
	walk_velocity = 2,
	run_velocity = 3,
	jump = true,
	drops = {
	},
	water_damage = 0,
	lava_damage = 2,
	light_damage = 0,
	follow = {"nativevillages:driedhumanmeat"},
	view_range = 15,
	owner = "singleplayer",
	order = "follow",
	fear_height = 3,
	animation = {
		speed_normal = 100,
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




		-- by right-clicking owner can switch npc between follow and stand
		if self.owner and self.owner == name then

			if self.order == "follow" then

				self.attack = nil
				self.order = "stand"
				self.state = "stand"
				self:set_animation("stand")
				self:set_velocity(0)

				minetest.chat_send_player(name, ("Cannibal stands still."))
			else
				self.order = "follow"

				minetest.chat_send_player(name, ("Cannibal will follow you."))
			end
		end
	end,
})


mobs:register_egg("nativevillages:slaveloyalcannibal", ("Loyal Cannibal"), "aslaveloyalcannibal.png")


mobs:register_mob("nativevillages:slavemaledancer", {
	type = "npc",
	passive = false,
	damage = 3,
	attack_type = "dogfight",
	attacks_monsters = true,
	attack_npcs = false,
	owner_loyal = true,
	pathfinding = true,
	hp_min = 60,
	hp_max = 70,
	armor = 100,
	collisionbox = {-0.35,-1.0,-0.35, 0.35,0.8,0.35},
	visual = "mesh",
	mesh = "Slavemaledancer.b3d",
	drawtype = "front",
	textures = {
		{"textureslavemaledancer.png"},
		{"textureslavemaledancer2.png"},
		{"textureslavemaledancer3.png"},
		{"textureslavemaledancer4.png"},

	},
	makes_footstep_sound = true,
	sounds = {
		random = "nativevillages_dancermale",
		attack = "nativevillages_dancermale2",
		damage = "nativevillages_dancermale3",
		death = "nativevillages_dancermale4",
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
	follow = {"farming:turkish_delight", "farming:garlic_bread", "farming:donut", "farming:donut_chocolate", "farming:donut_apple", "farming:porridge", "farming:jaffa_cake", "farming:apple_pie", "farming:spaghetti", "farming:burger", "farming:bibimbap"},
	view_range = 15,
	owner = "singleplayer",
	order = "follow",
	fear_height = 3,
	animation = {
		speed_normal = 50,
		stand_start = 0,
		stand_end = 100,
		stand2_start = 100,
		stand2_end = 200,
		stand3_start = 200,
		stand3_end = 300,
		walk_start = 300,
		walk_end = 400,
                punch_speed = 100,
		punch_start = 400,
		punch_end = 500,
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

		-- right clicking with gold lump drops random item from mobs.npc_drops
		if item:get_name() == "default:gold_lump" then

			if not mobs.is_creative(name) then
				item:take_item()
				clicker:set_wielded_item(item)
			end

			local pos = self.object:get_pos()

			pos.y = pos.y + 0.5

			local drops = self.npc_drops or mobs.npc_drops

			minetest.add_item(pos, {
				name = drops[math.random(1, #drops)]
			})

			minetest.chat_send_player(name, ("NPC dropped you an item for gold!"))

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

				minetest.chat_send_player(name, ("Dancer will dance!."))
			else
				self.order = "follow"

				minetest.chat_send_player(name, ("Dancer will follow you."))
			end
		end
	end,
})


mobs:register_egg("nativevillages:slavemaledancer", ("Male Dancer"), "aslavemaledancer.png")