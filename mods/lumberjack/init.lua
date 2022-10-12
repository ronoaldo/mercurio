--[[

	lumberjack
	==========

	Copyright (C) 2018-2022 Joachim Stolberg

	LGPLv2.1+
	See LICENSE.txt for more information

	Mod to completely cut trees by destroying only one block.
	This mod allows to destroy the root block of the tree and the whole tree is felled and 
	alternatively moved to the player's inventory or dropped.
	
	To distinguish between "grown" trees and placed tree nodes, the attribute 
	'node.param1' is used to identify placed nodes.
	
	The number of necessary lumberjack points has to be configured via 'settingtypes.txt'
	
]]--

lumberjack = {}

-- Test MT 5.4 new string mode
local CLIP = minetest.features.use_texture_alpha_string_modes and "clip" or true
local S = minetest.get_translator("lumberjack")

local MY_PARAM1_VAL = 7  -- to identify placed nodes

-- Necessary number of points for dug trees and placed sapling to get lumberjack privs
local LUMBERJACK_TREE_POINTS = tonumber(minetest.settings:get("lumberjack_points")) or 400
local LUMBERJACK_SAPL_POINTS = math.floor(LUMBERJACK_TREE_POINTS / 6)
local DROP_ITEMS = minetest.settings:get_bool("lumberjack_drop_tree_items") == true

local lTrees = {} -- List of registered tree items

--
-- Check if used tool is some kind of axe and is used by a player
--
local function chopper_tool(digger)
	if digger and digger:is_player() then
		local tool = digger:get_wielded_item()
		if tool then
			local caps = tool:get_tool_capabilities()
			if caps.groupcaps and caps.groupcaps.choppy and caps.groupcaps.choppy.maxlevel then
				-- diamond axe returns 3
				return caps.groupcaps.choppy.maxlevel <= 3
			end
		end 
	end
	return false
end

--
-- Remove/add tree steps
--
local function remove_steps(pos)
	local pos1 = {x=pos.x-1, y=pos.y, z=pos.z-1}
	local pos2 = {x=pos.x+1, y=pos.y, z=pos.z+1}
	for _,pos in ipairs(minetest.find_nodes_in_area(pos1, pos2, "lumberjack:step")) do
		minetest.remove_node(pos)
	end
end

local function add_steps(pos, digger)
	local facedir = minetest.dir_to_facedir(digger:get_look_dir(), false)
	local dir = minetest.facedir_to_dir((facedir + 2) % 4)
	local newpos = vector.add(pos, dir)
	if minetest.get_node(newpos).name == "air" then
		minetest.add_node(newpos, {name="lumberjack:step", param2=facedir})
	end
end

local function on_punch(pos, node, puncher, pointed_thing)
	if chopper_tool(puncher) and node.param1 == 0 then  -- grown tree?
		if not minetest.is_protected(pos, puncher:get_player_name()) then
			add_steps(pos, puncher)
		end
	end
	minetest.node_punch(pos, node, puncher, pointed_thing)
end

--
-- tool wearing
--
local function add_wear(digger, node, num_nodes)
	local tool = digger:get_wielded_item()
	if tool then
		local caps = tool:get_tool_capabilities()
		if caps.groupcaps and caps.groupcaps.choppy then 
			local uses = caps.groupcaps.choppy.uses or 10
			uses = uses * 9
			if  minetest.global_exists("toolranks") then
				local itemmeta = tool:get_meta()
				local dugnodes = tonumber(itemmeta:get_string("dug")) or 0
				itemmeta:set_string("dug", dugnodes + num_nodes - 1)
				toolranks.new_afteruse(tool, digger, node, {wear = uses})
			end
			tool:add_wear(65535 * num_nodes / uses)
			digger:set_wielded_item(tool)
		end
	end 
end

--
-- Remove all tree nodes including steps in the given area
--
local function remove_items(pos1, pos2, name)
	local cnt = 0
	for _,pos in ipairs(minetest.find_nodes_in_area(pos1, pos2, name)) do
		minetest.remove_node(pos)
		remove_steps(pos)
		if DROP_ITEMS then
			minetest.add_item(pos, ItemStack(name))
		end
		cnt = cnt + 1
	end
	return cnt
end

