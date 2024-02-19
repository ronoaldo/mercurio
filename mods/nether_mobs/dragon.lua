local scale = "nether_mobs:dragon_scale"

blacklist = { -- this nodes can't be destroyed by the nether dragon fire
	"default:obsidian",
	"default:obsidian_block",
	"default:obsidianbrick",
	"stairs:slab_obsidian",
	"stairs:slab_obsidian_block",
	"stairs:slab_obsidianbrick",
	"stairs:stair_obsidian",
	"stairs:stair_obsidian_block",
	"stairs:stair_obsidianbrick",
	"nether:portal",
}

local S = minetest.get_translator("nether_mobs")

-- Dragon Scale

minetest.register_node("nether_mobs:dragon_scale_block", {
	description = "nether dragon scale block",
	tiles = {"nether_dragon_scale_block_top.png", "nether_dragon_scale_block_top.png", "nether_dragon_scale_block.png"},
	paramtype = "facedir",
	is_ground_content = false,
	groups = {cracky = 1, level = 3},
	sounds = default.node_sound_stone_defaults(),

	on_place = minetest.rotate_node
})

stairs.register_stair_and_slab(
	"nether_dragon_scale_block",
	"nether_mobs:dragon_scale_block",
	{cracky = 1, level = 3},
	{"nether_dragon_scale_block.png"},
	"nether dragon scale stair",
	"nether dragon scale slab",
	default.node_sound_stone_defaults()
)

minetest.register_craft({
        output = "stairs:slab_nether_dragon_scale_block",
        recipe = {
            {scale, scale},
        }
    })

minetest.register_craft({
        output = "stairs:stair_nether_dragon_scale_block",
        recipe = {
            {"", scale},
	    {scale, scale},
        }
    })

minetest.register_craftitem("nether_mobs:dragon_scale", {
	description = "nether dragon scale",
	inventory_image = "nether_dragon_scale.png",
})

minetest.register_craft({
        output = "nether_mobs:dragon_scale_block",
        recipe = {
            {scale, scale},
            {scale, scale},
        }
    })

minetest.register_craft({
				output = "nether_mobs:dragon_scale 4",
				recipe = {
					{"nether_mobs:dragon_scale_block"},
				}
		})

-- Dragon Scales Armor

if minetest.get_modpath("3d_armor") then
    armor:register_armor("nether_mobs:dragon_helmet", {
        description = S("dragon scales helmet"),
        inventory_image = "nether_dragon_inv_helmet.png",
        groups = {armor_head=1, armor_heal=15, armor_use=100, armor_fire=1},
        armor_groups = {fleshy=15},
        damage_groups = {cracky=2, snappy=1, level=3},
        wear = 0,
    })

    armor:register_armor("nether_mobs:dragon_chestplate", {
        description = S("dragon scales chestplate"),
        inventory_image = "nether_dragon_inv_chestplate.png",
        groups = {armor_torso=1, armor_heal=15, armor_use=100, armor_fire=1},
        armor_groups = {fleshy=20},
        damage_groups = {cracky=2, snappy=1, level=3},
        wear = 0,
    })

    armor:register_armor("nether_mobs:dragon_leggings", {
        description = S("dragon scales leggings"),
        inventory_image = "nether_dragon_inv_leggings.png",
        groups = {armor_legs=1, armor_heal=15, armor_use=100, armor_fire=1},
        armor_groups = {fleshy=20},
        damage_groups = {cracky=2, snappy=1, level=3},
        wear = 0,
    })

    armor:register_armor("nether_mobs:dragon_boots", {
        description = S("dragon scales boots"),
        inventory_image = "nether_dragon_inv_boots.png",
        groups = {armor_feet=1, armor_heal=15, armor_use=100, armor_fire=1, physics_jump=0.5, physics_speed = 1},
        armor_groups = {fleshy=15},
	damage_groups = {cracky=2, snappy=1, level=3},
        wear = 0,
    })

    armor:register_armor("nether_mobs:dragon_shield", {
        description = S("dragon scales shield"),
        inventory_image = "nether_dragon_inven_shield.png",
        groups = {armor_shield=1, armor_heal=15, armor_use=100, armor_fire=2},
        armor_groups = {fleshy=20},
        damage_groups = {cracky=2, snappy=1, level=3},
        wear = 0,
    })
