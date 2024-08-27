-- Copyright (C) 2012-2013 Diego Martínez <kaeza@users.sf.net>
local materials = xcompat.materials

minetest.register_craft({
	output = "computers:shefriendSOO",
	recipe = {
		{ "basic_materials:plastic_sheet", "basic_materials:plastic_sheet", "basic_materials:plastic_sheet" },
		{ "basic_materials:plastic_sheet", materials.glass, "basic_materials:plastic_sheet" },
		{ "basic_materials:plastic_sheet", "group:wood", "basic_materials:plastic_sheet" }
	}
})

minetest.register_craft({
	output = "computers:slaystation",
	recipe = {
		{ "basic_materials:plastic_sheet", "basic_materials:plastic_sheet", "basic_materials:plastic_sheet" },
		{ "basic_materials:plastic_sheet", "group:wood", "basic_materials:plastic_sheet" }
	}
})

minetest.register_craft({
	output = "computers:vanio",
	recipe = {
		{ "basic_materials:plastic_sheet", "", "" },
		{ materials.glass, "", "" },
		{ "basic_materials:plastic_sheet", "basic_materials:plastic_sheet", "basic_materials:plastic_sheet" }
	}
})

minetest.register_craft({
	output = "computers:specter",
	recipe = {
		{ "", "", "basic_materials:plastic_sheet" },
		{ "basic_materials:plastic_sheet", "basic_materials:plastic_sheet", "basic_materials:plastic_sheet" },
		{ "basic_materials:plastic_sheet", "basic_materials:plastic_sheet", "basic_materials:plastic_sheet" }
	}
})

minetest.register_craft({
	output = "computers:slaystation2",
	recipe = {
		{ "basic_materials:plastic_sheet", "basic_materials:plastic_sheet", "basic_materials:plastic_sheet" },
		{ "basic_materials:plastic_sheet", materials.steel_ingot, "basic_materials:plastic_sheet" }
	}
})

minetest.register_craft({
	output = "computers:admiral64",
	recipe = {
		{ "basic_materials:plastic_sheet", "basic_materials:plastic_sheet", "basic_materials:plastic_sheet" },
		{ "group:wood", "group:wood", "group:wood" }
	}
})

minetest.register_craft({
	output = "computers:admiral128",
	recipe = {
		{ "basic_materials:plastic_sheet", "basic_materials:plastic_sheet", "basic_materials:plastic_sheet" },
		{ materials.steel_ingot, materials.steel_ingot, materials.steel_ingot }
	}
})

minetest.register_craft({
	output = "computers:wee",
	recipe = {
		{ "basic_materials:plastic_sheet", "basic_materials:plastic_sheet", "basic_materials:plastic_sheet" },
		{ "basic_materials:plastic_sheet", materials.copper_ingot, "basic_materials:plastic_sheet" }
	}
})

minetest.register_craft({
	output = "computers:piepad",
	recipe = {
		{ "basic_materials:plastic_sheet", "basic_materials:plastic_sheet", "basic_materials:plastic_sheet" },
		{ "basic_materials:plastic_sheet", materials.glass, "basic_materials:plastic_sheet" }
	}
})

--new stuff

minetest.register_craft({
	output = "computers:monitor",
	recipe = {
		{ "basic_materials:plastic_sheet", materials.glass,"" },
		{ "basic_materials:plastic_sheet", materials.glass,"" },
		{ "basic_materials:plastic_sheet", materials.mese_crystal_fragment, "basic_materials:plastic_sheet" }
	}
})

minetest.register_craft({
	output = "computers:router",
	recipe = {
		{ materials.steel_ingot,"","" },
		{ materials.steel_ingot ,"basic_materials:plastic_sheet", "basic_materials:plastic_sheet" },
		{ materials.mese_crystal_fragment,"basic_materials:plastic_sheet", "basic_materials:plastic_sheet"  }
	}
})

minetest.register_craft({
	output = "computers:tower",
	recipe = {
		{ "basic_materials:plastic_sheet", materials.steel_ingot, "basic_materials:plastic_sheet" },
		{ "basic_materials:plastic_sheet", materials.mese_crystal, "basic_materials:plastic_sheet" },
		{ "basic_materials:plastic_sheet", materials.steel_ingot, "basic_materials:plastic_sheet" }
	}
})

minetest.register_craft({
	output = "computers:printer",
	recipe = {
		{ "basic_materials:plastic_sheet", materials.steel_ingot,"" },
		{ "basic_materials:plastic_sheet", materials.mese_crystal, "basic_materials:plastic_sheet" },
		{ "basic_materials:plastic_sheet", materials.coal_lump, "basic_materials:plastic_sheet" }
	}
})

minetest.register_craft({
	output = "computers:printer",
	recipe = {
		{ "basic_materials:plastic_sheet", materials.steel_ingot,"" },
		{ "basic_materials:plastic_sheet", materials.mese_crystal, "basic_materials:plastic_sheet" },
		{ "basic_materials:plastic_sheet", materials.dye_black, "basic_materials:plastic_sheet", }
	}
})

minetest.register_craft({
	output = "computers:server",
	recipe = {
		{ "computers:tower", "computers:tower", "computers:tower", },
		{ "computers:tower", "computers:tower", "computers:tower" },
		{ "computers:tower", "computers:tower", "computers:tower" }
	}
})

minetest.register_craft({
	output = "computers:tetris_arcade",
	recipe = {
		{ "basic_materials:plastic_sheet", "basic_materials:energy_crystal_simple", "basic_materials:plastic_sheet", },
		{ materials.dye_black, materials.glass, materials.dye_black },
		{ "basic_materials:plastic_sheet", "basic_materials:energy_crystal_simple", "basic_materials:plastic_sheet" }
	}
})
