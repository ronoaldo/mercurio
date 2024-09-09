local selection_box = {
	type = "fixed",
	fixed = { -8/16, -8/16, -8/16, 8/16, -6/16, 8/16 }
}

local nodebox = {
	type = "fixed",
	fixed = {
		{ -8/16, -8/16, -8/16, 8/16, -7/16, 8/16 }, -- bottom slab
		{ -6/16, -7/16, -6/16, 6/16, -6/16, 6/16 }
	},
}

local function gate_rotate_rules(node, rules)
	for rotations = 0, node.param2 - 1 do
		rules = mesecon.rotate_rules_left(rules)
	end
	return rules
end

local function gate3_get_output_rules(node)
	return gate_rotate_rules(node, {{x=1, y=0, z=0}})
end

local function gate3_get_input_rules(node)
	return gate_rotate_rules(node, 	{
		{x=0, y=0, z=1, name="input1"},
		{x=0, y=0, z=-1, name="input2"},
		{x=-1, y=0, z=0, name="input3"}
	    })
end

local function set_gate3(pos, node, state)
	local gate = minetest.registered_nodes[node.name]

	if mesecon.do_overheat(pos) then
		minetest.remove_node(pos)
		mesecon.receptor_off(pos, gate3_get_output_rules(node))
		minetest.add_item(pos, gate.drop)
	elseif state then
		minetest.swap_node(pos, {name = gate.onstate, param2=node.param2})
		mesecon.receptor_on(pos, gate3_get_output_rules(node))
	else
		minetest.swap_node(pos, {name = gate.offstate, param2=node.param2})
		mesecon.receptor_off(pos, gate3_get_output_rules(node))
	end
end

local function update_gate3(pos, node, link, newstate)
	local gate = minetest.registered_nodes[node.name]

		local meta = minetest.get_meta(pos)


		meta:set_int(link.name, newstate == "on" and 1 or 0)

		local val1 = meta:get_int("input1") == 1 and 1 or 0
		local val2 = meta:get_int("input2") == 1 and 1 or 0
		local val3 = meta:get_int("input3") == 1 and 1 or 0


		set_gate3(pos, node, gate.assess(val1==1 and true or false, 
						val2==1 and true or false, 
						val3==1 and true or false))
	
end

local function register_gate(name, assess, recipe, description)
	local description = "Logic Gate: "..name

	local basename = "mesecons_gates3:"..name
	mesecon.register_node(basename, {
		description = description,
		inventory_image = "jeija_gate_off.png^jeija_gate_"..name..".png",
		paramtype = "light",
		paramtype2 = "facedir",
		is_ground_content = false,
		drawtype = "nodebox",
		drop = basename.."_off",
		selection_box = selection_box,
		node_box = nodebox,
		walkable = true,
		sounds = default.node_sound_stone_defaults(),
		assess = assess,
		onstate = basename.."_on",
		offstate = basename.."_off",
		after_dig_node = mesecon.do_cooldown,
	},{
		tiles = {
			"jeija_microcontroller_bottom.png^".."jeija_gate_off.png^"..
			"jeija_gate_output_off.png^".."jeija_gate_"..name..".png",
			"jeija_microcontroller_bottom.png^".."jeija_gate_output_off.png^"..
			"[transformFY",
			"jeija_gate_side.png^".."jeija_gate_side_output_off.png",
			"jeija_gate_side.png",
			"jeija_gate_side.png",
			"jeija_gate_side.png"
		},
		groups = {dig_immediate = 2, overheat = 1},
		mesecons = { receptor = {
			state = "off",
			rules = gate3_get_output_rules
		}, effector = {
			rules = gate3_get_input_rules,
			action_change = update_gate3
		}}
	},{
		tiles = {
			"jeija_microcontroller_bottom.png^".."jeija_gate_on.png^"..
			"jeija_gate_output_on.png^".."jeija_gate_"..name..".png",
			"jeija_microcontroller_bottom.png^".."jeija_gate_output_on.png^"..
			"[transformFY",
			"jeija_gate_side.png^".."jeija_gate_side_output_on.png",
			"jeija_gate_side.png",
			"jeija_gate_side.png",
			"jeija_gate_side.png"
		},
		groups = {dig_immediate = 2, not_in_creative_inventory = 1, overheat = 1},
		mesecons = { receptor = {
			state = "on",
			rules = gate3_get_output_rules
		}, effector = {
			rules = gate3_get_input_rules,
			action_change = update_gate3
		}}
	})

	minetest.register_craft({output = basename.."_off", recipe = recipe})
end

register_gate("and3", function (val1, val2, val3) return (val1 and val2 and val3) end,
	{{"mesecons:mesecon", "mesecons:mesecon", ""},
	 {"", "mesecons_materials:silicon", "mesecons:mesecon"},
	 {"mesecons:mesecon", "", ""}},
	"AND Gate")


register_gate("nand3",  function (val1, val2,val3) return not (val1 and val2 and val3) end,
	{{"mesecons:mesecon", "mesecons:mesecon", ""},
	 {"", "mesecons_materials:silicon", "mesecons_torch:mesecon_torch_on"},
	 {"mesecons:mesecon", "", ""}},
	"NAND Gate")

register_gate("nor3",  function (val1, val2, val3) return not (val1 or val2 or val3) end,
	{{"mesecons:mesecon", "mesecons:mesecon", ""},
	 {"", "mesecons:mesecon", "mesecons_torch:mesecon_torch_on"},
	 {"mesecons:mesecon", "", ""}},
	"NOR Gate")

register_gate("or3",  function (val1, val2, val3) return (val1 or val2 or val3) end,
	{{"mesecons:mesecon", "mesecons:mesecon", ""},
	 {"", "mesecons:mesecon", "mesecons:mesecon"},
	 {"mesecons:mesecon", "", ""}},
	"OR Gate")
