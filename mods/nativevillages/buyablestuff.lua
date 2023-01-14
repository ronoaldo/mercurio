local S = minetest.get_translator("nativevillages")

mobs:register_mob("nativevillages:tamecatfish", {
	stepheight = 1,
	type = "animal",
	passive = true,
	attack_type = "dogfight",
	group_attack = true,
	owner_loyal = true,
	attack_npcs = true,
	reach = 2,
	damage = 1,
	hp_min = 5,
	hp_max = 55,
	armor = 100,
	collisionbox = {-0.4, -0.01, -0.4, 0.4, 0.5, 0.4},
	visual = "mesh",
	mesh = "Lakecatfish.b3d",
	textures = {
		{"texturecatfish1.png"},
		{"texturecatfish2.png"},
		{"texturecatfish3.png"},
		{"texturecatfish4.png"},
		{"texturecatfish5.png"},
		{"texturecatfish6.png"},
	},
	makes_footstep_sound = true,
	sounds = {
	},
	walk_velocity = 1,
	run_velocity = 2,
	fly = true,
	fly_in = "default:water_source", "default:river_water_source", "default:water_flowing", "default:river_water_flowing",
	fall_speed = 0,
	jump = true,
	jump_height = 0,
	pushable = true,
        stay_near = {{"marinara:sand_with_alage", "marinara:sand_with_seagrass", "default:sand_with_kelp", "marinara:sand_with_kelp", "marinara:reed_root", "flowers:waterlily_waving", "naturalbiomes:waterlily", "default:clay"}, 5},
	follow = {
		"ethereal:worm", "seaweed", "fishing:bait_worm",
		"default:grass", "farming:cucumber", "farming:cabbage", "animalworld:ant", "animalworld:termite", "animalworld:fishfood", "animalworld:cockroach", "bees:frame_full", "animalworld:fishfood", "animalworld:ant", "animalworld:termite", "animalworld:bugice", "animalworld:termitequeen", "animalworld:notoptera", "animalworld:anteggs_raw", "group:grass", "group:normal_grass"
	},
	view_range = 6,
	drops = {
		{name = "nativevillages:catfish_raw", chance = 1, min = 1, max = 3},
	},
	water_damage = 0,
        air_damage = 1,
	lava_damage = 5,
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
		die_start = 0,
		die_end = 100,
		die_speed = 50,
		die_loop = false,
		die_rotate = true,
	},
	on_rightclick = function(self, clicker)

		if mobs:feed_tame(self, clicker, 8, true, true) then return end
		if mobs:protect(self, clicker) then return end
		if mobs:capture_mob(self, clicker, 15, 25, 0, false, nil) then return end
	end,
})



mobs:register_egg("nativevillages:tamecatfish", S("Domesticated Catfish"), "alakecatfish.png")


mobs:alias_mob("nativevillages:tamecatfish", "nativevillages:tamecatfish") -- compatibility


-- raw catfish
minetest.register_craftitem(":nativevillages:catfish_raw", {
	description = S("Raw Catfish"),
	inventory_image = "nativevillages_catfish_raw.png",
	on_use = minetest.item_eat(4),
	groups = {food_meat_raw = 1, flammable = 2},
})

-- cooked catfish
minetest.register_craftitem(":nativevillages:catfish_cooked", {
	description = S("Cooked Catfish"),
	inventory_image = "nativevillages_catfish_cooked.png",
	on_use = minetest.item_eat(8),
	groups = {food_meat = 1, flammable = 2},
})

minetest.register_craft({
	type = "cooking",
	output = "nativevillages:catfish_cooked",
	recipe = "nativevillages:catfish_raw",
	cooktime = 2,
})


local S = mobs.intllib

