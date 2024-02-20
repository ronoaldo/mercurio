local workbench = {}
local registered_cuttable_nodes = {}
local special_cuts = {}

screwdriver = screwdriver or {}
local min, ceil = math.min, math.ceil
local S = minetest.get_translator("xdecor")
local FS = function(...) return minetest.formspec_escape(S(...)) end


-- Nodeboxes definitions
workbench.defs = {
	-- Name Yield Nodeboxes (X Y Z W H L)  Description
	{"nanoslab",    16, {{ 0, 0,  0, 8,  1, 8  }}, S("Nanoslab")},
	{"micropanel",  16, {{ 0, 0,  0, 16, 1, 8  }}, S("Micropanel")},
	{"microslab",   8,  {{ 0, 0,  0, 16, 1, 16 }}, S("Microslab")},
	{"thinstair",   8,  {{ 0, 7,  0, 16, 1, 8  },
			{ 0, 15, 8, 16, 1, 8  }}, S("Thin Stair")},
	{"cube",        4,  {{ 0, 0,  0, 8,  8, 8 }}, S("Cube")},
	{"panel",       4,  {{ 0, 0,  0, 16, 8, 8 }}, S("Panel")},
	{"slab",        2,  nil, S("Slab") },
	{"doublepanel", 2,  {{ 0, 0,  0, 16, 8, 8  },
			{ 0, 8,  8, 16, 8, 8  }}, S("Double Panel")},
	{"halfstair",   2,  {{ 0, 0,  0, 8,  8, 16 },
			{ 0, 8,  8, 8,  8, 8  }}, S("Half-Stair")},
	{"stair_outer", 1,  nil, nil},
	{"stair",       1,  nil, S("Stair")},
	{"stair_inner", 1,  nil, nil},
}

local custom_repairable = {}
function xdecor:register_repairable(item)
	custom_repairable[item] = true
end

-- Tools allowed to be repaired
function workbench:repairable(stack)
	-- Explicitly registeded as repairable: Overrides everything else
	if custom_repairable[stack] then
		return true
	end
	-- no repair if non-tool
	if not minetest.registered_tools[stack] then
		return false
	end
	-- no repair if disable_repair group
	if minetest.get_item_group(stack, "disable_repair") == 1 then
		return false
	end
	return true
end

-- Returns true if item can be cut into basic stairs and slabs
function workbench:cuttable(itemname)
	local split = string.split(itemname, ":")
	if split and split[1] and split[2] then
		if minetest.registered_nodes["stairs:stair_"..split[2]] ~= nil or
		minetest.registered_nodes["stairs:slab_"..split[2]] ~= nil then
			return true
		end
	end
	if registered_cuttable_nodes[itemname] == true then
		return true
	end
	return false
end

-- Returns true if item can be cut into xdecor extended shapes (thinslab, panel, cube, etc.)
function workbench:cuttable_extended(itemname)
	return registered_cuttable_nodes[itemname] == true
end

-- method to allow other mods to check if an item is repairable
function xdecor:is_repairable(stack)
	return workbench:repairable(stack)
end

function workbench:get_output(inv, input, name)
	local output = {}
	local extended = workbench:cuttable_extended(input:get_name())
	for i = 1, #self.defs do
		local nbox = self.defs[i]
		local cuttype = nbox[1]
		local count = nbox[2] * input:get_count()
		local max_count = input:get_stack_max()
		if count > max_count then
			-- Limit count to maximum multiple to avoid waste
			count = nbox[2] * math.floor(max_count / nbox[2])
		end
		local was_cut = false
		if extended or nbox[3] == nil then
			local item = name .. "_" .. cuttype

			item = nbox[3] and item or "stairs:" .. cuttype .. "_" .. name:match(":(.*)")
			if minetest.registered_items[item] then
				output[i] = item .. " " .. count
				was_cut = true
			end
		end
		if not was_cut and special_cuts[input:get_name()] ~= nil then
			local cut = special_cuts[input:get_name()][cuttype]
			if cut then
				output[i] = cut .. " " .. count
				was_cut = true
			end
		end
	end

	inv:set_list("forms", output)
end

function workbench:register_special_cut(nodename, cutlist)
	registered_cuttable_nodes[nodename] = true
	special_cuts[nodename] = cutlist
end

