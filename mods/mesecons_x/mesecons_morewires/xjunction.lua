    
local xjunction_nodebox = {
	type = "fixed",
	-- ±0.001 is to prevent z-fighting
	fixed = {
		 { -3/32, -17/32, -16/32+0.001, 3/32, -13/32, -3/32},
		 { -3/32, -17/32, 16/32+0.001, 3/32, -13/32, 3/32},
		{ -16/32-0.001, -17/32, -3/32, -3/32, -13/32, 3/32 },
		{ 16/32+0.001, -17/32, -3/32, 3/32, -13/32, 3/32 },

		{ -6/32, -17/32, -6/32, 6/32, -12/32, 6/32 },
	}
}

local xjunction_selectionbox = {
		type = "fixed",
		fixed = { -16/32, -16/32, -16/32, 16/32, -13/32, 16/32 },
}
local xjunction_rules = 
{
        {x = 1, y = 0, z = 0},
        {x =-1, y = 0, z = 0},
        {x = 0, y = 0, z = 1},
        {x = 0, y = 0, z =-1},
}



minetest.register_node("mesecons_morewires:xjunction_on", {
	drawtype = "nodebox",
	tiles = {
		"jeija_insulated_wire_x_top_on.png",
		"jeija_insulated_wire_sides_on.png",
		"jeija_insulated_wire_ends_on.png",
		"jeija_insulated_wire_ends_on.png",
		"jeija_insulated_wire_ends_on.png",
		"jeija_insulated_wire_ends_on.png"
	},

	paramtype = "light",
--	paramtype2 = "facedir",
	is_ground_content = false,
	walkable = false,
	sunlight_propagates = true,
	selection_box = xjunction_selectionbox,
	node_box = xjunction_nodebox,
	groups = {dig_immediate = 3, not_in_creative_inventory = 1},
	drop = "mesecons_morewires:xjunction_off",
	sounds = default.node_sound_defaults(),
	mesecons = {conductor =
	{
		state = mesecon.state.on,
		rules = xjunction_rules,
		offstate = "mesecons_morewires:xjunction_off"
	}},
	on_blast = mesecon.on_blastnode,
	on_rotate = nil
})

minetest.register_node("mesecons_morewires:xjunction_off", {
	drawtype = "nodebox",
	description = "Insulated Mesecon X-junction",
	tiles = {
		"jeija_insulated_wire_x_top_off.png",
		"jeija_insulated_wire_sides_off.png",
		"jeija_insulated_wire_ends_off.png",
		"jeija_insulated_wire_ends_off.png",
		"jeija_insulated_wire_ends_off.png",
		"jeija_insulated_wire_ends_off.png"
	},
	paramtype = "light",
--	paramtype2 = "facedir",
	is_ground_content = false,
	walkable = false,
	sunlight_propagates = true,
	selection_box = xjunction_selectionbox,
	node_box = xjunction_nodebox,
	groups = {dig_immediate = 3},
	sounds = default.node_sound_defaults(),
	mesecons = {conductor =
	{
		state = mesecon.state.off,
		rules = xjunction_rules,
		onstate = "mesecons_morewires:xjunction_on"
	}},
	on_blast = mesecon.on_blastnode,
	on_rotate = nil
})

minetest.register_craft({
	output = "mesecons_morewires:xjunction_off 2",
	recipe = {
		{"","mesecons_insulated:insulated_off", ""},
		{"mesecons_insulated:insulated_off","mesecons_insulated:insulated_off" , "mesecons_insulated:insulated_off"},
		{"","mesecons_insulated:insulated_off", ""},
	}
})