mobs:register_mob("nativevillages:zombietame", {
	type = "npc",
	passive = false,
	attack_type = "dogfight",
	group_attack = true,
	owner_loyal = true,
	attack_npcs = false,
	reach = 2,
	damage = 5,
	hp_min = 55,
	hp_max = 95,
	armor = 100,
	attacks_monsters = true,
	collisionbox = {-0.35,-1.0,-0.35, 0.35,0.8,0.35},
	visual = "mesh",
	mesh = "Zombie2.b3d",
	drawtype = "front",
	textures = {
		{"texturezombietame.png"},
	},
	makes_footstep_sound = true,
	sounds = {
		attack = "nativevillages_tamedzombie2",
		random = "nativevillages_tamedzombie",
		damage = "nativevillages_tamedzombie3",
		death = "nativevillages_tamedzombie4",
		distance = 10,
	},
	walk_velocity = 2,
	run_velocity = 3,
	jump = true,
	drops = {		
	},
        stay_near = {{"nativevillages:cannibalshrine", "nativevillages:driedpeople"}, 5},
	water_damage = 0,
	lava_damage = 2,
	light_damage = 0,
	follow = {"nativevillages:driedhumanmeat"},
	view_range = 20,
	owner = "",
	order = "follow",
	fear_height = 3,
	animation = {
		speed_normal = 60,
		stand_speed = 50,
		stand_start = 300,
		stand_end = 400,
		walk_start = 100,
		walk_end = 200,
		walk2_start = 200,
		walk2_end = 300,
		punch_start = 0,
		punch_end = 100,
		die_start = 0,
		die_end = 100,
		die_speed = 50,
		die_loop = false,
		die_rotate = true,
	},

	on_rightclick = function(self, clicker)

		-- feed to heal npc
		if mobs:feed_tame(self, clicker, 8, true, true) then return end

		-- capture npc with net or lasso
		if mobs:capture_mob(self, clicker, 15, 25, 0, false, nil) then return end

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

				minetest.chat_send_player(name, S("Zombie stands still."))
			else
				self.order = "follow"

				minetest.chat_send_player(name, S("Zombie will follow you."))
			end
		end
	end,
})


mobs:register_egg("nativevillages:zombietame", S("Tamed Zombie"), "azombietame.png" )