end


if minetest.get_modpath("3d_armor") then
    minetest.register_craft({
        output = "nether_mobs:dragon_helmet",
        recipe = {
            {scale, scale, scale},
            {scale, "", scale},
            {"", "", ""},
        }
    })

    minetest.register_craft({
        output = "nether_mobs:dragon_chestplate",
        recipe = {
            {scale, "", scale},
            {scale, scale, scale},
            {scale, scale, scale},
        }
    })

    minetest.register_craft({
        output = "nether_mobs:dragon_leggings",
        recipe = {
            {scale, scale, scale},
            {scale, "", scale},
            {scale, "", scale},
        }
    })

    minetest.register_craft({
        output = "nether_mobs:dragon_boots",
        recipe = {
            {scale, "", scale},
            {scale, "", scale},
        }
    })

    minetest.register_craft({
        output = "nether_mobs:dragon_shield",
        recipe = {
            {scale, scale, scale},
            {scale, scale, scale},
            {"", scale, ""},
        }
    })
end

-- Dragon Fire

minetest.register_node("nether_mobs:dragon_fire", {
	description = "nether dragon fire",
	drawtype = "firelike",
	tiles = {{
		name = "nether_dragon_fire_animated.png",
		animation = {type = "vertical_frames",
			aspect_w = 16, aspect_h = 16, length = 1},
	}},
	inventory_image = "nether_dragon_fire.png",
	light_source = 15,
	groups = {igniter = 3, snappy=1},
	drop = '',
	walkable = false,
	buildable_to = false,
	damage_per_second = 8,
	on_construct = function(pos)
		minetest.get_node_timer(pos):start(math.min(10), math.max(10))
	end,
	on_timer = function(pos)
		local f = minetest.find_node_near(pos, 1, {"group:flammable"})
		if not fire_enabled or not f then
			minetest.remove_node(pos)
			return
		end
		return true
	end,
})

minetest.register_node(":nether_mobs:permanent_dragon_fire", { --only avaible in creative mode
	description = "Permanent nether dragon fire",
	drawtype = "firelike",
	tiles = {{
		name = "nether_dragon_fire_animated.png",
		animation = {type = "vertical_frames",
			aspect_w = 16, aspect_h = 16, length = 1},
	}},
	inventory_image = "nether_dragon_fire.png",
	light_source = 15,
	groups = {snappy=1},
	walkable = false,
	buildable_to = false,
	damage_per_second = 8,
})


-- Fire Breathing

function fire_breath(pos)
	for i=pos.x-math.random(0, 1), pos.x+math.random(0, 1), 1 do
		for j=pos.y-1, pos.y+2, 1 do
			for k=pos.z-math.random(0, 1), pos.z+math.random(0, 1), 1 do
				local p = {x=i, y=j, z=k}
				local n = minetest.env:get_node(p).name
				if minetest.get_item_group(n, "unbreakable") == 1 or minetest.is_protected(p, "") then
				else
					minetest.set_node({x=i, y=j, z=k}, {name="nether_mobs:dragon_fire"})
				end
			end
		end
	end
end


mobs:register_arrow("nether_mobs:dragon_breath", {
	visual = "sprite",
	visual_size = {x = 1, y = 1},
	textures = {"nether_dragon_fire.png"},
	collisionbox = {-0.1, -0.1, -0.1, 0.1, 0.1, 0.1},
	velocity = 7,
	tail = 1,
	tail_texture = "nether_dragon_fire.png",
	tail_size = 10,
	glow = 5,
	expire = 0.1,

	on_activate = function(self, staticdata, dtime_s)
		self.object:set_armor_groups({immortal = 1, fleshy = 100})
	end,

	hit_player = function(self, player)
		player:punch(self.object, 1.0, {
			full_punch_interval = 1.0,
			damage_groups = {fleshy = 18},
		}, nil)
	end,

	hit_mob = function(self, player)
		player:punch(self.object, 1.0, {
			full_punch_interval = 1.0,
			damage_groups = {fleshy = 28},
		}, nil)
	end,

	-- node hit
	hit_node = function(self, pos, node)
		pos.y = pos.y + 0.5
		mobs:effect(pos, 30, "nether_particle.png", 0.1, 2, 3, 5)
		pos.y = pos.y + 0.25
		mobs:effect(pos, 30, "nether_particle.png", 0.1, 2, 3, 5)
		for _, blacknode in ipairs(blacklist) do
			if blacknode == node then
				pos.y = pos.y + 1
				fire_breath(pos)
			else
				mobs:boom(self, pos, 1)
				fire_breath(pos)
			end
		end
	end
})

