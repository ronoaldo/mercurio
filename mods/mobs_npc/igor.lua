
local S = mobs_npc.S

-- Igor by TenPlus1

mobs_npc.igor_drops = {
	"vessels:glass_bottle", "mobs:meat_raw", {"default:sword_steel", 2},
	"farming:bread", {"bucket:bucket_water", 2}, "flowers:mushroom_red",
	"default:jungletree", {"fire:flint_and_steel", 3}, "mobs:leather",
	"default:acacia_sapling", {"fireflies:bug_net", 3}, "default:clay_lump",
	"default:ice", "default:coral_brown", "default:iron_lump",
	"default:obsidian_shard", "default:mossycobble", {"default:obsidian", 2}
}


mobs:register_mob("mobs_npc:igor", {
	type = "npc",
	passive = false,
	damage = 5,
	attack_type = "dogfight",
	owner_loyal = true,
	pathfinding = true,
	reach = 2,
	attacks_monsters = true,
	hp_min = 20,
	hp_max = 30,
	armor = 100,
	collisionbox = {-0.35,-1.0,-0.35, 0.35,0.8,0.35},
	visual = "mesh",
	mesh = "mobs_character.b3d",
	textures = {
		{"mobs_igor.png"}, -- skin by ruby32199
		{"mobs_igor2.png"},
		{"mobs_igor3.png"},
		{"mobs_igor4.png"},
		{"mobs_igor5.png"},
		{"mobs_igor6.png"},
		{"mobs_igor7.png"},
		{"mobs_igor8.png"}
	},
	makes_footstep_sound = true,
	sounds = {},
	walk_velocity = 1,
	run_velocity = 2,
	stepheight = 1.1,
	fear_height = 2,
	jump = true,
	drops = {
		{name = "mobs:meat_raw", chance = 1, min = 1, max = 2},
		{name = "default:gold_lump", chance = 3, min = 1, max = 1}
	},
	water_damage = 1,
	lava_damage = 3,
	light_damage = 0,
	follow = {"mobs:meat_raw", "default:diamond"},
	view_range = 15,
	owner = "",
	order = "follow",
	animation = {
		speed_normal = 30,
		speed_run = 30,
		stand_start = 0,
		stand_end = 79,
		walk_start = 168,
		walk_end = 187,
		run_start = 168,
		run_end = 187,
		punch_start = 200,
		punch_end = 219
	},

	on_rightclick = function(self, clicker)

		-- feed to heal npc
		if mobs:feed_tame(self, clicker, 8, false, true) then return end
		if mobs:protect(self, clicker) then return end
		if mobs:capture_mob(self, clicker, nil, 5, 80, false, nil) then return end

		local item = clicker:get_wielded_item()
		local name = clicker:get_player_name()

		-- right clicking with gold lump drops random item from list
		if 	mobs_npc.drop_trade(self, clicker, "default:gold_lump",
				self.npc_drops or mobs_npc.igor_drops) then
			return
		end

		-- owner can right-click with stick to show control formspec
		if item:get_name() == "default:stick"
		and self.owner == name then

			minetest.show_formspec(name, "mobs_npc:controls",
					mobs_npc.get_controls_formspec(name, self))

			return
		end

		-- show simple dialog if enabled or idle chatter
		if mobs_npc.useDialogs == "Y" then
			simple_dialogs.show_dialog_formspec(name, self)
		else
			if self.state == "attack" then
				mobs_npc.npc_talk(self, clicker, {"Grr!", "Must Kill!"})
			else
				mobs_npc.npc_talk(self, clicker, {
					"Hey!", "What do you want?", "Go away!", "Go bother someone else!"})
			end
		end
	end
})


-- register spawn egg
mobs:register_egg("mobs_npc:igor", S("Igor"), "mobs_meat_raw.png", 1)


-- this is only required for servers that used the old mobs mod
mobs:alias_mob("mobs:igor", "mobs_npc:igor")


-- spawn Igor in world
if not mobs.custom_spawn_npc then

	mobs:spawn({
		name = "mobs_npc:igor",
		nodes = {"mobs:meatblock"},
		neighbors = {"default:brick"},
		min_light = 10,
		chance = 10000,
		active_object_count = 1,
		min_height = 0,
		day_toggle = true
	})
end