mobs:register_mob("nativevillages:domesticcow", {
	type = "animal",
	passive = false,
	attack_type = "dogfight",
	attack_npcs = false,
	group_attack = true,
	reach = 2,
	damage = 4,
	hp_min = 5,
	hp_max = 55,
	armor = 100,
	collisionbox = {-0.6, -0.01, -0.4, 0.6, 1.2, 0.4},
	visual = "mesh",
	mesh = "Grasslandcow.b3d",
	textures = {
		{"texturegrasslandcow.png"},
		{"texturegrasslandcow2.png"},
		{"texturegrasslandcow3.png"},
		{"texturegrasslandcow4.png"},
		{"texturegrasslandcow5.png"},
		{"texturegrasslandcow6.png"},
		{"texturegrasslandcow7.png"},
	},
	makes_footstep_sound = true,
	sounds = {
		random = "nativevillages_cow",
		attack = "nativevillages_cow2",
		damage = "nativevillages_cow3",
	},
	walk_velocity = 1,
	run_velocity = 2,
	jump = false,
	jump_height = 6,
        stay_near = {{"people:feeder", "marinara:reed_bundle", "naturalbiomes:reed_bundle", "farming:straw"}, 5},
	stepheight = 1,
	fear_height = 2,
	pushable = true,
        knock_back = false,
	drops = {
		{name = "mobs:meat_raw", chance = 1, min = 1, max = 3},
		{name = "mobs:leather", chance = 1, min = 0, max = 2},
	},
	water_damage = 0,
	lava_damage = 5,
	light_damage = 0,
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
	follow = {
		"farming:wheat", "default:grass_1", "farming:barley",
		"farming:oat", "farming:rye", "farming:carrot", "farming:beans", "farming:lettuce", "default:dry_grass_1", "default:dry_grass_2", "default:dry_grass_3", "default:grass_1", "default:grass_2", "default:grass_3", "default:grass_4", "default:grass_5", "default:marram_grass_1", "default:marram_grass_2", "default:marram_grass_3", "default:coldsteppe_grass_1", "default:coldsteppe_grass_2", "default:coldsteppe_grass_3", "default:coldsteppe_grass_4", "default:coldsteppe_grass_5", "default:coldsteppe_grass_6", "naturalbiomes:savanna_grass1", "naturalbiomes:savanna_grass2", "naturalbiomes:savanna_grass3", "naturalbiomes:outback_grass1", "naturalbiomes:outback_grass2", "naturalbiomes:outback_grass3", "naturalbiomes:outback_grass4", "naturalbiomes:outback_grass5", "naturalbiomes:outback_grass6", "naturalbiomes:med_grass1", "naturalbiomes:med_grass2", "naturalbiomes:heath_grass1", "naturalbiomes:heath_grass2", "naturalbiomes:heath_grass3", "naturalbiomes:alpine_grass1", "naturalbiomes:alpine_grass2", "naturalbiomes:heath_grass2", "naturalbiomes:heath_grass3", "naturalbiomes:", "naturalbiomes:", "naturalbiomes:bushland_grass", "naturalbiomes:bushland_grass2", "naturalbiomes:bushland_grass3", "naturalbiomes:bushland_grass4", "naturalbiomes:bushland_grass5", "naturalbiomes:bushland_grass6", "naturalbiomes:bushland_grass7", "group:grass", "group:normal_grass"
	},
	view_range = 8,
	replace_rate = 10,
	replace_what = {
		{"group:grass", "air", 0},
		{"default:dirt_with_grass", "default:dirt", -1}
	},
--	stay_near = {"farming:straw", "group:grass"}, 10},
	fear_height = 2,
	on_rightclick = function(self, clicker)

		-- feed or tame
		if mobs:feed_tame(self, clicker, 8, true, true) then

			-- if fed 7x wheat or grass then cow can be milked again
			if self.food and self.food > 6 then
				self.gotten = false
			end

			return
		end

		if mobs:protect(self, clicker) then return end
		if mobs:capture_mob(self, clicker, 0, 0, 25, false, nil) then return end

		local tool = clicker:get_wielded_item()
		local name = clicker:get_player_name()

		-- milk cow with empty bucket
		if tool:get_name() == "bucket:bucket_empty" then

			--if self.gotten == true
			if self.child == true then
				return
			end

			if self.gotten == true then
				minetest.chat_send_player(name,
					S("Cow already milked!"))
				return
			end

			local inv = clicker:get_inventory()

			tool:take_item()
			clicker:set_wielded_item(tool)

			if inv:room_for_item("main", {name = "nativevillages:bucket_milk"}) then
				clicker:get_inventory():add_item("main", "nativevillages:bucket_milk")
			else
				local pos = self.object:get_pos()
				pos.y = pos.y + 0.5
				minetest.add_item(pos, {name = "nativevillages:bucket_milk"})
			end

			self.gotten = true -- milked

			return
		end
	end,

	on_replace = function(self, pos, oldnode, newnode)

		self.food = (self.food or 0) + 1

		-- if cow replaces 8x grass then it can be milked again
		if self.food >= 8 then
			self.food = 0
			self.gotten = false
		end
	end,
})



mobs:register_egg("nativevillages:domesticcow", S("Domesticated Cow"), "agrasslandcow.png")


mobs:alias_mob("nativevillages:domesticcow", "nativevillages:domesticcow") -- compatibility


-- bucket of milk
minetest.register_craftitem(":nativevillages:bucket_milk", {
	description = S("Bucket of Milk"),
	inventory_image = "nativevillages_bucket_milk.png",
	stack_max = 1,
	on_use = minetest.item_eat(8, "bucket:bucket_empty"),
	groups = {food_milk = 1, flammable = 3, drink = 1},
})

-- glass of milk
minetest.register_craftitem(":mobs:glass_milk", {
	description = S("Glass of Milk"),
	inventory_image = "mobs_glass_milk.png",
	on_use = minetest.item_eat(2, "vessels:drinking_glass"),
	groups = {food_milk_glass = 1, flammable = 3, vessel = 1, drink = 1},
})

minetest.register_craft({
	type = "shapeless",
	output = "mobs:glass_milk 4",
	recipe = {
		"vessels:drinking_glass", "vessels:drinking_glass",
		"vessels:drinking_glass", "vessels:drinking_glass",
		"nativevillages:bucket_milk"
	},
	replacements = { {"nativevillages:bucket_milk", "bucket:bucket_empty"} }
})

