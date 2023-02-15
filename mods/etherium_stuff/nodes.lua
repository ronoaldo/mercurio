local S = etherium_stuff.intllib

--Code for placing nodes in air
function get_eye_pos(player)
	local player_pos = player:get_pos()
	local eye_height = player:get_properties().eye_height
	local eye_offset = player:get_eye_offset()
	player_pos.y = player_pos.y + eye_height
	player_pos = vector.add(player_pos, eye_offset)

	return player_pos
end

function place_in_air(itemstack, user, pointed_thing)
	local pos = get_eye_pos(user)
	local look_dir = user:get_look_dir()
	look_dir = vector.multiply(look_dir, 4)

	pos = vector.add(pos, look_dir)

	minetest.set_node(pos, {name = itemstack:get_name()})
	itemstack:take_item(1)
	return itemstack
end

minetest.register_node("etherium_stuff:sand", {
	description = S("Etherium Sand"),
	tiles = {"etherium_sand.png"},
	groups = {crumbly = 3, falling_node = 1},
	sounds = default.node_sound_sand_defaults(),
	on_secondary_use = place_in_air
})


minetest.register_node("etherium_stuff:sandstone", {
	description = S("Etherium Sandstone"),
	tiles = {"etherium_sandstone.png"},
	groups = {crumbly = 1, cracky = 3},
	sounds = default.node_sound_stone_defaults(),
	on_secondary_use = place_in_air
})

minetest.register_node("etherium_stuff:sandstone_brick", {
	description = S("Etherium Sandstone Brick"),
	paramtype2 = "facedir",
	place_param2 = 0,
	tiles = {"etherium_sandstone_brick.png"},
	is_ground_content = false,
	groups = {cracky = 2},
	sounds = default.node_sound_stone_defaults(),
	on_secondary_use = place_in_air
})

minetest.register_node("etherium_stuff:sandstone_block", {
	description = S("Etherium Sandstone Block"),
	tiles = {"etherium_sandstone_block.png"},
	is_ground_content = false,
	groups = {cracky = 2},
	sounds = default.node_sound_stone_defaults(),
	on_secondary_use = place_in_air
})

minetest.register_node("etherium_stuff:glass", {
	description = S("Etherium Glass"),
	drawtype = "glasslike_framed_optional",
	tiles = {"etherium_glass.png", "etherium_glass_detail.png"},
	paramtype = "light",
	sunlight_propagates = true,
	is_ground_content = false,
	groups = {cracky = 3, oddly_breakable_by_hand = 3},
	sounds = default.node_sound_glass_defaults(),
	on_secondary_use = place_in_air
})

minetest.register_node("etherium_stuff:crystal_glass", {
	description = S("Etherium Crystal Glass"),
	drawtype = "glasslike_framed_optional",
	tiles = {"etherium_crystal_glass.png", "etherium_crystal_glass_detail.png"},
	paramtype = "light",
	sunlight_propagates = true,
	is_ground_content = false,
	light_source = default.LIGHT_MAX - 1,
	groups = {cracky = 3, oddly_breakable_by_hand = 3},
	sounds = default.node_sound_glass_defaults(),
	on_secondary_use = place_in_air
})

minetest.register_node("etherium_stuff:sandstone_light_block", {
	description = S("Etherium Sandstone Light Block"),
	tiles = {"etherium_sandstone_light_block.png"},
	paramtype = "light",
	light_source = 14,
	groups = {cracky = 2, oddly_breakable_by_hand = 3},
	sounds = default.node_sound_glass_defaults(),
	on_secondary_use = place_in_air
})
