local nodebox = {
	type = "fixed",
	fixed = {{-8/16, -8/16, -8/16, 8/16, -7/16, 8/16 }},
}

local function gate_rotate_rules(node, rules)
	for rotations = 0, node.param2 - 1 do
		rules = mesecon.rotate_rules_left(rules)
	end
	return rules
end


local function latch_get_input_rules(node)
	return gate_rotate_rules(node, 
	    {
		{x=-1, y=0, z=0, name="data"},
		{x=0, y=0, z=-1, name="enable"}
	    })
end

local function latch_get_output_rules(node)
	return gate_rotate_rules(node, 
	    { {x=1,y=0,z=0 }} 
	)
end



local function set_latch(pos,node,state)
	local latch = minetest.registered_nodes[node.name]
	if state then
		minetest.swap_node(pos, {name = latch.onstate, param2=node.param2})
		mesecon.receptor_on(pos, latch_get_output_rules(node))
	else
		minetest.swap_node(pos, {name = latch.offstate, param2=node.param2})
		mesecon.receptor_off(pos, latch_get_output_rules(node))
	end    
end


local function update_latch(pos, node, link, newstate)
	local latch = minetest.registered_nodes[node.name]
	local meta = minetest.get_meta(pos)

	local data= meta:get_int("data") == 1 and 1 or 0
	local enable = meta:get_int("enable") == 1 and 1 or 0


	if link.name == "enable" then
	    if newstate == "off"  and enable == 1 then
		if data == 0 then
		    set_latch(pos,node,false)
		else 
		    set_latch(pos,node,true)
		end
		meta:set_int("enable",0)
	    end
	    if newstate == "on" then
		if data == 0 then	
		    set_latch(pos,node,false)
		else
		    set_latch(pos,node,true)
		end
		meta:set_int("enable",1)
	    end
	    
	end

	if link.name == "data" then
	    if enable == 1 then
		    local nv = newstate == "on" and 1 or 0
		    set_latch(pos,node, nv == 1 and true or false)
        	    meta:set_int("data",nv)
	    else
		meta:set_int("data", newstate == "on" and 1 or 0 )
	    end
	end

end



local function register_latch()
	local name = "latch"
	local description = "Logic Memory Circuit: "..name

	local basename = "mesecons_regs:"..name
	mesecon.register_node(basename, 
	{
		description = description,
		inventory_image = "jeija_gate_off.png^jeija_gate_"..name..".png",
		paramtype = "light",
		paramtype2 = "facedir",
		is_ground_content = false,
		drawtype = "nodebox",
		drop = basename.."_off",
		selection_box = nodebox,
		node_box = nodebox,
		walkable = true,
		sounds = default.node_sound_stone_defaults(),
		onstate = basename.."_on",
		offstate = basename.."_off",
		after_dig_node = mesecon.do_cooldown,
	},{
		tiles = {"jeija_microcontroller_bottom.png^".."jeija_gate_off.png^"..
			"jeija_gate_"..name..".png"},
		groups = {dig_immediate = 2, overheat = 1},
		mesecons = { receptor = {
			state = "off",
			rules = latch_get_output_rules
		}, effector = {
			rules = latch_get_input_rules,
			action_change = update_latch
		}}
	},{
		tiles = {"jeija_microcontroller_bottom.png^".."jeija_gate_on.png^"..
			"jeija_gate_"..name..".png"},
		groups = {dig_immediate = 2, not_in_creative_inventory = 1, overheat = 1},
		mesecons = { receptor = {
			state = "on",
			rules = latch_get_output_rules
		}, effector = {
			rules = latch_get_input_rules,
			action_change = update_latch
		}}
	})


	minetest.register_craft({output = basename.."_off", recipe = { 
	    { "mesecons_gates:and_off", "mesecons_gates:and_off", "mesecons_gates:not_off"},
	    { "mesecons_gates:nor_off", "mesecons_gates:nor_off", "mesecons_insulated:insulated_off"},
	    { "mesecons_insulated:insulated_off", "mesecons_insulated:insulated_off", "mesecons_insulated:insulated_off"}
	}})

end


register_latch()





local function update_flipflop(pos, node, link, newstate)
	local latch = minetest.registered_nodes[node.name]
	local meta = minetest.get_meta(pos)

	local data= meta:get_int("data") == 1 and 1 or 0
	local enable = meta:get_int("enable") == 1 and 1 or 0



	if link.name == "enable" then
	    if newstate == "off" then
		meta:set_int("enable",0)
	    end
	    if newstate == "on" and enable == 0 then
		if data == 0 then	
		    set_latch(pos,node,false)
		else
		    set_latch(pos,node,true)
		end
		meta:set_int("enable",1)
	    end
	    
	end

	if link.name == "data" then
		meta:set_int("data", newstate == "on" and 1 or 0 )
	end

end



local function register_flipflop()
	local name = "flipflop"
	local description = "Logic Memory Circuit: "..name

	local basename = "mesecons_regs:"..name
	mesecon.register_node(basename, 
	{
		description = description,
		inventory_image = "jeija_gate_off.png^jeija_gate_"..name..".png",
		paramtype = "light",
		paramtype2 = "facedir",
		is_ground_content = false,
		drawtype = "nodebox",
		drop = basename.."_off",
		selection_box = nodebox,
		node_box = nodebox,
		walkable = true,
		sounds = default.node_sound_stone_defaults(),
		onstate = basename.."_on",
		offstate = basename.."_off",
		after_dig_node = mesecon.do_cooldown,
	},{
		tiles = {"jeija_microcontroller_bottom.png^".."jeija_gate_off.png^"..
			"jeija_gate_"..name..".png"},
		groups = {dig_immediate = 2, overheat = 1},
		mesecons = { receptor = {
			state = "off",
			rules = latch_get_output_rules
		}, effector = {
			rules = latch_get_input_rules,
			action_change = update_flipflop
		}}
	},{
		tiles = {"jeija_microcontroller_bottom.png^".."jeija_gate_on.png^"..
			"jeija_gate_"..name..".png"},
		groups = {dig_immediate = 2, not_in_creative_inventory = 1, overheat = 1},
		mesecons = { receptor = {
			state = "on",
			rules = latch_get_output_rules
		}, effector = {
			rules = latch_get_input_rules,
			action_change = update_flipflop
		}}
	})

	minetest.register_craft({output = basename.."_off", 
	    recipe = { 
		    { "mesecons_regs:latch_off", "mesecons_regs:latch_off", },
		    { "mesecons_gates:not_off", "mesecons_insulated:insulated_off",},
		    { "mesecons_extrawires:tjunction_off", "mesecons_extrawires:corner_off", }
	    }})

end


register_flipflop()
