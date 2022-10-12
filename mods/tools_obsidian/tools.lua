--pick
minetest.register_tool("tools_obsidian:pick_obsidian", {
	description = "Obsidian Pickaxe",
	inventory_image = "tools_obsidian_pick.png",
	wield_scale = {x=1.2,y=1,z=.4},
	tool_capabilities = {
		full_punch_interval = 0.9,
        stack_max = 1,
        range = 4.0,
		max_drop_level=3,
		groupcaps={
			cracky = {times={[1]=1.60, [2]=0.8, [3]=0.40}, uses = t_uses.twenty*2, maxlevel=3},
		},
		damage_groups = {fleshy=5},
	},
	sound = {breaks = "default_tool_breaks"},
	groups = {pickaxe = 1}
})

minetest.register_craft({
		output = "tools_obsidian:pick_obsidian",
		recipe = {
			{"default:obsidian_shard", "default:diamond", "default:obsidian"},
			{"default:mese_crystal_fragment", "default:mese_crystal", "default:diamond"},
			{"bucket:bucket_lava", "default:mese_crystal_fragment", "default:obsidian_shard"}
		},
		replacements = {
			{"bucket:bucket_lava", "bucket:bucket_empty"},
		}
	}
)

--axe
minetest.register_tool("tools_obsidian:axe_obsidian", {
	description = "Obsidian Axe",
	inventory_image = "tools_obsidian_axe.png",
	wield_scale = {x=1.2,y=1,z=.4},
	tool_capabilities = {
		full_punch_interval = 1,
        stack_max = 1,
        range = 4.5,
		max_drop_level=2,
		groupcaps={
			choppy = {times={[1]=1.80, [2]=0.6, [3]=0.40}, uses = t_uses.twenty*2, maxlevel=3},
		},
		damage_groups = {fleshy=8},
	},
	sound = {breaks = "default_tool_breaks"},
	groups = {axe = 1}
})

minetest.register_craft({
		output = "tools_obsidian:axe_obsidian",
		recipe = {
			{"default:obsidian", "default:diamond",	"default:mese_crystal_fragment"},
			{"default:obsidian", "default:mese_crystal_fragment", ""},
			{"bucket:bucket_lava", "default:mese_crystal", ""}
		},
		replacements = {
			{"bucket:bucket_lava", "bucket:bucket_empty"},
		}
	}
)

--shovel
minetest.register_tool("tools_obsidian:shovel_obsidian", {
	description = "Obsidian Shovel",
	inventory_image = "tools_obsidian_shovel.png^[transformR90",
	wield_scale = {x=1.2,y=1,z=.4},
	tool_capabilities = {
		full_punch_interval = 1.2,
        stack_max = 1,
        range = 4.5,
		max_drop_level=2,
		groupcaps={
			crumbly = {times={[1]=0.9, [2]=0.40, [3]=0.20}, uses = t_uses.twenty*2, maxlevel=3},
		},
		damage_groups = {fleshy=5},
	},
	sound = {breaks = "default_tool_breaks"},
	groups = {shovel = 1}
})

minetest.register_craft({
		output = "tools_obsidian:shovel_obsidian",
		recipe = {
			{"default:obsidian_shard","default:obsidian","default:obsidian_shard"},
			{"default:mese_crystal_fragment","default:diamond","default:mese_crystal_fragment"},
			{"bucket:bucket_lava", "default:mese_crystal", ""}
		},
		replacements = {
			{"bucket:bucket_lava", "bucket:bucket_empty"},
		}
	}
)