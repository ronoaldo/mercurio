
-- translation

local S = core.get_translator("protector")
local F = core.formspec_escape

-- MineClone support

local mcl = core.get_modpath("mcl_core")
local mcf = core.get_modpath("mcl_formspec")

-- Are crafts enabled?

local protector_crafts = core.settings:get_bool("protector_crafts") ~= false

-- Protected Chest

local chest_size = mcl and (9 * 3) or (8 * 4)

core.register_node("protector:chest", {
	description = S("Protected Chest"),
	tiles = {
		"default_chest_top.png", "default_chest_top.png",
		"default_chest_side.png", "default_chest_side.png",
		"default_chest_side.png", "default_chest_front.png^protector_logo.png"
	},
	paramtype2 = "facedir",
	groups = {dig_immediate = 2, unbreakable = 1},
	legacy_facedir_simple = true,
	is_ground_content = false,
	sounds = default.node_sound_wood_defaults(),

	on_construct = function(pos)

		local meta = core.get_meta(pos)
		local inv = meta:get_inventory()

		meta:set_string("infotext", S("Protected Chest"))
		meta:set_string("name", S("Protected Chest"))
		inv:set_size("main", chest_size)
	end,

	can_dig = function(pos,player)

		local meta = core.get_meta(pos)
		local inv = meta:get_inventory()

		if inv:is_empty("main") then

			if not core.is_protected(pos, player:get_player_name()) then
				return true
			end
		end
	end,

	on_metadata_inventory_put = function(pos, listname, index, stack, player)

		core.log("action", player:get_player_name()
			.. " moves stuff to protected chest at " .. core.pos_to_string(pos))
	end,

	on_metadata_inventory_take = function(pos, listname, index, stack, player)

		core.log("action", player:get_player_name()
			.. " takes stuff from protected chest at " .. core.pos_to_string(pos))
	end,

	on_metadata_inventory_move = function(
			pos, from_list, from_index, to_list, to_index, count, player)

		core.log("action", player:get_player_name()
			.. " moves stuff inside protected chest at " .. core.pos_to_string(pos))
	end,

	allow_metadata_inventory_put = function(pos, listname, index, stack, player)

		if core.is_protected(pos, player:get_player_name()) then
			return 0
		end

		return stack:get_count()
	end,

	allow_metadata_inventory_take = function(pos, listname, index, stack, player)

		if core.is_protected(pos, player:get_player_name()) then
			return 0
		end

		return stack:get_count()
	end,

	allow_metadata_inventory_move = function(
			pos, from_list, from_index, to_list, to_index, count, player)

		if core.is_protected(pos, player:get_player_name()) then
			return 0
		end

		return count
	end,

	on_rightclick = function(pos, node, clicker)

		if core.is_protected(pos, clicker:get_player_name()) then return end

		local meta = core.get_meta(pos) ; if not meta then return end

		local spos = pos.x .. "," .. pos.y .. "," ..pos.z
		local formspec

		-- mineclone support
		if mcl and mcf then

			formspec = "size[9,8.75]"
			.. "label[0,0;" .. core.formspec_escape(
					core.colorize("#313131", "Protected Chest")) .. "]"
			.. "list[nodemeta:" .. spos .. ";main;0,0.5;9,3;]"
			.. mcl_formspec.get_itemslot_bg(0,0.5,9,3)
			.. "image_button[3.0,3.5;1.05,0.8;protector_up_icon.png;protect_up;]"
			.. "image_button[4.0,3.5;1.05,0.8;protector_down_icon.png;protect_down;]"
			.. "label[0,4.0;" .. core.formspec_escape(
					core.colorize("#313131", "Inventory")) .. "]"
			.. "list[current_player;main;0,4.5;9,3;9]"
			.. mcl_formspec.get_itemslot_bg(0,4.5,9,3)
			.. "list[current_player;main;0,7.74;9,1;]"
			.. mcl_formspec.get_itemslot_bg(0,7.74,9,1)
			.. "listring[nodemeta:" .. spos .. ";main]"
			.. "listring[current_player;main]"

		else -- default formspec

			formspec = "size[8,9]"
			.. "list[nodemeta:".. spos .. ";main;0,0.3;8,4;]"

			.. "image_button[-0.01,4.26;1.05,0.8;protector_up_icon.png;protect_up;]"
			.. "image_button[0.98,4.26;1.05,0.8;protector_down_icon.png;protect_down;]"
			.. "tooltip[protect_up;" .. S("To Chest") .. "]"
			.. "tooltip[protect_down;" .. S("To Inventory") .. "]"

			.. "field[2.3,4.8;4,0.25;protect_name;;"
			.. meta:get_string("name") .. "]"
			.. "button[5.99,4.5;2.05,0.25;protect_rename;" .. S("Rename") .. "]"

			.. "list[current_player;main;0,5;8,1;]"
			.. "list[current_player;main;0,6.08;8,3;8]"
			.. "listring[nodemeta:" .. spos .. ";main]"
			.. "listring[current_player;main]"
		end

		core.show_formspec(clicker:get_player_name(),
				"protector:chest_" .. core.pos_to_string(pos), formspec)
	end,

	on_blast = function() end
})

-- Container transfer helper

local function to_from(src, dst)

	local stack, item, leftover
	local size = dst:get_size("main")

	for i = 1, size do

		stack = src:get_stack("main", i)
		item = stack:get_name()

		if item ~= "" and dst:room_for_item("main", item) then

			leftover = dst:add_item("main", stack)

			if leftover and not leftover:is_empty() then
				src:set_stack("main", i, leftover)
			else
				src:set_stack("main", i, nil)
			end
		end
	end
end

-- Protected Chest formspec buttons

core.register_on_player_receive_fields(function(player, formname, fields)

	if string.sub(formname, 0, 16) ~= "protector:chest_" then return end

	local pos_s = string.sub(formname, 17)
	local pos = core.string_to_pos(pos_s)

	if core.is_protected(pos, player:get_player_name()) then return end

	local meta = core.get_meta(pos) ; if not meta then return end
	local chest_inv = meta:get_inventory() ; if not chest_inv then return end
	local player_inv = player:get_inventory()

	-- copy contents of player inventory to chest
	if fields.protect_up then

		to_from(player_inv, chest_inv)

	-- copy contents of chest to player inventory
	elseif fields.protect_down then

		to_from(chest_inv, player_inv)

	elseif fields.protect_name or fields.protect_rename then

		-- change chest infotext to display name
		if fields.protect_name ~= "" then

			if fields.protect_name ~= string.match(fields.protect_name, "[%w%s_-]+")
			or fields.protect_name:len() > 35 then
				return
			end

			meta:set_string("name", fields.protect_name)
			meta:set_string("infotext", fields.protect_name)
		else
			meta:set_string("name", S("Protected Chest"))
			meta:set_string("infotext", S("Protected Chest"))
		end

	end
end)

-- Protected Chest recipes

if protector_crafts then

	if mcl then

		core.register_craft({
			output = "protector:chest",
			recipe = { {"mcl_chests:chest", "mcl_core:gold_ingot"} }
		})
	else
		core.register_craft({
			output = "protector:chest",
			recipe = {
				{"group:wood", "group:wood", "group:wood"},
				{"group:wood", "default:copper_ingot", "group:wood"},
				{"group:wood", "group:wood", "group:wood"}
			}
		})

		core.register_craft({
			output = "protector:chest",
			recipe = { {"default:chest", "default:copper_ingot"} }
		})
	end
end