minetest.register_craft({
	type = "shapeless",
	output = "nativevillages:bucket_milk",
	recipe = {
		"group:food_milk_glass", "group:food_milk_glass",
		"group:food_milk_glass", "group:food_milk_glass",
		"bucket:bucket_empty"
	},
	replacements = {
		{"group:food_milk_glass", "vessels:drinking_glass 4"},
	}
})


-- butter
minetest.register_craftitem(":nativevillages:butter", {
	description = S("Butter"),
	inventory_image = "nativevillages_butter.png",
	on_use = minetest.item_eat(1),
	groups = {food_butter = 1, flammable = 2},
})

if minetest.get_modpath("farming") and farming and farming.mod then
minetest.register_craft({
	type = "shapeless",
	output = "nativevillages:butter",
	recipe = {"nativevillages:bucket_milk", "farming:salt"},
	replacements = {{ "nativevillages:bucket_milk", "bucket:bucket_empty"}}
})
else -- some saplings are high in sodium so makes a good replacement item
minetest.register_craft({
	type = "shapeless",
	output = "nativevillages:butter",
	recipe = {"nativevillages:bucket_milk", "default:sapling"},
	replacements = {{ "nativevillages:bucket_milk", "bucket:bucket_empty"}}
})
end

-- cheese wedge
minetest.register_craftitem(":nativevillages:cheese", {
	description = S("Mozzarella Cheese"),
	inventory_image = "nativevillages_cheese.png",
	on_use = minetest.item_eat(4),
	groups = {food_cheese = 1, flammable = 2},
})

minetest.register_craft({
	type = "cooking",
	output = "nativevillages:cheese",
	recipe = "nativevillages:bucket_milk",
	cooktime = 5,
	replacements = {{ "nativevillages:bucket_milk", "bucket:bucket_empty"}}
})

-- cheese block
minetest.register_node(":nativevillages:cheeseblock", {
	description = S("Mozzarella Cheese Block"),
	tiles = {"nativevillages_cheeseblock.png"},
	is_ground_content = false,
	groups = {crumbly = 3},
	sounds = default.node_sound_dirt_defaults()
})

minetest.register_craft({
	output = "nativevillages:cheeseblock",
	recipe = {
		{"nativevillages:cheese", "nativevillages:cheese", "nativevillages:cheese"},
		{"nativevillages:cheese", "nativevillages:cheese", "nativevillages:cheese"},
		{"nativevillages:cheese", "nativevillages:cheese", "nativevillages:cheese"},
	}
})

minetest.register_craft({
	output = "nativevillages:cheese 9",
	recipe = {
		{"nativevillages:cheeseblock"},
	}
})