--
-- Check for tree nodes on the next higher level
-- We have to check more than one level, because Ethereal allows stem gaps
--
local function is_top_tree_node(pos, name)
	local pos1 = {x=pos.x-1, y=pos.y+1, z=pos.z-1}
	local pos2 = {x=pos.x+1, y=pos.y+3, z=pos.z+1}
	for _,pos in ipairs(minetest.find_nodes_in_area(pos1, pos2, name)) do
		return false
	end
	return true
end

--
-- Check for the necessary number of points and grant lumberjack privs if level is reached
--

local function get_points(player)
	if player and player.is_player and player:is_player() then
		-- Test if we got an automatised tool like nodebreaker from pipeworks
		-- always allow lumberjack point with this workaroud
		if not player.get_meta then
			return -1,-1
		end
		local meta = player:get_meta()
		
		if not meta:contains("lumberjack_tree_points") then
			meta:set_int("lumberjack_tree_points", LUMBERJACK_TREE_POINTS)
		end
		if not meta:contains("lumberjack_sapl_points") then
			meta:set_int("lumberjack_sapl_points", LUMBERJACK_SAPL_POINTS)
		end
		
		local tree_points = meta:get_int("lumberjack_tree_points")
		local sapl_points = meta:get_int("lumberjack_sapl_points")
		
		return tree_points, sapl_points
	end
end

local function is_lumberjack(player, tree_points, sapl_points)
	if not tree_points or not sapl_points then
		return false
	elseif tree_points > 0 or sapl_points > 0 then
		return false
	elseif tree_points == 0 or sapl_points == 0 then
		local meta = player:get_meta()
		if not meta:contains("is_lumberjack") then
			meta:set_int("is_lumberjack", 1)
			local player_name = player:get_player_name()
			minetest.chat_send_player(player_name, S("You're a real lumberjack now!"))
			minetest.log("action", player_name .. " got lumberjack privs")
		end
	end
	return true
end

--
-- Maintain lumberjack points
--
local function after_dig_tree(digger)
	local tree_points, sapl_points = get_points(digger)
	if tree_points and digger.get_meta then
		tree_points = tree_points - 1
		local meta = digger:get_meta()
		meta:set_int("lumberjack_tree_points", tree_points)
		is_lumberjack(digger, tree_points, sapl_points)
	end
	return false
end

--
-- Decrement sapling points
--
local function after_place_sapling(pos, placer)
	local tree_points, sapl_points = get_points(placer)
	if sapl_points and placer.get_meta then
		sapl_points = sapl_points - 1
		local meta = placer:get_meta()
		meta:set_int("lumberjack_sapl_points", sapl_points)
		is_lumberjack(placer, tree_points, sapl_points)
	end
end	

--
-- Remove the complete tree and return the number of removed items
--
local function remove_tree(pos, radius, name)
	local level = 1
	local num_nodes = 0
	while true do
		-- We have to check more than one level, because Ethereal allows stem gaps
		local pos1 = {x=pos.x-radius, y=pos.y+level,   z=pos.z-radius}
		local pos2 = {x=pos.x+radius, y=pos.y+level+2, z=pos.z+radius}
		local cnt = remove_items(pos1, pos2, name)
		if cnt == 0 then break end
		num_nodes = num_nodes + cnt
		level = level + 3
	end
	return num_nodes
end


--
-- Add tree items to the players inventory
--
local function add_to_inventory(digger, name, len, pos)
	if not DROP_ITEMS then
		local inv = digger:get_inventory()
		local items = ItemStack(name .. " " .. len)
		if inv and items and inv:room_for_item("main", items) then
			inv:add_item("main", items)
		else
			minetest.item_drop(items, digger, pos)
		end
	end
end	

--
-- Remove the complete tree if the destroyed node belongs to a tree
--
local function after_dig_node(pos, oldnode, oldmetadata, digger)
	-- Player placed node?
	if oldnode.param1 ~= 0 then return end
	
	after_dig_tree(digger)
	remove_steps(pos)
	-- don't remove whole tree?
	if not digger or digger:get_player_control().sneak then	return end
	-- Get tree parameters
	local height_min = 3
	local radius = 0
	local registered_tree = lTrees[oldnode.name]
	if registered_tree then
		height_min = registered_tree.height_min or height_min
		radius = registered_tree.radius or radius
	end
	-- Or root nodes?
	local test_pos = {x=pos.x, y=pos.y+height_min-1, z=pos.z}
	if minetest.get_node(test_pos).name ~= oldnode.name then return	end
	-- Fell the tree
	local num_nodes = remove_tree(pos, radius, oldnode.name)
	add_to_inventory(digger, oldnode.name, num_nodes, pos)
	add_wear(digger, oldnode, num_nodes)
	minetest.log("action", digger:get_player_name().." fells "..oldnode.name..
					" ("..num_nodes.." items)".." at "..minetest.pos_to_string(pos))
	minetest.sound_play("tree_falling", {pos = pos, max_hear_distance = 16})