local main_fs = "label[0.9,1.23;"..FS("Cut").."]"
	.."label[0.9,2.23;"..FS("Repair").."]"
	..[[ box[-0.05,1;2.05,0.9;#555555]
	box[-0.05,2;2.05,0.9;#555555] ]]
	.."button[0,0;2,1;craft;"..FS("Crafting").."]"
	.."button[2,0;2,1;storage;"..FS("Storage").."]"
	..[[ image[3,1;1,1;gui_arrow.png]
	image[0,1;1,1;worktable_saw.png]
	image[0,2;1,1;worktable_anvil.png]
	image[3,2;1,1;hammer_layout.png]
	list[context;input;2,1;1,1;]
	list[context;tool;2,2;1,1;]
	list[context;hammer;3,2;1,1;]
	list[context;forms;4,0;4,3;]
	listring[current_player;main]
	listring[context;tool]
	listring[current_player;main]
	listring[context;hammer]
	listring[current_player;main]
	listring[context;forms]
	listring[current_player;main]
	listring[context;input]
]]

local crafting_fs = "image[5,1;1,1;gui_furnace_arrow_bg.png^[transformR270]"
	.."button[0,0;1.5,1;back;< "..FS("Back").."]"
	..[[ list[current_player;craft;2,0;3,3;]
	list[current_player;craftpreview;6,1;1,1;]
	listring[current_player;main]
	listring[current_player;craft]
]]

local storage_fs = "list[context;storage;0,1;8,2;]"
	.."button[0,0;1.5,1;back;< "..FS("Back").."]"
	..[[listring[context;storage]
	listring[current_player;main]
]]

local formspecs = {
	-- Main formspec
	main_fs,

	-- Crafting formspec
	crafting_fs,

	-- Storage formspec
	storage_fs,
}

function workbench:set_formspec(meta, id)
	meta:set_string("formspec",
		"size[8,7;]list[current_player;main;0,3.25;8,4;]" ..
		formspecs[id] .. xdecor.xbg .. default.get_hotbar_bg(0,3.25))
end

function workbench.construct(pos)
	local meta = minetest.get_meta(pos)
	local inv = meta:get_inventory()

	inv:set_size("tool", 1)
	inv:set_size("input", 1)
	inv:set_size("hammer", 1)
	inv:set_size("forms", 4*3)
	inv:set_size("storage", 8*2)

	meta:set_string("infotext", S("Work Bench"))
	workbench:set_formspec(meta, 1)
end

function workbench.fields(pos, _, fields)
	if fields.quit then return end

	local meta = minetest.get_meta(pos)
	local id = fields.back and 1 or fields.craft and 2 or fields.storage and 3
	if not id then return end

	workbench:set_formspec(meta, id)
end

function workbench.dig(pos)
	local inv = minetest.get_meta(pos):get_inventory()
	return inv:is_empty("input") and inv:is_empty("hammer") and
	       inv:is_empty("tool") and inv:is_empty("storage")
end

function workbench.blast(pos)
	local drops = xdecor.get_inventory_drops(pos, {"input", "hammer", "tool", "storage"})
	minetest.remove_node(pos)
	return drops
end

function workbench.timer(pos)
	local timer = minetest.get_node_timer(pos)
	local inv = minetest.get_meta(pos):get_inventory()
	local tool = inv:get_stack("tool", 1)
	local hammer = inv:get_stack("hammer", 1)

	if tool:is_empty() or hammer:is_empty() or tool:get_wear() == 0 then
		timer:stop()
		return
	end

	-- Tool's wearing range: 0-65535; 0 = new condition
	tool:add_wear(-500)
	hammer:add_wear(700)

	inv:set_stack("tool", 1, tool)
	inv:set_stack("hammer", 1, hammer)

	return true
end

function workbench.allow_put(pos, listname, index, stack, player)
	local stackname = stack:get_name()
	if (listname == "tool" and workbench:repairable(stackname)) or
	   (listname == "input" and workbench:cuttable(stackname)) or
	   (listname == "hammer" and stackname == "xdecor:hammer") or
	    listname == "storage" then
		return stack:get_count()
	end

	return 0
end

function workbench.on_put(pos, listname, index, stack, player)
	local inv = minetest.get_meta(pos):get_inventory()
	if listname == "input" then
		local input = inv:get_stack("input", 1)
		workbench:get_output(inv, input, stack:get_name())
	elseif listname == "tool" or listname == "hammer" then
		local timer = minetest.get_node_timer(pos)
		timer:start(3.0)
	end
end

function workbench.allow_move(pos, from_list, from_index, to_list, to_index, count, player)
	if (to_list == "storage" and from_list ~= "forms") then
		return count
	elseif (to_list == "hammer" and from_list == "tool") or (to_list == "tool" and from_list == "hammer") then
		local inv = minetest.get_inventory({type="node", pos=pos})
		local stack = inv:get_stack(from_list, from_index)
		if stack:get_name() == "xdecor:hammer" then
			return count
		end
	end
	return 0
end

function workbench.on_move(pos, from_list, from_index, to_list, to_index, count, player)
	local meta = minetest.get_meta(pos)
	local inv = meta:get_inventory()
	local from_stack = inv:get_stack(from_list, from_index)
	local to_stack = inv:get_stack(to_list, to_index)

	workbench.on_take(pos, from_list, from_index, from_stack, player)
	workbench.on_put(pos, to_list, to_index, to_stack, player)
end

function workbench.allow_take(pos, listname, index, stack, player)
	return stack:get_count()
end

function workbench.on_take(pos, listname, index, stack, player)
	local inv = minetest.get_meta(pos):get_inventory()
	local input = inv:get_stack("input", 1)
	local inputname = input:get_name()
	local stackname = stack:get_name()

	if listname == "input" then
		if stackname == inputname and workbench:cuttable(inputname) then
			workbench:get_output(inv, input, stackname)
		else
			inv:set_list("forms", {})
		end
	elseif listname == "forms" then
		local fromstack = inv:get_stack(listname, index)
		if not fromstack:is_empty() and fromstack:get_name() ~= stackname then
			local player_inv = player:get_inventory()
			if player_inv:room_for_item("main", fromstack) then
				player_inv:add_item("main", fromstack)
			end
		end

		input:take_item(ceil(stack:get_count() / workbench.defs[index][2]))
		inv:set_stack("input", 1, input)
		workbench:get_output(inv, input, inputname)
	end
end

xdecor.register("workbench", {
	description = S("Work Bench"),
	_tt_help = S("For cutting blocks, repairing tools with a hammer, crafting and storing items"),
	groups = {cracky = 2, choppy = 2, oddly_breakable_by_hand = 1},
	is_ground_content = false,
	sounds = default.node_sound_wood_defaults(),
	tiles = {
		"xdecor_workbench_top.png","xdecor_workbench_top.png",
		"xdecor_workbench_sides.png", "xdecor_workbench_sides.png",
		"xdecor_workbench_front.png", "xdecor_workbench_front.png"
	},
	on_rotate = screwdriver.rotate_simple,
	can_dig = workbench.dig,
	on_blast = workbench.blast,
	on_timer = workbench.timer,
	on_construct = workbench.construct,
	on_receive_fields = workbench.fields,
	on_metadata_inventory_put = workbench.on_put,
	on_metadata_inventory_take = workbench.on_take,
	on_metadata_inventory_move = workbench.on_move,
	allow_metadata_inventory_put = workbench.allow_put,
	allow_metadata_inventory_take = workbench.allow_take,
	allow_metadata_inventory_move = workbench.allow_move
})


minetest.register_on_mods_loaded(function()
local cuttable_nodes = {}

-- Nodes allowed to be cut:
-- Only the regular, solid blocks without metas or explosivity
-- from the xdecor or default mods.
for nodename, def in pairs(minetest.registered_nodes) do
	local nodenamesplit = string.split(nodename, ":")
	local modname = nodenamesplit[1]
	if (modname == "xdecor" or modname == "default") and xdecor.stairs_valid_def(def) then
		cuttable_nodes[#cuttable_nodes + 1] = nodename
		registered_cuttable_nodes[nodename] = true
	end
end

for _, d in ipairs(workbench.defs) do
for i = 1, #cuttable_nodes do
	local node = cuttable_nodes[i]
	local mod_name, item_name = node:match("^(.-):(.*)")
	local def = minetest.registered_nodes[node]

	if item_name and d[3] then
		local groups = {}
		local tiles
		groups.not_in_creative_inventory = 1

		for k, v in pairs(def.groups) do
			if k ~= "wood" and k ~= "stone" and k ~= "level" then
				groups[k] = v
			end
		end

		if def.tiles then
			if #def.tiles > 1 and (def.drawtype:sub(1,5) ~= "glass") then
				tiles = def.tiles
			else
				tiles = {def.tiles[1]}
			end
		else
			tiles = {def.tile_images[1]}
		end

		-- Erase `tileable_vertical=false` from tiles because it
		-- lead to buggy textures (e.g. with default:permafrost_with_moss)
		for t=1, #tiles do
			if type(tiles[t]) == "table" and tiles[t].tileable_vertical == false then
				tiles[t].tileable_vertical = nil
			end
		end

		local custom_tiles = xdecor.glasscuts[node]
		if custom_tiles then
			if not custom_tiles.nanoslab then
				custom_tiles.nanoslab = custom_tiles.cube
			end
			if not custom_tiles.micropanel then
				custom_tiles.micropanel = custom_tiles.micropanel
			end
			if not custom_tiles.doublepanel then
				custom_tiles.doublepanel = custom_tiles.panel
			end
		end

		if not minetest.registered_nodes["stairs:slab_" .. item_name] then
			if custom_tiles and (custom_tiles.slab or custom_tiles.stair) then
				if custom_tiles.stair then
					stairs.register_stair(item_name, node,
						groups, custom_tiles.stair, S("@1 Stair", def.description),
						def.sounds)
					stairs.register_stair_inner(item_name, node,
						groups, custom_tiles.stair_inner, "", def.sounds, nil, S("Inner @1 Stair", def.description))
					stairs.register_stair_outer(item_name, node,
						groups, custom_tiles.stair_outer, "", def.sounds, nil, S("Outer @1 Stair", def.description))
				end
				if custom_tiles.slab then
					stairs.register_slab(item_name, node,
						groups, custom_tiles.slab, S("@1 Slab", def.description),
						def.sounds)
				end
			else
				stairs.register_stair_and_slab(item_name, node,
					groups, tiles,
					S("@1 Stair", def.description),
					S("@1 Slab", def.description),
					def.sounds, nil,
					S("Inner @1 Stair", def.description),
					S("Outer @1 Stair", def.description))
			end
		end

		local cutname = d[1]
		local tiles_special_cut
		if custom_tiles and custom_tiles[cutname] then
			tiles_special_cut = custom_tiles[cutname]
		else
			tiles_special_cut = tiles
		end

		minetest.register_node(":" .. node .. "_" .. cutname, {
			-- @1: Base node description (e.g. "Stone"); @2: modifier (e.g. "Nanoslab")
			description = S("@1 @2", def.description, d[4]),
			paramtype = "light",
			paramtype2 = "facedir",
			drawtype = "nodebox",
			sounds = def.sounds,
			tiles = tiles_special_cut,
			use_texture_alpha = def.use_texture_alpha,
			groups = groups,
			is_ground_content = def.is_ground_content,
			node_box = xdecor.pixelbox(16, d[3]),
			sunlight_propagates = true,
			on_place = minetest.rotate_node
		})

	elseif item_name and mod_name then
		minetest.register_alias_force(
			("%s:%s_innerstair"):format(mod_name, item_name),
			("stairs:stair_inner_%s"):format(item_name)
		)
		minetest.register_alias_force(
			("%s:%s_outerstair"):format(mod_name, item_name),
			("stairs:stair_outer_%s"):format(item_name)
		)
	end
end
end
end)

-- Craft items

minetest.register_tool("xdecor:hammer", {
	description = S("Hammer"),
	_tt_help = S("Repairs tools at the work bench"),
	inventory_image = "xdecor_hammer.png",
	wield_image = "xdecor_hammer.png",
	on_use = function() do
		return end
	end
})

-- Recipes

minetest.register_craft({
	output = "xdecor:hammer",
	recipe = {
		{"default:steel_ingot", "group:stick", "default:steel_ingot"},
		{"", "group:stick", ""}
	}
})

minetest.register_craft({
	output = "xdecor:workbench",
	recipe = {
		{"group:wood", "group:wood"},
		{"group:wood", "group:wood"}
	}
})

-- Special cuts for cushion block and cabinet
workbench:register_special_cut("xdecor:cushion_block", { slab = "xdecor:cushion" })
workbench:register_special_cut("xdecor:cabinet", { slab = "xdecor:cabinet_half" })