mobs:register_mob("nativevillages:desertchickentame", {
stepheight = 1,
	type = "animal",
	passive = true,
	attack_type = "dogfight",
	group_attack = false,
	owner_loyal = true,
	attack_npcs = false,
	reach = 2,
	damage = 1,
	hp_min = 10,
	hp_max = 25,
	armor = 100,
	collisionbox = {-0.4, -0.01, -0.3, 0.4, 0.8, 0.4},
	visual = "mesh",
	mesh = "Desertchicken.b3d",
	textures = {
		{"texturedesertchicken.png"}, 
		{"texturedesertchicken2.png"}, 
		{"texturedesertchicken3.png"}, 
		{"texturedesertchicken4.png"}, 

	},
	child_texture = {
		{"texturedesertchickenbaby.png"},
	},
	makes_footstep_sound = true,
	sounds = {
		random = "nativevillages_chicken",
		damage = "nativevillages_chicken2",
		death = "nativevillages_chicken3",
	},
	walk_velocity = 0.5,
	run_velocity = 3,
	runaway = true,
        runaway_from = {"animalworld:bear", "animalworld:crocodile", "animalworld:tiger", "animalworld:spider", "animalworld:spidermale", "animalworld:shark", "animalworld:hyena", "animalworld:kobra", "animalworld:monitor", "animalworld:snowleopard", "animalworld:volverine", "livingfloatlands:deinotherium", "livingfloatlands:carnotaurus", "livingfloatlands:lycaenops", "livingfloatlands:smilodon", "livingfloatlands:tyrannosaurus", "livingfloatlands:velociraptor", "animalworld:divingbeetle", "animalworld:scorpion"},
	drops = {
		{name = "nativevillages:chicken_raw", chance = 1, min = 1, max = 1},
	},
        stay_near = {{"people:feeder", "marinara:reed_bundle", "naturalbiomes:reed_bundle", "farming:straw"}, 5},
	water_damage = 1,
	lava_damage = 5,
	light_damage = 0,
	fear_height = 3,
	animation = {
		speed_normal = 75,
		stand_start = 0,
		stand_end = 100,
		stand2_start = 100,
		stand2_end = 200,
		walk_start = 200,
		walk_end = 300,
		die_start = 200,
		die_end = 300,
		die_speed = 50,
		die_loop = false,
		die_rotate = true,
	},
	follow = {
		"farming:seed_wheat", "farming:seed_cotton", "farming:seed_barley",
		"farming:seed_oat", "farming:seed_rye", "animalworld:cockroach", "bees:frame_full", "animalworld:fishfood", "animalworld:ant", "animalworld:termite", "animalworld:bugice", "animalworld:termitequeen", "animalworld:notoptera", "animalworld:anteggs_raw", "farming:corn_cob", "farming:seed_hemp", "farming:seed_barley", "farming:seed_oat", "farming:seed_cotton", "farming:seed_sunflower", "farming:seed_wheat", "farming:seed_rye", "naturalbiomes:coconut_slice", "naturalbiomes:hazelnut_cracked", "farming:sunflower_seeds_toasted", "livingfloatlands:roasted_pine_nuts", "livingfloatlands:coldsteppe_pine3_pinecone", "livingfloatlands:coldsteppe_pine_pinecone", "livingfloatlands:coldsteppe_pine2_pinecone"
	},
	view_range = 10,

	on_rightclick = function(self, clicker)

		if mobs:feed_tame(self, clicker, 8, true, true) then return end
		if mobs:protect(self, clicker) then return end
		if mobs:capture_mob(self, clicker, 15, 25, 0, false, nil) then return end
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


mobs:register_egg("nativevillages:desertchickentame", S("Domesticated Desert Chicken"), "adesertchicken.png", 0)

local S = mobs.intllib

mobs:register_mob("nativevillages:maleliontame", {
	type = "npc",
	passive = false,
	attack_type = "dogfight",
	group_attack = true,
	owner_loyal = true,
	attack_npcs = false,
        attack_monsters = true,
	reach = 2,
	damage = 10,
	hp_min = 45,
	hp_max = 115,
	armor = 100,
	collisionbox = {-0.5, -0.01, -0.5, 0.5, 0.95, 0.5},
	visual = "mesh",
	mesh = "Lionmale.b3d",
	drawtype = "front",
	textures = {
		{"texturelionmale.png"},
	},
	makes_footstep_sound = true,
	sounds = {
		attack = "nativevillages_lion2",
		random = "nativevillages_lion",
		damage = "nativevillages_lion4",
		death = "nativevillages_lion3",
		distance = 10,
	},
	walk_velocity = 2,
	run_velocity = 3,
	jump = true,
        stepheight = 2,
        fear_height = 3,
        stay_near = {{"nativevillages:savannacorpse", "mobs:meatblock"}, 5},
	drops = {		
	},
	water_damage = 0,
	lava_damage = 2,
	light_damage = 0,
follow = {
		"ethereal:fish_raw", "animalworld:rawfish", "mobs_fish:tropical",
		"mobs:meat_raw", "animalworld:rabbit_raw", "animalworld:pork_raw", "water_life:meat_raw", "animalworld:chicken_raw", "nativevillages:chicken_raw", "mobs:meatblock_raw", "animalworld:chicken_raw", "livingfloatlands:ornithischiaraw", "livingfloatlands:largemammalraw", "livingfloatlands:theropodraw", "livingfloatlands:sauropodraw", "animalworld:raw_athropod", "animalworld:whalemeat_raw", "animalworld:rabbit_raw", "nativevillages:chicken_raw", "mobs:meat_raw", "animalworld:pork_raw", "people:mutton:raw"
	},
	view_range = 15,
	owner = "",
	order = "follow",
	fear_height = 3,
	animation = {
speed_normal = 75,
		stand_start = 0,
		stand_end = 100,
		stand2_start = 100,
		stand2_end = 200,
		walk_start = 200,
		walk_end = 300,
                punch_speed = 100,
		punch_start = 300,
		punch_end = 400,
		die_start = 300,
		die_end = 400,
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



		-- by right-clicking owner can switch npc between follow and stand
		if self.owner and self.owner == name then

			if self.order == "follow" then

				self.attack = nil
				self.order = "stand"
				self.state = "stand"
				self:set_animation("stand")
				self:set_velocity(0)

				minetest.chat_send_player(name, S("Lion stands still."))
			else
				self.order = "follow"

				minetest.chat_send_player(name, S("Lion will follow you."))
			end
		end
	end,
})


mobs:register_egg("nativevillages:maleliontame", S("Tamed Male Lion"), "amalelion.png" )

local S = mobs.intllib

mobs:register_mob("nativevillages:femaleliontame", {
	type = "npc",
	passive = false,
	attack_type = "dogfight",
	group_attack = true,
	owner_loyal = true,
	attack_npcs = false,
        attack_monsters = true,
	reach = 2,
	damage = 7,
	hp_min = 45,
	hp_max = 75,
	armor = 100,
	collisionbox = {-0.5, -0.01, -0.5, 0.5, 0.95, 0.5},
	visual = "mesh",
	mesh = "Lionfemale.b3d",
	drawtype = "front",
	textures = {
		{"texturelionfemale.png"},
	},
	makes_footstep_sound = true,
	sounds = {
		attack = "nativevillages_lion2",
		random = "nativevillages_lion",
		damage = "nativevillages_lion4",
		death = "nativevillages_lion3",
		distance = 10,
	},
	walk_velocity = 2,
	run_velocity = 3,
	jump = true,
	drops = {		
	},
        stay_near = {{"nativevillages:savannacorpse", "mobs:meatblock"}, 5},
	water_damage = 0,
	lava_damage = 2,
	light_damage = 0,
        stepheight = 2,
        fear_height = 3,
follow = {
		"ethereal:fish_raw", "animalworld:rawfish", "mobs_fish:tropical",
		"mobs:meat_raw", "animalworld:rabbit_raw", "animalworld:pork_raw", "water_life:meat_raw", "animalworld:chicken_raw", "nativevillages:chicken_raw", "mobs:meatblock_raw", "animalworld:chicken_raw", "livingfloatlands:ornithischiaraw", "livingfloatlands:largemammalraw", "livingfloatlands:theropodraw", "livingfloatlands:sauropodraw", "animalworld:raw_athropod", "animalworld:whalemeat_raw", "animalworld:rabbit_raw", "nativevillages:chicken_raw", "mobs:meat_raw", "animalworld:pork_raw", "people:mutton:raw"
	},
	view_range = 15,
	owner = "",
	order = "follow",
	fear_height = 3,
	animation = {
speed_normal = 75,
		stand_start = 0,
		stand_end = 100,
		stand2_start = 100,
		stand2_end = 200,
		walk_start = 200,
		walk_end = 300,
                punch_speed = 100,
		punch_start = 300,
		punch_end = 400,
		die_start = 300,
		die_end = 400,
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



		-- by right-clicking owner can switch npc between follow and stand
		if self.owner and self.owner == name then

			if self.order == "follow" then

				self.attack = nil
				self.order = "stand"
				self.state = "stand"
				self:set_animation("stand")
				self:set_velocity(0)

				minetest.chat_send_player(name, S("Lion stands still."))
			else
				self.order = "follow"

				minetest.chat_send_player(name, S("Lion will follow you."))
			end
		end
	end,
})


mobs:register_egg("nativevillages:femaleliontame", S("Tamed Female Lion"), "afemalelion.png" )

mobs:register_mob("nativevillages:grasslandcat", {
	stay_near = {"singleplayer", 10},
	type = "animal",
	visual = "mesh",
	mesh = "Grasslandcat.b3d",
	collisionbox = {-0.4, -0.01, -0.4, 0.4, 0.5, 0.4},
	animation = {
		speed_normal = 100,
		stand_speed = 50,
		stand_start = 0,
		stand_end = 100,
		stand2_speed = 50,
		stand2_start = 100,
		stand2_end = 200,
		stand3_speed = 50,
		stand3_start = 200,
		stand3_end = 300,
		stand4_speed = 50,
		stand4_start = 0,
		stand4_end = 100,
		stand5_speed = 50,
		stand5_start = 200,
		stand5_end = 300,
		walk_start = 300,
		walk_end = 400,
		punch_start = 400,
		punch_end = 500,
		die_start = 400,
		die_end = 500,
		die_speed = 50,
		die_loop = false,
		die_rotate = true,
	},
	textures = {
		{"texturegrasslandcat.png"},
		{"texturegrasslandcat2.png"},
		{"texturegrasslandcat3.png"},
		{"texturegrasslandcat4.png"},
		{"texturegrasslandcat5.png"},
	},
	fear_height = 5,
        stepheight = 2,
	runaway = false,
	jump = true,
	jump_height = 8,
        stay_near = {{"people:villagerbed", "mobs:meatblock", "animalworld:blackbirdpillow", "animalworld:hyenapillow", "animalworld:monitorstool", "animalworld:owltrophy", "animalworld:vulturepillow", "animalworld:snowleopardpillow", "animalworld:tigerpillow", "animalworld:tigerstool", "chair"}, 5},
	fly = false,
	walk_velocity = 2,
        walk_chance = 15,
	run_velocity = 3,
	view_range = 12,
	passive = false,
	attack_type = "dogfight",
	damage = 4,
	reach = 2,
	attack_monsters = true,
	attack_animals = false,
	attack_npcs = false,
	pathfinding = true,
	group_attack = true,
	hp_min = 25,
	hp_max = 75,
	armor = 100,
	knock_back = 2,
	lava_damage = 5,
	fall_damage = 1,
	water_damage = 1,
	makes_footstep_sound = true,
	sounds = {
		attack = "nativevillages_cat",
		random = "nativevillages_cat2",
		damage = "nativevillages_cat3",
		death = "nativevillages_cat4",
		distance = 10,
	},
	follow = {"ethereal:fish_raw", "animalworld:rawfish", "mobs_fish:tropical",
		"mobs:meat_raw", "animalworld:rabbit_raw", "xocean:fish_edible", "fishing:fish_raw", "water_life:meat_raw", "fishing:carp_raw", "animalworld:chicken_raw", "nativevillages:chicken_raw", "nativevillages:chicken_cooked", "nativevillages:catfish_raw", "nativevillages:catfish_cooked", "fishing:fish_cooked", "marinaramobs:cooked_exotic_fish", "animalworld:cookedfish", "marinara:mussels", "nativevillages:catfish_cooked", "fishing:pike_cooked", "animalworld:cooked_athropod", "livingfloatlands:theropodcooked", "mobs:meatblock", "animalworld:whelaemeat_cooked", "animalworld:rat_cooked", "mobs:meat", "animalworld:chicken_cooked", "livingfloatlands:sauropodcooked", "livingfloatlands:ornithischiacooked", "nativevillages:driedhumanmeat", "livingfloatlands:largemammalcooked", "pie:meat"},
	on_rightclick = function(self, clicker)
		if mobs:feed_tame(self, clicker, 6, true, true) then return end
		if mobs:protect(self, clicker) then return end
		if mobs:capture_mob(self, clicker, 0, 25, 0, false, nil) then return end

		if clicker:get_wielded_item():is_empty() and clicker:get_player_name() == self.owner then
			if clicker:get_player_control().sneak then
				self.order = ""
				self.state = "walk"
				self.walk_velocity = 2
				self.stepheight = 2
			else
				if self.order == "follow" then
					self.order = "stand"
					self.state = "stand"
					self.walk_velocity = 2
					self.stepheight = 2
				else
					self.order = "follow"
					self.state = "walk"
					self.walk_velocity = 3
					self.stepheight = 2
				end
			end
			return
		end
	end
})

mobs:register_egg("nativevillages:grasslandcat", S"Cat", "agrasslandcat.png")