end	

--
-- Mark node as "placed by player"
--
local function on_construct(pos)
	local node = minetest.get_node(pos)
	if node then
		minetest.swap_node(pos, {name=node.name, param1=MY_PARAM1_VAL, param2=node.param2})		
	end
end

local function can_dig(pos, digger)
	if not digger then
		return true
	end
	local name = digger:get_player_name()
	if minetest.is_protected(pos, name) then
		return false
	end
	local node = minetest.get_node(pos)
	if node.param1 ~= 0 then 
		return true
	end
	local tree_points, sapl_points = get_points(digger)
	if is_lumberjack(digger, tree_points, sapl_points) then
		if chopper_tool(digger) then
			return true
		else
			minetest.chat_send_player(name, S("[Lumberjack Mod] You are using the wrong tool"))
			return false
		end
	end
	if is_top_tree_node(pos, node.name) then
		return true
	end
	minetest.chat_send_player(name, S("[Lumberjack Mod] From the top, please"))
	return false
end

minetest.register_node("lumberjack:step", {
	description = "Lumberjack Step",
	drawtype = "nodebox",
	tiles = {"lumberjack_steps.png"},
	node_box = {
		type = "fixed",
		fixed = {
			{  -0.5, -0.5, 0.49,  0.5,  0.5,  0.5},
		},
	},	
	paramtype2 = "facedir",
	is_ground_content = false,
	climbable = true,
	paramtype = "light",
	use_texture_alpha = CLIP,
	sunlight_propagates = true,
	walkable = false,
	pointable = false,
	drop = "",
	groups = {choppy = 2},
})


--
-- Register the tree node to the lumberjack mod.
-- 'tree_name' is the tree item name,, e.g. "default:tree"
-- 'sapling_name' is the tree sapling name, e.g. "default:sapling"
-- 'radius' is the range in nodes (+x/-x/+z/-z), where all available tree nodes will be removed.
-- 'stem_height_min' is the minimum number of tree nodes, to be a valid stem (and not a root item).
--
function lumberjack.register_tree(tree_name, sapling_name, radius, stem_height_min)
	
	-- check tree attributes
	local data = minetest.registered_nodes[tree_name]
	if data == nil then
		error("[lumberjack] "..tree_name.." is no valid item")
	end
	if data.after_dig_node then
		error("[lumberjack] "..tree_name.." has already an 'after_dig_node' function")
	end
	if data.on_construct then
		error("[lumberjack] "..tree_name.." has already an 'on_construct' function")
	end
	if data.can_dig then
		error("[lumberjack] "..tree_name.." has already a 'can_dig' function")
	end
	if not data.groups.choppy then
		error("[lumberjack] "..tree_name.." has no 'choppy' property")
	end
	
	-- check sapling attributes
	if minetest.registered_nodes[sapling_name].after_place_node then
		error("[lumberjack] "..sapling_name.." has already an 'after_place_node' function")
	end
	
	minetest.override_item(tree_name, {
			after_dig_node = after_dig_node, 
			on_construct = on_construct,
			can_dig = can_dig,
			on_punch = on_punch,
	})
	minetest.override_item(sapling_name, {
			after_place_node = after_place_sapling
	})

	lTrees[tree_name] = {radius=radius, height_min=stem_height_min, choppy=data.groups.choppy}
end

minetest.register_chatcommand("lumberjack", {
	description = S("Output your lumberjack points"),
	func = function(name, param)
		local tree_points, sapl_points = get_points(minetest.get_player_by_name(name))
		if tree_points > 0 and sapl_points > 0 then
			return true, S("You need further @1 tree and @2 sapling points.", tree_points, sapl_points)
		elseif tree_points > 0 then
			return true, S("You need further @1 tree points.", tree_points)
		elseif sapl_points > 0 then
			return true, S("You need further @1 sapling points.", sapl_points)
		else
			return true, S("You are already a lumberjack.")
		end
	end
})