-- Walking and Flying animation sets

local animation_fly = {
		speed_normal = 10,
		speed_sprint = 20,
		stand_start = 140,
		stand_end = 160,
		walk_start = 110,
		walk_end = 130,
		}
local animation_land = {
		speed_normal = 10,
		speed_sprint = 20,
		stand_start = 50,
		stand_end = 100,
		walk_start = 1,
		walk_end = 40,
		}

-- Nether Dragon by rael5

mobs:register_mob("nether_mobs:dragon", {
	type = "monster",
	hp_min = 200,
	hp_max = 300,
	armor = 80,
	passive = false,
	walk_velocity = 3,
	run_velocity = 5,
	walk_chance = 35,
	jump = false,
	jump_height = 1.1,
	stepheight = 1.5,
	fly = true,
	fly_in = "air",
	runaway = false,
	pushable = false,
	view_range = 60,
	knock_back = 5,
	damage = 40,
	--fear_height = 6,
	fall_speed = -8,
	fall_damage = 20,
	water_damage = 5,
	lava_damage = 0,
	light_damage = 1,
	suffocation = false,
	floats = 1,
	reach = 7,
	attack_chance = 30,
	attack_animals = true,
	attack_npcs = true,
	attack_players = true,
	attacks_monsters = false,
	attack_type = "dogshoot",
	shoot_interval = 1,
	dogshoot_switch = 2,
	dogshoot_count = 0,
	dogshoot_count_max =5,
	arrow = "nether_mobs:dragon_breath",
	shoot_offset = 1,
	group_attack = true,
	pathfinding = 1,
	makes_footstep_sound = true,
	sounds = {
		random = "nether_dragon_random",
		shoot_attack = "nether_dragon_attack",
	},
	blood_texture = "nether_particle.png",
	drops = {
		{name = "mobs:meat_raw", chance = 1, min = 5, max = 8},
		{name = "nether_mobs:dragon_scale", chance = 1, min = 1, max = 3},
		{name = "nether_mobs:dragon_egg", chance = 9, min = 1, max = 1},
		{name = "nether:rack", chance = 3, min = 2, max = 4},
		{name = "nether:rack_deep", chance = 3, min = 1, max = 2},
		{name = "nether:brick_compressed", chance = 5, min = 1, max = 2},
		{name = "nether:glowstone", chance = 1, min = 2, max = 6},
		{name = "nether:glowstone_deep", chance = 2, min = 1, max = 4},
		{name = "nether:basalt", chance = 2, min = 1, max = 2},
	},
	visual = "mesh",
	visual_size = {x=20, y=20},
	collisionbox = {-1.3, -1.0, -1.3, 1.3, 1.8, 1.3},
	textures = {
		{"mobs_nether_dragon.png"},
	},
	child_texture = {
		{"mobs_nether_dragon_child.png"},
	},
	mesh = "mobs_nether_dragon.b3d",
	replace_rate = 10, --allow to spawn in the overworld without too much transformation
	replace_what = {
			"default:sand",
			"default:silver_sand",
			"default:dirt_with_grass",
			"default:dirt_with_snow",
			"default:dirt_with_dry_grass",
			"default:dirt_with_rainforest_litter",
			"default:dirt",
                    },
	replace_with = "nether:sand",
	replace_offset = -2,
	animation = animation_fly,
	on_die = function(self, pos)
		pos.y = pos.y + 0.5
		mobs:effect(pos, 30, "nether_particle.png", 0.1, 2, 3, 5)
		pos.y = pos.y + 0.25
		mobs:effect(pos, 30, "nether_particle.png", 0.1, 2, 3, 5)
	end,

})

-- Tamed Nether Dragon by rael5

