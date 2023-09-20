
local S = farming.translate
local a = farming.recipe_items

-- wooden bowl

minetest.register_craftitem("farming:bowl", {
	description = S("Wooden Bowl"),
	inventory_image = "farming_bowl.png",
	groups = {food_bowl = 1, flammable = 2}
})

if not farming.mcl then

	minetest.register_craft({
		output = "farming:bowl 4",
		recipe = {
			{"group:wood", "", "group:wood"},
			{"", "group:wood", ""}
		}
	})
end

minetest.register_craft({
	type = "fuel",
	recipe = "farming:bowl",
	burntime = 10
})

-- saucepan

minetest.register_craftitem("farming:saucepan", {
	description = S("Saucepan"),
	inventory_image = "farming_saucepan.png",
	groups = {food_saucepan = 1, flammable = 2}
})

minetest.register_craft({
	output = "farming:saucepan",
	recipe = {
		{a.steel_ingot, "", ""},
		{"", "group:stick", ""}
	}
})

-- cooking pot

minetest.register_craftitem("farming:pot", {
	description = S("Cooking Pot"),
	inventory_image = "farming_pot.png",
	groups = {food_pot = 1, flammable = 2}
})

minetest.register_craft({
	output = "farming:pot",
	recipe = {
		{"group:stick", a.steel_ingot, a.steel_ingot},
		{"", a.steel_ingot, a.steel_ingot}
	}
})

-- baking tray

minetest.register_craftitem("farming:baking_tray", {
	description = S("Baking Tray"),
	inventory_image = "farming_baking_tray.png",
	groups = {food_baking_tray = 1, flammable = 2}
})

minetest.register_craft({
	output = "farming:baking_tray",
	recipe = {
		{a.clay_brick, a.clay_brick, a.clay_brick},
		{a.clay_brick, "", a.clay_brick},
		{a.clay_brick, a.clay_brick, a.clay_brick}
	}
})

-- skillet

minetest.register_craftitem("farming:skillet", {
	description = S("Skillet"),
	inventory_image = "farming_skillet.png",
	groups = {food_skillet = 1, flammable = 2}
})

minetest.register_craft({
	output = "farming:skillet",
	recipe = {
		{a.steel_ingot, "", ""},
		{"", a.steel_ingot, ""},
		{"", "", "group:stick"}
	}
})

-- mortar and pestle

minetest.register_craftitem("farming:mortar_pestle", {
	description = S("Mortar and Pestle"),
	inventory_image = "farming_mortar_pestle.png",
	groups = {food_mortar_pestle = 1, flammable = 2}
})

minetest.register_craft({
	output = "farming:mortar_pestle",
	recipe = {
		{a.stone, "group:stick", a.stone},
		{"", a.stone, ""}
	}
})

-- cutting board

minetest.register_craftitem("farming:cutting_board", {
	description = S("Cutting Board"),
	inventory_image = "farming_cutting_board.png",
	groups = {food_cutting_board = 1, flammable = 2}
})

minetest.register_craft({
	output = "farming:cutting_board",
	recipe = {
		{a.steel_ingot, "", ""},
		{"", "group:stick", ""},
		{"", "", "group:wood"}
	}
})

-- juicer

minetest.register_craftitem("farming:juicer", {
	description = S("Juicer"),
	inventory_image = "farming_juicer.png",
	groups = {food_juicer = 1, flammable = 2}
})

minetest.register_craft({
	output = "farming:juicer",
	recipe = {
		{"", a.stone, ""},
		{a.stone, "", a.stone}
	}
})

-- glass mixing bowl

minetest.register_craftitem("farming:mixing_bowl", {
	description = S("Glass Mixing Bowl"),
	inventory_image = "farming_mixing_bowl.png",
	groups = {food_mixing_bowl = 1, flammable = 2}
})

minetest.register_craft({
	output = "farming:mixing_bowl",
	recipe = {
		{a.glass, "group:stick", a.glass},
		{"", a.glass, ""}
	}
})

minetest.register_craft( {
	output = "vessels:glass_fragments",
	recipe = {{"farming:mixing_bowl"}}
})