minetest.register_chatcommand("set_lumberjack_points", {
	params = "<name> <tree-points>",
	description = S("Give a player lumberjack points"),
	privs = {server = true},
	func = function(name, param)
		local param_name, points = param:match("^(%S+)%s+(%d+)$")
		if param_name and points then
			local tree_points = tonumber(points) or 0
			local sapl_points = math.floor(tree_points / 6)
			local player = minetest.get_player_by_name(param_name)
			if player then
				local meta = player:get_meta()
				meta:set_int("lumberjack_tree_points", tree_points)
				meta:set_int("lumberjack_sapl_points", sapl_points)
				meta:set_string("is_lumberjack", "")
				return true, S("Player @1 now has @2 tree and @3 sapling points.", param_name, tree_points, sapl_points)
			end
			return true, S("Player @1 is unknown!", param_name)
		end
		return false
	end
})

if  minetest.global_exists("default") then
	lumberjack.register_tree("default:tree", "default:sapling", 1, 2)
	lumberjack.register_tree("default:jungletree", "default:junglesapling", 1, 5)
	lumberjack.register_tree("default:acacia_tree", "default:acacia_sapling", 2, 3)
	lumberjack.register_tree("default:aspen_tree", "default:aspen_sapling", 0, 5)
	lumberjack.register_tree("default:pine_tree", "default:pine_sapling", 0, 3)
end

if minetest.get_modpath("ethereal") and minetest.global_exists("ethereal") then 
	lumberjack.register_tree("ethereal:palm_trunk", "ethereal:palm_sapling", 1, 3)
	lumberjack.register_tree("ethereal:mushroom_trunk", "ethereal:mushroom_sapling", 1, 3)
	lumberjack.register_tree("ethereal:birch_trunk", "ethereal:birch_sapling", 0, 3)
	lumberjack.register_tree("ethereal:banana_trunk", "ethereal:banana_tree_sapling", 1, 3)
	lumberjack.register_tree("ethereal:willow_trunk", "ethereal:willow_sapling", 4, 3)
	lumberjack.register_tree("ethereal:frost_tree", "ethereal:frost_tree_sapling", 1, 3)
	lumberjack.register_tree("ethereal:sakura_trunk", "ethereal:sakura_sapling", 4, 3)
	lumberjack.register_tree("ethereal:yellow_trunk", "ethereal:yellow_tree_sapling", 3, 3)
end

if minetest.get_modpath("moretrees") and minetest.global_exists("moretrees") then
	lumberjack.register_tree("moretrees:beech_trunk", "moretrees:beech_sapling", 1, 3)
	lumberjack.register_tree("moretrees:apple_tree_trunk", "moretrees:apple_tree_sapling", 8, 3)
	lumberjack.register_tree("moretrees:oak_trunk", "moretrees:oak_sapling", 13,5 )
	lumberjack.register_tree("moretrees:sequoia_trunk", "moretrees:sequoia_sapling", 9, 3)
	lumberjack.register_tree("moretrees:birch_trunk", "moretrees:birch_sapling", 12,5)
	lumberjack.register_tree("moretrees:palm_trunk", "moretrees:palm_sapling", 5, 3)
--	lumberjack.register_tree("moretrees:palm_fruit_trunk", "moretrees:palm_sapling", 5, 3)
	lumberjack.register_tree("moretrees:spruce_trunk", "moretrees:spruce_sapling", 1, 3)
	lumberjack.register_tree("moretrees:pine_trunk", "moretrees:pine_sapling", 0, 3)
	lumberjack.register_tree("moretrees:willow_trunk", "moretrees:willow_sapling",1,3)
	lumberjack.register_tree("moretrees:rubber_tree_trunk", "moretrees:rubber_tree_sapling", 7, 3)
--	lumberjack.register_tree("moretrees:jungletree_trunk", "moretrees:jungletree_sapling", 1, 5) -- crashes
	lumberjack.register_tree("moretrees:fir_trunk", "moretrees:fir_sapling", 5, 3) -- below leaves by 5
end
