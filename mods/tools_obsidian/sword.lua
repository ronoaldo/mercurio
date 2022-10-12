
--sword
minetest.register_tool("tools_obsidian:sword_obsidian", {
	description = "Obsidian Sword",
	inventory_image = "tools_obsidian_sword.png",
	wield_scale = {x=1.2,y=1,z=.4},
	tool_capabilities = {
		full_punch_interval = 1.0,
        stack_max = 1,
        range = 4.0,
		max_drop_level=1,
		groupcaps={
			snappy={times={[1]=1.60, [2]=0.80, [3]=0.25}, uses = t_uses.twenty*2, maxlevel=3},
		},
		damage_groups = {fleshy=10},
	},
	sound = {breaks = "default_tool_breaks"},
	groups = {sword = 1}
})

minetest.register_craft({
		output = "tools_obsidian:sword_obsidian",
		recipe = {
			{"default:obsidian_glass", "default:obsidian_shard", "default:obsidian"},
			{"default:mese_crystal", "default:obsidian", "default:diamond"},
			{"bucket:bucket_lava", "default:mese_crystal", "default:obsidian_glass"}
		},
		replacements = {
			{"bucket:bucket_lava", "bucket:bucket_empty"},
		}
	}
)

--longsword
minetest.register_tool("tools_obsidian:longsword_obsidian", {
	description = "Obsidian Longword",
	inventory_image = "tools_obsidian_sword_long.png",
	wield_image = "tools_obsidian_sword_long.png",
	wield_scale = {x=2,y=1.3,z=.4},
	tool_capabilities = {
		full_punch_interval = 4.2,
        stack_max = 1,
        range = 6.0,
		max_drop_level=2,
		groupcaps={
			snappy={times={[1]=1.90, [2]=0.90, [3]=0.30}, uses=t_uses.twenty*3, maxlevel=3},
		},
		damage_groups = {fleshy=26},
	},
	sound = {breaks = "default_tool_breaks"},
	groups = {sword = 1}
})

minetest.register_craft({
		output = "tools_obsidian:longsword_obsidian",
		recipe = {
			{"default:obsidian_glass", "default:obsidian_shard", "default:obsidian"},
			{"default:mese_crystal", "tools_obsidian:sword_obsidian", "default:diamond"},
			{"bucket:bucket_lava", "default:mese_crystal", "default:obsidian_glass"}
		},
		replacements = {
			{"bucket:bucket_lava", "bucket:bucket_empty"},
		}
	}
)

--dagger
minetest.register_tool("tools_obsidian:dagger_obsidian", {
	description = "Obsidian Dagger",
	inventory_image = "tools_obsidian_dagger.png",
	wield_image = "tools_obsidian_dagger_wield.png",
	wield_scale = {x=1.2,y=1,z=.4},
	tool_capabilities = {
		full_punch_interval = .4,
        stack_max = 1,
        range = 3.0,
		max_drop_level=2,
		groupcaps={
			snappy={times={[1]=1.30, [2]=0.50, [3]=0.15}, uses=t_uses.twenty*3, maxlevel=3},
		},
		damage_groups = {fleshy=4},
	},
	sound = {breaks = "default_tool_breaks"},
	groups = {sword = 1}
})

minetest.register_craft({
		output = "tools_obsidian:dagger_obsidian",
		recipe = {
			{"default:obsidian_glass", "default:obsidian", "default:obsidian_shard"},
			{"default:mese_crystal_fragment", "default:obsidian_shard", "default:diamond"},
			{"bucket:bucket_lava", "default:mese_crystal_fragment", "default:obsidian_glass"}
		},
		replacements = {
			{"bucket:bucket_lava", "bucket:bucket_empty"},
		}
	}
)