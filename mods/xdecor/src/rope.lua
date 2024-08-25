local rope = {}
local S = minetest.get_translator("xdecor")

-- Maximum length a rope can extend to
local MAX_ROPES = 30

local ropesounds = default.node_sound_leaves_defaults()

-- Code by Mirko K. (modified by Temperest, Wulfsdad, kilbith and Wuzzy) (License: GPL).
function rope.place(itemstack, placer, pointed_thing)
	local creative = minetest.is_creative_enabled(placer:get_player_name())
	local protection_bypass = minetest.check_player_privs(placer, "protection_bypass")
	local pname = placer:get_player_name()
	if pointed_thing.type == "node" then
		-- Use pointed node's on_rightclick function first, if present
		if placer and not placer:get_player_control().sneak then
			local node = minetest.get_node(pointed_thing.under)
			if minetest.registered_nodes[node.name] and minetest.registered_nodes[node.name].on_rightclick then
				return minetest.registered_nodes[node.name].on_rightclick(pointed_thing.under, node, placer, itemstack) or itemstack
			end
		end
		local pos = pointed_thing.above
		-- Check protection
		if minetest.is_protected(pos, pname) and not protection_bypass then
			minetest.record_protection_violation(pos, pname)
			return itemstack
		end

		local oldnode = minetest.get_node(pos)
		local stackname = itemstack:get_name()
		-- Limit rope length to max. stack size or MAX_ROPES (whatever is smaller).
		-- Prevents the rope to extend infinitely in Creative Mode.
		local max_ropes = math.min(itemstack:get_stack_max(), MAX_ROPES)

		-- Start placing ropes and extend it downwards until we hit an obstacle,
		-- run out of ropes or hit the maximum rope length.
		local start_pos = table.copy(pos)
		local ropes_to_place = 0
		local new_rope_nodes = {}
		while oldnode.name == "air" and (creative or (ropes_to_place < itemstack:get_count())) and ropes_to_place < max_ropes do
			-- Stop extending rope into protected area
			if minetest.is_protected(pos, pname) and not protection_bypass then
				break
			end

			table.insert(new_rope_nodes, table.copy(pos))
			pos.y = pos.y - 1
			oldnode = minetest.get_node(pos)
			ropes_to_place = ropes_to_place + 1
		end
		local newnode = {name = stackname}
		if ropes_to_place == 1 then
			minetest.set_node(new_rope_nodes[1], newnode)
		else
			minetest.bulk_set_node(new_rope_nodes, newnode)
		end
		if not creative then
			itemstack:take_item(ropes_to_place)
		end

		-- Play placement sound manually
		if ropes_to_place > 0 then
			minetest.sound_play(ropesounds.place, {pos=start_pos}, true)
		end
	end

	return itemstack
end

function rope.remove(pos, oldnode, digger, rope_name)
	local num = 0
	local below = {x = pos.x, y = pos.y, z = pos.z}
	local digger_inv = digger:get_inventory()

	while minetest.get_node(below).name == rope_name do
		minetest.remove_node(below)
		below.y = below.y - 1
		num = num + 1
	end

	if num == 0 then return end

	-- Play dig sound manually
	minetest.sound_play(ropesounds.dug, {pos=pos}, true)

	-- Give/drop rope items
	local creative = minetest.is_creative_enabled(digger:get_player_name())
	if not creative or not digger_inv:contains_item("main", rope_name) then
		if creative then
			num = 1
		end
		local item = rope_name.." "..num
		local leftover = digger_inv:add_item("main", rope_name.." "..num)
		if not leftover:is_empty() then
			minetest.add_item(pos, leftover)
		end
	end

	return true
end

xdecor.register("rope", {
	description = S("Rope"),
	drawtype = "plantlike",
	walkable = false,
	climbable = true,
	groups = {dig_immediate = 3, flammable = 3},
	is_ground_content = false,
	tiles = {"xdecor_rope.png"},
	inventory_image = "xdecor_rope_inv.png",
	wield_image = "xdecor_rope_inv.png",
	selection_box = xdecor.pixelbox(8, {{3, 0, 3, 2, 8, 2}}),
	node_placement_prediction = "",
	on_place = rope.place,

	after_dig_node = function(pos, oldnode, oldmetadata, digger)
		pos = vector.new(pos.x, pos.y-1, pos.z)
		rope.remove(pos, oldnode, digger, "xdecor:rope")
	end,
	sounds = ropesounds,
})

-- Recipes

minetest.register_craft({
	output = "xdecor:rope",
	recipe = {
		{"farming:string"},
		{"farming:string"},
		{"farming:string"}
	}
})