mobs:register_mob("nether_mobs:tamed_dragon", {
	type = "npc",
	hp_min = 100,
	hp_max = 200,
	armor = 80,
	passive = false,
	walk_velocity = 3,
	run_velocity = 5,
	walk_chance = 35,
	jump = false,
	jump_height = 1.1,
	stepheight = 1.5,
	fly = true,
	fly_in = "air",
	runaway = false,
	pushable = false,
	view_range = 60,
	knock_back = 5,
	damage = 34,
	--fear_height = 6,
	fall_speed = -8,
	fall_damage = 20,
	water_damage = 5,
	lava_damage = 0,
	--light_damage = 1,
	suffocation = false,
	floats = 1,
	--reach = 7,
	attack_chance = 30,
	attack_animals = false,
	attack_npcs = false,
	attacks_monsters = true,
	--owner_loyal = true,
	attack_type = "dogshoot",
	shoot_interval = 1,
	dogshoot_switch = 2,
	dogshoot_count = 0,
	dogshoot_count_max =5,
	arrow = "nether_mobs:dragon_breath",
	shoot_offset = 1,
	--pathfinding = 1,
	makes_footstep_sound = true,
	sounds = {
		random = "nether_dragon_random",
		shoot_attack = "nether_dragon_attack",
	},
	blood_texture = "nether_particle.png",
	drops = {
		{name = "mobs:meat_raw", chance = 1, min = 5, max = 8},
		{name = "nether_mobs:dragon_scale", chance = 1, min = 1, max = 1}, --less scale dropped by tamed dragon
		{name = "nether_mobs:dragon_egg", chance = 12, min = 1, max = 1},
		{name = "nether:rack", chance = 3, min = 2, max = 4},
		{name = "nether:rack_deep", chance = 3, min = 1, max = 2},
		{name = "nether:brick_compressed", chance = 5, min = 1, max = 2},
		{name = "nether:glowstone", chance = 1, min = 2, max = 6},
		{name = "nether:glowstone_deep", chance = 2, min = 1, max = 4},
		{name = "nether:basalt", chance = 2, min = 1, max = 2},
	},
	visual = "mesh",
	visual_size = {x=20, y=20},
	collisionbox = {-1.3, -1.0, -1.3, 1.3, 1.8, 1.3},
	textures = {
		{"mobs_nether_dragon_child.png"},
	},
	child_texture = {
		{"mobs_nether_dragon_child.png"},
	},
	mesh = "mobs_nether_dragon.b3d",
	--replace_rate = 10, --allow to spawn in the overworld without too much transformation
	--replace_what = {
		--	"default:sand",
		--	"default:silver_sand",
		--	"default:dirt_with_grass",
		--	"default:dirt_with_snow",
		--	"default:dirt_with_dry_grass",
		--	"default:dirt_with_rainforest_litter",
		--	"default:dirt",
    --                },
	--replace_with = "nether:sand",
	--replace_offset = -5,
	animation = animation_fly,
	on_die = function(self, pos)
		pos.y = pos.y + 0.5
		mobs:effect(pos, 30, "nether_particle.png", 0.1, 2, 3, 5)
		pos.y = pos.y + 0.25
		mobs:effect(pos, 30, "nether_particle.png", 0.1, 2, 3, 5)
		if self.driver then
			minetest.add_item(pos, "mobs:saddle")
			mobs.detach(self.driver, {x = 1, y = 0, z = 1})
		end
	end,
	follow = {"mobs:meat_raw", "mobs:meat"},
	do_custom = function(self, dtime)

		-- set needed values if not already present
		if not self.v3 or (self.child ~= self._child) then
			self.v2 = 0
			self.v3 = 0
			self._child = self.child
			self.max_speed_forward = 12
			self.max_speed_reverse = 4
			self.accel = 6
			self.terrain_type = 2
			self.driver_attach_at = {x = 0, y = (self.child and 1.3 or 1.25), z = 0}
			self.driver_eye_offset = {x = 0, y = (self.child and 3 or 31), z = 0}
			local scale = (self.child and 0.1 or 0.05)
			self.driver_scale = {x = scale, y = scale} -- shrink driver to fit model
		end

		-- if driver present allow control of dragon
		if self.driver then

			mobs.drive(self, "walk", "stand", true, dtime)

			return false -- skip rest of mob functions
		end

		return true
	end,

	on_rightclick = function(self, clicker)

		-- make sure player is clicking
		if not clicker or not clicker:is_player() then
			return
		end

		-- feed, tame or heal dragon
		if mobs:feed_tame(self, clicker, 10, true, true) then
			return
		end

		-- applying protection rune
		if mobs:protect(self, clicker) then
			return
		end

		-- make sure tamed dragon is being clicked by owner only
		if self.tamed and self.owner == clicker:get_player_name() then

			local inv = clicker:get_inventory()

			-- detatch player already riding dragon
			if self.driver and clicker == self.driver then

				mobs.detach(clicker, {x = 1, y = 0, z = 1})

				-- add saddle back to inventory
				if inv:room_for_item("main", "mobs:saddle") then
					inv:add_item("main", "mobs:saddle")
				else
					minetest.add_item(clicker:get_pos(), "mobs:saddle")
				end

self.saddle = nil

			-- attach player to dragon
			elseif (not self.driver-- and not self.child
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
		end

		-- used to capture dragon with magic lasso
		if mobs:capture_mob(self, clicker, nil, nil, 80, false, nil) then
			return
		end
	end

})


mobs:spawn({
	name = "nether_mobs:dragon",
	nodes = {"nether:rack","nether:rack_deep"},
        neighbours = "air",
	max_light = 14, --not in bright daylight
	max_height = nethermobs.MAX_HEIGHT_DRAGON,
	min_height = nethermobs.MIN_HEIGHT_DRAGON,
	interval = 100,
	chance = 64000,
	day_toggle = nil,
	active_object_count = 2,
	on_spawn = function(self, pos)
		pos.y = pos.y + 0.5
		mobs:effect(pos, 30, "nether_particle.png", 0.1, 2, 3, 5)
		pos.y = pos.y + 0.25
		mobs:effect(pos, 30, "nether_particle.png", 0.1, 2, 3, 5)
	end,
})

mobs:register_egg("nether_mobs:tamed_dragon", S("nether dragon"), "mobs_chicken_egg.png^(nether_sand.png^fire_basic_flame.png^[mask:mobs_chicken_egg_overlay.png)", 1)
mobs:register_egg("nether_mobs:dragon", S("nether dragon"), "nether_sand.png^nether_dragon_fire.png", 1)

-- to spawn childs from eggs

minetest.register_craftitem("nether_mobs:dragon_egg", {

		description = S("@1 (tamed)", S("nether dragon")),
		inventory_image = "mobs_chicken_egg.png^(nether_sand.png^fire_basic_flame.png^[mask:mobs_chicken_egg_overlay.png)",
		groups = {spawn_egg = 2},
		stack_max = 1,

		on_place = function(itemstack, placer, pointed_thing)

			local pos = pointed_thing.above

			-- am I clicking on something with existing on_rightclick function?
			local under = minetest.get_node(pointed_thing.under)
			local def = minetest.registered_nodes[under.name]
			if def and def.on_rightclick then
				return def.on_rightclick(pointed_thing.under, under, placer, itemstack)
			end

			if pos
			and not minetest.is_protected(pos, placer:get_player_name()) then

				if not minetest.registered_entities["nether_mobs:tamed_dragon"] then
					return
				end

				pos.y = pos.y + 1

				local data = itemstack:get_metadata()
				local mob = minetest.add_entity(pos, "nether_mobs:tamed_dragon", data)
				local ent = mob:get_luaentity()

				ent.owner = placer:get_player_name()
				mob:set_properties({
					textures = ent.child_texture[1],
					visual_size = {
						x = ent.base_size.x / 5,
						y = ent.base_size.y / 5
					},
					collisionbox = {
						ent.base_colbox[1] / 5,
						ent.base_colbox[2] / 5,
						ent.base_colbox[3] / 5,
						ent.base_colbox[4] / 5,
						ent.base_colbox[5] / 5,
						ent.base_colbox[6] / 5
					},
				})



				ent.child = true
				ent.tamed = true

				-- since mob is unique we remove egg once spawned
				itemstack:take_item()
			end

			return itemstack
		end,
	})


mobs:alias_mob("mobs:nether_dragon", "nether_mobs:dragon") -- compatibility
