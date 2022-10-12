minetest.register_craft({
	output = "basic_signs:sign_wall_locked",
	type = "shapeless",
	recipe = {
		"default:sign_wall_wood",
		"basic_materials:padlock",
	},
})

-- craft recipes for the metal signs

minetest.register_craft( {
	output = "basic_signs:sign_wall_steel_green",
	recipe = {
			{ "dye:dark_green", "dye:white", "dye:dark_green" },
			{ "", "default:sign_wall_steel", "" }
	},
})

minetest.register_craft( {
	output = "basic_signs:sign_wall_steel_green 2",
	recipe = {
			{ "dye:dark_green", "dye:white", "dye:dark_green" },
			{ "steel:sheet_metal", "steel:sheet_metal", "steel:sheet_metal" }
	},
})

minetest.register_craft( {
	output = "basic_signs:sign_wall_steel_yellow",
	recipe = {
			{ "dye:yellow", "dye:black", "dye:yellow" },
			{ "", "default:sign_wall_steel", "" }
	},
})

minetest.register_craft( {
	output = "basic_signs:sign_wall_steel_yellow 2",
	recipe = {
			{ "dye:yellow", "dye:black", "dye:yellow" },
			{ "steel:sheet_metal", "steel:sheet_metal", "steel:sheet_metal" }
	},
})

minetest.register_craft( {
	output = "basic_signs:sign_wall_steel_red",
	recipe = {
			{ "dye:red", "dye:white", "dye:red" },
			{ "", "default:sign_wall_steel", "" }
	},
})

minetest.register_craft( {
	output = "basic_signs:sign_wall_steel_red 2",
	recipe = {
			{ "dye:red", "dye:white", "dye:red" },
			{ "steel:sheet_metal", "steel:sheet_metal", "steel:sheet_metal" }
	},
})

minetest.register_craft( {
	output = "basic_signs:sign_wall_steel_white_red",
	recipe = {
			{ "dye:white", "dye:red", "dye:white" },
			{ "", "default:sign_wall_steel", "" }
	},
})

minetest.register_craft( {
	output = "basic_signs:sign_wall_steel_white_red 2",
	recipe = {
			{ "dye:white", "dye:red", "dye:white" },
			{ "steel:sheet_metal", "steel:sheet_metal", "steel:sheet_metal" }
	},
})

minetest.register_craft( {
	output = "basic_signs:sign_wall_steel_white_black",
	recipe = {
			{ "dye:white", "dye:black", "dye:white" },
			{ "", "default:sign_wall_steel", "" }
	},
})

minetest.register_craft( {
	output = "basic_signs:sign_wall_steel_white_black 2",
	recipe = {
			{ "dye:white", "dye:black", "dye:white" },
			{ "steel:sheet_metal", "steel:sheet_metal", "steel:sheet_metal" }
	},
})

minetest.register_craft( {
	output = "basic_signs:sign_wall_steel_orange",
	recipe = {
			{ "dye:orange", "dye:black", "dye:orange" },
			{ "", "default:sign_wall_steel", "" }
	},
})

minetest.register_craft( {
	output = "basic_signs:sign_wall_steel_orange 2",
	recipe = {
			{ "dye:orange", "dye:black", "dye:orange" },
			{ "steel:sheet_metal", "steel:sheet_metal", "steel:sheet_metal" }
	},
})

minetest.register_craft( {
	output = "basic_signs:sign_wall_steel_blue",
	recipe = {
			{ "dye:blue", "dye:white", "dye:blue" },
			{ "", "default:sign_wall_steel", "" }
	},
})

minetest.register_craft( {
	output = "basic_signs:sign_wall_steel_blue 2",
	recipe = {
			{ "dye:blue", "dye:white", "dye:blue" },
			{ "steel:sheet_metal", "steel:sheet_metal", "steel:sheet_metal" }
	},
})

minetest.register_craft( {
	output = "basic_signs:sign_wall_steel_brown",
	recipe = {
			{ "dye:brown", "dye:white", "dye:brown" },
			{ "", "default:sign_wall_steel", "" }
	},
})

minetest.register_craft( {
	output = "basic_signs:sign_wall_steel_brown 2",
	recipe = {
			{ "dye:brown", "dye:white", "dye:brown" },
			{ "steel:sheet_metal", "steel:sheet_metal", "steel:sheet_metal" }
	},
})

minetest.register_craft( {
	output = "basic_signs:sign_wall_glass 8",
	recipe = {
			{ "default:glass", "default:glass", "default:glass" },
			{ "default:glass", "default:glass", "default:glass" },
			{ "",              "default:glass", "" }
	},
})

minetest.register_craft( {
	output = "basic_signs:sign_wall_obsidian_glass 8",
	recipe = {
			{ "default:obsidian_glass", "default:obsidian_glass", "default:obsidian_glass" },
			{ "default:obsidian_glass", "default:obsidian_glass", "default:obsidian_glass" },
			{ "",                       "default:obsidian_glass", "" }
	},
})

minetest.register_craft( {
	output = "basic_signs:sign_wall_glass 3",
	recipe = {
			{ "xpanes:pane_flat", "xpanes:pane_flat", "xpanes:pane_flat" },
			{ "xpanes:pane_flat", "xpanes:pane_flat", "xpanes:pane_flat" },
			{ "",                 "xpanes:pane_flat", "" }
	},
})

minetest.register_craft( {
	output = "basic_signs:sign_wall_obsidian_glass 3",
	recipe = {
			{ "xpanes:obsidian_pane_flat", "xpanes:obsidian_pane_flat", "xpanes:obsidian_pane_flat" },
			{ "xpanes:obsidian_pane_flat", "xpanes:obsidian_pane_flat", "xpanes:obsidian_pane_flat" },
			{ "",                       "xpanes:obsidian_pane_flat", "" }
	},
})

minetest.register_craft( {
	output = "basic_signs:sign_wall_plastic 3",
	recipe = {
			{ "basic_materials:plastic_sheet", "basic_materials:plastic_sheet", "basic_materials:plastic_sheet" },
			{ "basic_materials:plastic_sheet", "basic_materials:plastic_sheet", "basic_materials:plastic_sheet" },
			{ "",                              "default:steel_ingot",           "" }
	},
})
