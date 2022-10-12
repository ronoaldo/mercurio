mobs.desertvillagermale_drops = {
	"farming:salt"
}

mobs:register_mob("nativevillages:desertvillagermale", {
	type = "monster",
	passive = false,
	damage = 2,
	attack_type = "dogfight",
	attacks_monsters = false,
	attack_npcs = true,
	owner_loyal = true,
	pathfinding = true,
	hp_min = 30,
	hp_max = 60,
	armor = 100,
	collisionbox = {-0.35,-1.0,-0.35, 0.35,0.8,0.35},
	visual = "mesh",
	mesh = "Desertvillagermale.b3d",
	drawtype = "front",
	textures = {
		{"texturedesertvillagermale.png"},
		{"texturedesertvillagermale2.png"},
		{"texturedesertvillagermale3.png"},
		{"texturedesertvillagermale4.png"},

	},
	makes_footstep_sound = true,
sounds = {
		attack = "nativevillages_desertmale2",
		random = "nativevillages_desertmale",
		damage = "nativevillages_desertmale4",
		death = "nativevillages_desertmaledesertmale3",
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
        stay_near = "nativevillages:desertcrpet",
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

		-- right clicking with gold lump drops random item from mobs.desertvillagermale_drops
		if item:get_name() == "default:stick" then

			if not mobs.is_creative(name) then
				item:take_item()
				clicker:set_wielded_item(item)
			end

			local pos = self.object:get_pos()

			pos.y = pos.y + 0.5

			local drops = self.npc_drops or mobs.desertvillagermale_drops

			minetest.add_item(pos, {
				name = drops[math.random(1, #drops)]
			})

			minetest.chat_send_player(name, ("Desert Villager dropped you an item for a stick!"))

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

				minetest.chat_send_player(name, ("Desert Villager stands still."))
			else
				self.order = "follow"

				minetest.chat_send_player(name, ("Desert Villager will follow you."))
			end
		end
	end,
})

if not mobs.custom_spawn_nativevillages then
mobs:spawn({
	name = "nativevillages:desertvillagermale",
	nodes = {"default:desert_sand", "group:wool"},
	neighbors = {"nativevillages:desertcrpet"},
	min_light = 0,
	interval = 60,
	active_object_count = 2,
	chance = 1, -- 15000
	min_height = 0,
	max_height = 120,
})
end

mobs:register_egg("nativevillages:desertvillagermale", ("Male Desert Villager"), "adesertvillagermale.png")

mobs.desertvillagerfemale_drops = {
	"farming:salt"
}

mobs:register_mob("nativevillages:desertvillagerfemale", {
	type = "monster",
	passive = false,
	damage = 1,
	attack_type = "dogfight",
	attacks_monsters = false,
	attack_npcs = true,
	owner_loyal = true,
	pathfinding = true,
	hp_min = 20,
	hp_max = 40,
	armor = 100,
	collisionbox = {-0.35,-1.0,-0.35, 0.35,0.8,0.35},
	visual = "mesh",
	mesh = "Desertvillagerfemale.b3d",
	drawtype = "front",
	textures = {
		{"texturedesertvillagerfemale.png"},
		{"texturedesertvillagerfemale2.png"},
		{"texturedesertvillagerfemale3.png"},
		{"texturedesertvillagerfemale4.png"},
		{"texturedesertvillagerfemale5.png"},
		{"texturedesertvillagerfemale6.png"},

	},
	makes_footstep_sound = true,
sounds = {
		attack = "nativevillages_desertfemale2",
		random = "nativevillages_desertfemale",
		damage = "nativevillages_desertfemale4",
		death = "nativevillages_desertfemale3",
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
        stay_near = "nativevillages:desertcrpet",
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

		-- right clicking with gold lump drops random item from mobs.desertvillagerfemale_drops
		if item:get_name() == "default:stick" then

			if not mobs.is_creative(name) then
				item:take_item()
				clicker:set_wielded_item(item)
			end

			local pos = self.object:get_pos()

			pos.y = pos.y + 0.5

			local drops = self.npc_drops or mobs.desertvillagerfemale_drops

			minetest.add_item(pos, {
				name = drops[math.random(1, #drops)]
			})

			minetest.chat_send_player(name, ("Desert Villager dropped you an item for a stick!"))

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

				minetest.chat_send_player(name, ("Desert Villager stands still."))
			else
				self.order = "follow"

				minetest.chat_send_player(name, ("Desert will follow you."))
			end
		end
	end,
})

if not mobs.custom_spawn_nativevillages then
mobs:spawn({
	name = "nativevillages:desertvillagerfemale",
	nodes = {"default:desert_sand", "group:wool"},
	neighbors = {"nativevillages:desertcrpet"},
	min_light = 0,
	interval = 60,
	active_object_count = 2,
	chance = 1, -- 15000
	min_height = 0,
	max_height = 120,
})
end

mobs:register_egg("nativevillages:desertvillagerfemale", ("Female Desert Villager"), "adesertvillagerfemale.png")

mobs.desertslavetrader_drops = {
	"nativevillages:slavechickenbreeder", "nativevillages:slavecowherder", "nativevillages:slaveliontrainer",
	"nativevillages:slavefemaledancer", "nativevillages:slaveloyalcannibal", "nativevillages:slavemaledancer"
}

mobs:register_mob("nativevillages:desertslavetrader", {
	type = "npc",
	passive = false,
	damage = 5,
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
	mesh = "Desertslavetrader.b3d",
	drawtype = "front",
	textures = {
		{"texturedesertslavetrader.png"},

	},
	makes_footstep_sound = true,
sounds = {
		attack = "nativevillages_desertmale2",
		random = "nativevillages_desertmale",
		damage = "nativevillages_desertmale4",
		death = "nativevillages_desertmale3",
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
        stay_near = "nativevillages:desertcage",
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

		-- right clicking with gold lump drops random item from mobs.desertslavetrader_drops
		if item:get_name() == "default:gold_ingot" then

			if not mobs.is_creative(name) then
				item:take_item()
				clicker:set_wielded_item(item)
			end

			local pos = self.object:get_pos()

			pos.y = pos.y + 0.5

			local drops = self.npc_drops or mobs.desertslavetrader_drops

			minetest.add_item(pos, {
				name = drops[math.random(1, #drops)]
			})

			minetest.chat_send_player(name, ("Slave delivered!"))

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

				minetest.chat_send_player(name, ("Slavetrader stands still."))
			else
				self.order = "follow"

				minetest.chat_send_player(name, ("Slavetrader will follow you."))
			end
		end
	end,
})

if not mobs.custom_spawn_nativevillages then
mobs:spawn({
	name = "nativevillages:desertslavetrader",
	nodes = {"default:desert_sand", "group:wool"},
	neighbors = {"nativevillages:desertcage"},
	min_light = 0,
	interval = 60,
	active_object_count = 1,
	chance = 1, -- 15000
	min_height = 0,
	max_height = 120,
})
end

mobs:register_egg("nativevillages:desertslavetrader", ("Slave Trader"), "adesertslavetrader.png")

mobs:register_mob("nativevillages:desertranger", {
	type = "monster",
	passive = false,
	damage = 7,
        raeach = 4,
	attack_type = "dogfight",
	attacks_monsters = false,
	attack_npcs = true,
        attack_player = true,
	owner_loyal = true,
	pathfinding = true,
	hp_min = 50,
	hp_max = 85,
	armor = 100,
	collisionbox = {-0.35,-1.0,-0.35, 0.35,0.8,0.35},
	visual = "mesh",
	mesh = "Desertranger.b3d",
	drawtype = "front",
	textures = {
		{"texturedesertranger.png"},

	},
	makes_footstep_sound = true,
sounds = {
		attack = "nativevillages_desertmale2",
		random = "nativevillages_desertmale",
		damage = "nativevillages_desertmale4",
		death = "nativevillages_desertmaledesertmale3",
		distance = 10,
	},
	walk_velocity = 2,
        walk_chance = 15,
	run_velocity = 3,
	jump = true,
	drops = {
		{name = "default:apple", chance = 2, min = 1, max = 2},
		{name = "default:sword_stone", chance = 5, min = 1, max = 1},
	},
	water_damage = 0,
	lava_damage = 2,
	light_damage = 0,
	follow = {},
        stay_near = "nativevillages:hookah",
	view_range = 15,
	owner = "",
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

		if mobs:feed_tame(self, clicker, 8, true, true) then return end
		if mobs:protect(self, clicker) then return end
		if mobs:capture_mob(self, clicker, 0, 5, 50, false, nil) then return end
	end,
})

if not mobs.custom_spawn_nativevillages then
mobs:spawn({
	name = "nativevillages:desertranger",
	nodes = {"default:desert_sand", "group:wool"},
	neighbors = {"nativevillages:hookah"},
	min_light = 0,
	interval = 60,
	active_object_count = 2,
	chance = 1, -- 15000
	min_height = 0,
	max_height = 120,
})
end

mobs:register_egg("nativevillages:desertranger", ("Desert Ranger"), "adesertranger.png")


mobs:register_mob("nativevillages:desertraider", {
	type = "monster",
	passive = false,
	damage = 7,
	attack_type = "dogfight",
	attacks_monsters = false,
	attack_npcs = true,
	owner_loyal = true,
	pathfinding = true,
	hp_min = 50,
	hp_max = 100,
	armor = 100,
	collisionbox = {-0.35,-1.0,-0.35, 0.35,0.8,0.35},
	visual = "mesh",
	mesh = "Desertraider.b3d",
	drawtype = "front",
	textures = {
		{"texturedesertraider.png"},

	},
	makes_footstep_sound = true,
sounds = {
		attack = "nativevillages_desertmale2",
		random = "nativevillages_desertmale",
		damage = "nativevillages_desertmale4",
		death = "nativevillages_desertmale3",
		distance = 10,
	},
	walk_velocity = 1,
        walk_chance = 15,
	run_velocity = 3,
	jump = true,
	drops = {
		{name = "default:apple", chance = 2, min = 1, max = 2},
		{name = "default:sword_stone", chance = 5, min = 1, max = 1},
	},
	water_damage = 0,
	lava_damage = 2,
	light_damage = 0,
	follow = {},
        stay_near = "nativevillages:hookah",
	view_range = 15,
	owner = "",
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

		if mobs:feed_tame(self, clicker, 8, true, true) then return end
		if mobs:protect(self, clicker) then return end
		if mobs:capture_mob(self, clicker, 0, 5, 50, false, nil) then return end
	end,
})

if not mobs.custom_spawn_nativevillages then
mobs:spawn({
	name = "nativevillages:desertraider",
	nodes = {"default:desert_sand", "group:wool"},
	neighbors = {"nativevillages:hookah"},
	min_light = 0,
	interval = 60,
	active_object_count = 2,
	chance = 1, -- 15000
	min_height = 0,
	max_height = 120,
})
end

mobs:register_egg("nativevillages:desertraider", ("Desert Raider"), "adesertraider.png")

mobs:register_mob("nativevillages:desertchicken", {
stepheight = 1,
	type = "animal",
	passive = false,
	attack_type = "dogfight",
	group_attack = true,
	owner_loyal = true,
	attack_npcs = false,
	reach = 2,
	damage = 3,
	hp_min = 10,
	hp_max = 20,
	armor = 100,
	collisionbox = {-0.4, -0.01, -0.3, 0.4, 0.8, 0.4},
	visual = "mesh",
	mesh = "Desertchicken.b3d",
	textures = {
		{"texturedesertchicken.png"}, 

	},
	child_texture = {
		{"desertchicken.png"},
	},
	makes_footstep_sound = true,
	sounds = {
		random = "nativevillages_chicken",
		damage = "nativevillages_chicken2",
		death = "nativevillages_chicken3",
	},
	walk_velocity = 1,
	run_velocity = 3,
	runaway = true,
        runaway_from = {"animalworld:bear", "animalworld:crocodile", "animalworld:tiger", "animalworld:spider", "animalworld:spidermale", "animalworld:shark", "animalworld:hyena", "animalworld:kobra", "animalworld:monitor", "animalworld:snowleopard", "animalworld:volverine", "livingfloatlands:deinotherium", "livingfloatlands:carnotaurus", "livingfloatlands:lycaenops", "livingfloatlands:smilodon", "livingfloatlands:tyrannosaurus", "livingfloatlands:velociraptor", "animalworld:divingbeetle", "animalworld:scorpion"},
	drops = {
	},
	water_damage = 1,
	lava_damage = 5,
	light_damage = 0,
	fear_height = 3,
	animation = {
		speed_normal = 100,
		stand_start = 0,
		stand_end = 100,
		stand2_start = 100,
		stand2_end = 200,
		walk_start = 200,
		walk_end = 300,

	},
	follow = {},
	view_range = 10,

	on_rightclick = function(self, clicker)

		if mobs:feed_tame(self, clicker, 8, true, true) then return end
		if mobs:protect(self, clicker) then return end
		if mobs:capture_mob(self, clicker, 30, 50, 80, false, nil) then return end
	end,

	do_custom = function(self, dtime)

		self.egg_timer = (self.egg_timer or 0) + dtime
		if self.egg_timer < 10 then
			return
		end
		self.egg_timer = 0

		if self.child
		or math.random(1, 100) > 1 then
			return
		end

		local pos = self.object:get_pos()

		minetest.add_item(pos, "mobs:egg")

		minetest.sound_play("default_place_node_hard", {
			pos = pos,
			gain = 1.0,
			max_hear_distance = 5,
		})
	end,
})


if not mobs.custom_spawn_nativevillages then
mobs:spawn({
	name = "nativevillages:desertchicken",
	nodes = {"default:clay", "default:desert_sand"}, 
	neighbors = {"nativevillages:desertseeds"},
	min_light = 0,
	interval = 60,
	chance = 1, -- 15000
	active_object_count = 3,
	min_height = 0,
	max_height = 100,
})
end


mobs:register_egg("nativevillages:desertchicken", ("Desert Chicken"), "adesertchicken.png", 0)




-- egg entity

mobs:register_arrow("nativevillages:egg_entity", {
	visual = "sprite",
	visual_size = {x=.5, y=.5},
	textures = {"mobs_chicken_egg.png"},
	velocity = 6,

	hit_player = function(self, player)
		player:punch(minetest.get_player_by_name(self.playername) or self.object, 1.0, {
			full_punch_interval = 1.0,
			damage_groups = {fleshy = 1},
		}, nil)
	end,

	hit_mob = function(self, player)
		player:punch(minetest.get_player_by_name(self.playername) or self.object, 1.0, {
			full_punch_interval = 1.0,
			damage_groups = {fleshy = 1},
		}, nil)
	end,

	hit_node = function(self, pos, node)

		if math.random(1, 10) > 1 then
			return
		end

		pos.y = pos.y + 1

		local nod = minetest.get_node_or_nil(pos)

		if not nod
		or not minetest.registered_nodes[nod.name]
		or minetest.registered_nodes[nod.name].walkable == true then
			return
		end

		local mob = minetest.add_entity(pos, "nativevillages:desertchicken")
		local ent2 = mob:get_luaentity()

		mob:set_properties({
			textures = ent2.child_texture[1],
			visual_size = {
				x = ent2.base_size.x / 2,
				y = ent2.base_size.y / 2
			},
			collisionbox = {
				ent2.base_colbox[1] / 2,
				ent2.base_colbox[2] / 2,
				ent2.base_colbox[3] / 2,
				ent2.base_colbox[4] / 2,
				ent2.base_colbox[5] / 2,
				ent2.base_colbox[6] / 2
			},
		})

		ent2.child = true
		ent2.tamed = true
		ent2.owner = self.playername
	end
})


-- egg throwing item

local egg_GRAVITY = 9
local egg_VELOCITY = 19

-- shoot egg
local mobs_shoot_egg = function (item, player, pointed_thing)

	local playerpos = player:get_pos()

	minetest.sound_play("default_place_node_hard", {
		pos = playerpos,
		gain = 1.0,
		max_hear_distance = 5,
	})

	local obj = minetest.add_entity({
		x = playerpos.x,
		y = playerpos.y +1.5,
		z = playerpos.z
	}, "nativevillages:egg_entity")

	local ent = obj:get_luaentity()
	local dir = player:get_look_dir()

	ent.velocity = egg_VELOCITY -- needed for api internal timing
	ent.switch = 1 -- needed so that egg doesn't despawn straight away

	obj:setvelocity({
		x = dir.x * egg_VELOCITY,
		y = dir.y * egg_VELOCITY,
		z = dir.z * egg_VELOCITY
	})

	obj:setacceleration({
		x = dir.x * -3,
		y = -egg_GRAVITY,
		z = dir.z * -3
	})

	-- pass player name to egg for chick ownership
	local ent2 = obj:get_luaentity()
	ent2.playername = player:get_player_name()

	item:take_item()

	return item
end


-- egg
minetest.register_node(":nativevillages:egg", {
	description = ("Bird Egg"),
	tiles = {"mobs_chicken_egg.png"},
	inventory_image  = "mobs_chicken_egg.png",
	visual_scale = 0.7,
	drawtype = "plantlike",
	wield_image = "mobs_chicken_egg.png",
	paramtype = "light",
	walkable = false,
	is_ground_content = true,
	sunlight_propagates = true,
	selection_box = {
		type = "fixed",
		fixed = {-0.2, -0.5, -0.2, 0.2, 0, 0.2}
	},
	groups = {food_egg = 1, snappy = 2, dig_immediate = 3},
	after_place_node = function(pos, placer, itemstack)
		if placer:is_player() then
			minetest.set_node(pos, {name = "nativevillages:egg", param2 = 1})
		end
	end,
	on_use = mobs_shoot_egg
})


-- fried egg
minetest.register_craftitem(":nativevillages:chicken_egg_fried", {
	description = ("Fried Desert Chicken Egg"),
	inventory_image = "nativevillages_chicken_egg_fried.png",
	on_use = minetest.item_eat(2),
	groups = {food_egg_fried = 1, flammable = 2},
})

minetest.register_craft({
	type  =  "cooking",
	recipe  = "nativevillages:egg",
	output = "nativevillages:chicken_egg_fried",
})

-- raw chicken
minetest.register_craftitem(":nativevillages:chicken_raw", {
description = ("Raw Desert Chicken meat"),
	inventory_image = "nativevillages_chicken_raw.png",
	on_use = minetest.item_eat(2),
	groups = {food_meat_raw = 1, food_chicken_raw = 1, flammable = 2},
})

-- cooked chicken
minetest.register_craftitem(":nativevillages:chicken_cooked", {
description = ("Cooked Desert Chicken"),
	inventory_image = "nativevillages_chicken_cooked.png",
	on_use = minetest.item_eat(6),
	groups = {food_meat = 1, food_chicken = 1, flammable = 2},
})

minetest.register_craft({
	type  =  "cooking",
	recipe  = "nativevillages:chicken_raw",
	output = "nativevillages:chicken_cooked",
})


