
-- default support (for use with MineClone2 and other [games]

if not core.global_exists("default") then

	default = {
		node_sound_stone_defaults = function(table) return {} end,
		node_sound_wood_defaults = function(table) return {} end,
		node_sound_metal_defaults = function(table) return {} end,
		gui_bg = "", gui_bg_img = "", gui_slots = ""
	}
end

if core.get_modpath("mcl_sounds") then
	default.node_sound_stone_defaults = mcl_sounds.node_sound_stone_defaults
	default.node_sound_wood_defaults = mcl_sounds.node_sound_wood_defaults
	default.node_sound_metal_defaults = mcl_sounds.node_sound_metal_defaults
end

-- modpath, formspec helper and translator

local MP = core.get_modpath(core.get_current_modname())
local F = core.formspec_escape
local S = core.get_translator("protector")

-- global table

protector = {
	mod = "redo",
	max_shares = 12,
	radius = tonumber(core.settings:get("protector_radius")) or 5
}

-- radius limiter (minetest cannot handle node volume of more than 4096000)

if protector.radius > 30 then protector.radius = 30 end

-- playerfactions check

local factions_available = core.global_exists("factions")

if factions_available then protector.max_shares = 8 end

-- localize math

local math_floor, math_pi = math.floor, math.pi

-- settings

local protector_flip = core.settings:get_bool("protector_flip") or false
local protector_hurt = tonumber(core.settings:get("protector_hurt")) or 0
local protector_spawn = tonumber(core.settings:get("protector_spawn")
	or core.settings:get("protector_pvp_spawn")) or 0
local protector_show = tonumber(core.settings:get("protector_show_interval")) or 5
local protector_recipe = core.settings:get_bool("protector_recipe") ~= false
local protector_msg = core.settings:get_bool("protector_msg") ~= false

-- get static spawn position

local statspawn = core.string_to_pos(core.settings:get("static_spawnpoint"))
		or {x = 0, y = 2, z = 0}

-- return list of members as a table

local function get_member_list(meta)

	return meta:get_string("members"):split(" ")
end

-- write member list table in protector meta as string

local function set_member_list(meta, list)

	meta:set_string("members", table.concat(list, " "))
end

-- check for owner name

local function is_owner(meta, name)

	return name == meta:get_string("owner")
end

-- check for member name

local function is_member(meta, name)

	if factions_available and meta:get_int("faction_members") == 1 then

		if factions.version == nil then

			-- backward compatibility
			if factions.get_player_faction(name) ~= nil
			and factions.get_player_faction(meta:get_string("owner")) ==
					factions.get_player_faction(name) then
				return true
			end
		else
			-- is member if player and owner share at least one faction
			local player_factions = factions.get_player_factions(name)
			local owner = meta:get_string("owner")

			if player_factions ~= nil and player_factions ~= false then

				for _, f in ipairs(player_factions) do

					if factions.player_is_in_faction(f, owner) then return true end
				end
			end
		end
	end

	for _, n in pairs(get_member_list(meta)) do

		if n == name then return true end
	end

	return false
end

-- add player name to table as member

local function add_member(meta, name)

	-- Validate player name for MT compliance
	if name ~= string.match(name, "[%w_-]+") then return end

	-- Constant (20) defined by player.h
	if name:len() > 25 then return end

	-- does name already exist?
	if is_owner(meta, name) or is_member(meta, name) then return end

	local list = get_member_list(meta)

	if #list >= protector.max_shares then return end

	table.insert(list, name)

	set_member_list(meta, list)
end

-- remove player name from table

local function del_member(meta, name)

	local list = get_member_list(meta)

	for i, n in pairs(list) do

		if n == name then
			table.remove(list, i) ; break
		end
	end

	set_member_list(meta, list)
end

-- protector interface

local function protector_formspec(meta)

	local formspec = "size[8,7]"
		.. default.gui_bg
		.. default.gui_bg_img
		.. "label[2.5,0;" .. F(S("-- Protector interface --")) .. "]"
		.. "label[0,1;" .. F(S("PUNCH node to show protected area")) .. "]"
		.. "label[0,2;" .. F(S("Members:")) .. "]"
		.. "button_exit[2.5,6.2;3,0.5;close_me;" .. F(S("Close")) .. "]"
		.. "field_close_on_enter[protector_add_member;false]"

	local members = get_member_list(meta)
	local i = 0
	local checkbox_faction = false

	-- Display the checkbox only if the owner is member of at least 1 faction
	if factions_available then

		if factions.version == nil then

			-- backward compatibility
			if factions.get_player_faction(meta:get_string("owner")) then
				checkbox_faction = true
			end
		else
			local player_factions = factions.get_player_factions(meta:get_string("owner"))

			if player_factions ~= nil and type(player_factions) == "table"
			and #player_factions >= 1 then
				checkbox_faction = true
			end
		end
	end

	if checkbox_faction then

		formspec = formspec .. "checkbox[0,5;faction_members;"
			.. F(S("Allow faction access"))
			.. ";" .. (meta:get_int("faction_members") == 1 and
					"true" or "false") .. "]"
	end

	for n = 1, #members do

		if i < protector.max_shares then

			-- show username
			formspec = formspec .. "button[" .. (i % 4 * 2)
			.. "," .. math_floor(i / 4 + 3)
			.. ";1.5,.5;protector_member;" .. F(members[n]) .. "]"

			-- username remove button
			.. "button[" .. (i % 4 * 2 + 1.25) .. ","
			.. math_floor(i / 4 + 3)
			.. ";.75,.5;protector_del_member_" .. F(members[n]) .. ";X]"
		end

		i = i + 1
	end

	if i < protector.max_shares then

		-- user name entry field
		formspec = formspec .. "field[" .. (i % 4 * 2 + 1 / 3) .. ","
		.. (math_floor(i / 4 + 3) + 1 / 3)
		.. ";1.433,.5;protector_add_member;;]"

		-- username add button
		.."button[" .. (i % 4 * 2 + 1.25) .. ","
		.. math_floor(i / 4 + 3) .. ";.75,.5;protector_submit;+]"
	end

	return formspec
end

-- check if pos is inside a protected spawn area

local function inside_spawn(pos, radius)

	if protector_spawn <= 0 then return false end

	if  pos.x < statspawn.x + radius and pos.x > statspawn.x - radius
	and pos.y < statspawn.y + radius and pos.y > statspawn.y - radius
	and pos.z < statspawn.z + radius and pos.z > statspawn.z - radius then

		return true
	end
end

-- show protection message if enabled

local function show_msg(player_name, msg)

	-- if messages disabled or no player name provided
	if protector_msg == false or not player_name or player_name == "" then return end

	core.chat_send_player(player_name, msg)
end

-- Infolevel:
-- 0 for no info
-- 1 for "This area is owned by <owner> !" if you can't dig
-- 2 for "This area is owned by <owner>.
-- 3 for checking protector overlaps

function protector.can_dig(r, pos, digger, onlyowner, infolevel)

	if not digger or not pos then return false end

	-- protector_bypass privileged users can override protection
	if infolevel == 1
	and core.check_player_privs(digger, {protection_bypass = true}) then
		return true
	end

	-- infolevel 3 is only used to bypass priv check, change to 1 now
	if infolevel == 3 then infolevel = 1 end

	-- is spawn area protected ?
	if inside_spawn(pos, protector_spawn) then

		show_msg(digger, S("Spawn @1 has been protected up to a @2 block radius.",
				core.pos_to_string(statspawn), protector_spawn))

		return false
	end

	-- find the protector nodes
	local pos = core.find_nodes_in_area(
			{x = pos.x - r, y = pos.y - r, z = pos.z - r},
			{x = pos.x + r, y = pos.y + r, z = pos.z + r},
			{"protector:protect", "protector:protect2", "protector:protect_hidden"})

	local meta, owner, members

	for n = 1, #pos do

		meta = core.get_meta(pos[n])
		owner = meta:get_string("owner") or ""
		members = meta:get_string("members") or ""

		-- node change and digger isn't owner
		if infolevel == 1 and owner ~= digger then

			-- and you aren't on the member list
			if onlyowner or not is_member(meta, digger) then

				show_msg(digger, S("This area is owned by @1", owner) .. "!")

				return false
			end
		end

		-- when using protector as tool, show protector information
		if infolevel == 2 then

			core.chat_send_player(digger,
					S("This area is owned by @1", owner) .. ".")

			core.chat_send_player(digger,
					S("Protection located at: @1", core.pos_to_string(pos[n])))

			if members ~= "" then
				core.chat_send_player(digger, S("Members: @1.", members))
			end

			return false
		end

	end

	-- show when you can build on unprotected area
	if infolevel == 2 then

		if #pos < 1 then
			core.chat_send_player(digger, S("This area is not protected."))
		end

		core.chat_send_player(digger, S("You can build here."))
	end

	return true
end

-- add protector hurt and flip to protection violation function

core.register_on_protection_violation(function(pos, name)

	local player = core.get_player_by_name(name)

	if player and player:is_player() then

		-- hurt player if protection violated
		if protector_hurt > 0 and player:get_hp() > 0 then

			-- This delay fixes item duplication bug (thanks luk3yx)
			core.after(0.1, function(player)
				player:set_hp(player:get_hp() - protector_hurt)
			end, player)
		end

		-- flip player when protection violated
		if protector_flip then

			-- yaw + 180°
			local yaw = player:get_look_horizontal() + math_pi

			if yaw > 2 * math_pi then
				yaw = yaw - 2 * math_pi
			end

			player:set_look_horizontal(yaw)

			-- invert pitch
			player:set_look_vertical(-player:get_look_vertical())

			-- if digging below player, move up to avoid falling through hole
			local pla_pos = player:get_pos()

			if pos.y < pla_pos.y then
				player:set_pos({x = pla_pos.x, y = pla_pos.y + 0.8, z = pla_pos.z})
			end
		end
	end
end)

-- backup old is_protected function

local old_is_protected = core.is_protected

-- check for protected area, return true if protected and digger isn't on list

function core.is_protected(pos, digger)

	digger = digger or "" -- nil check

	-- is area protected against digger?
	if not protector.can_dig(protector.radius, pos, digger, false, 1) then
		return true
	end

	-- otherwise can dig or place
	return old_is_protected(pos, digger)
end

-- make sure protection block doesn't overlap another protector's area

local function check_overlap(itemstack, placer, pointed_thing)

	if pointed_thing.type ~= "node" then return itemstack end

	local pos = pointed_thing.above
	local name = placer:get_player_name()

	-- make sure protector doesn't overlap onto protected spawn area
	if inside_spawn(pos, protector_spawn + protector.radius) then

		core.chat_send_player(name,
				S("Spawn @1 has been protected up to a @2 block radius.",
				core.pos_to_string(statspawn), protector_spawn))

		return itemstack
	end

	-- make sure protector doesn't overlap any other player's area
	if not protector.can_dig(protector.radius * 2, pos, name, true, 3) then

		core.chat_send_player(name,
				S("Overlaps into above players protected area"))

		return itemstack
	end

	return core.item_place(itemstack, placer, pointed_thing)
end

-- remove protector display entities

local function del_display(pos)

	local objects = core.get_objects_inside_radius(pos, 0.5)

	for _, v in ipairs(objects) do

		if v and v:get_luaentity() and v:get_luaentity().name == "protector:display" then
			v:remove()
		end
	end
end

-- temporary position store

local player_pos = {}

-- stone texture

local stone_tex = "default_stone.png"

if core.get_modpath("nc_terrain") then
	stone_tex = "nc_terrain_stone.png"
end

-- protector default

local def = {

	description = S("Protection Block") .. " (" .. S("USE for area check") .. ")",
	tiles = {
		stone_tex .. "^protector_overlay.png",
		stone_tex .. "^protector_overlay.png",
		stone_tex .. "^protector_overlay.png^protector_logo.png"
	},
	drawtype = "nodebox",
	node_box = {type = "fixed", fixed = {{-0.499 ,-0.499, -0.499, 0.499, 0.499, 0.499}}},
	sounds = default.node_sound_stone_defaults(),
	groups = {dig_immediate = 2, unbreakable = 1},
	is_ground_content = false,
	paramtype = "light",
	light_source = 4,
	walkable = true,

	on_place = check_overlap,

	after_place_node = function(pos, placer)

		local meta = core.get_meta(pos)

		meta:set_string("owner", placer:get_player_name() or "")
		meta:set_string("members", "")
		meta:set_string("infotext",
				S("Protection (owned by @1)", meta:get_string("owner")))
	end,

	on_use = function(itemstack, user, pointed_thing)

		if pointed_thing.type ~= "node" then return end

		protector.can_dig(protector.radius, pointed_thing.under,
				user:get_player_name(), false, 2)
	end,

	on_rightclick = function(pos, node, clicker, itemstack)

		local meta = core.get_meta(pos)
		local name = clicker:get_player_name()

		if meta and protector.can_dig(1, pos, name, true, 1) then

			player_pos[name] = pos

			core.show_formspec(name, "protector:node", protector_formspec(meta))
		end
	end,

	on_punch = function(pos, node, puncher)

		if core.is_protected(pos, puncher:get_player_name()) then return end

		core.add_entity(pos, "protector:display")
	end,

	can_dig = function(pos, player)

		return player and protector.can_dig(1, pos, player:get_player_name(), true, 1)
	end,

	on_blast = function() end,

	after_destruct = del_display
}

-- protection node

core.register_node("protector:protect", table.copy(def))

-- default recipe and alternative for MineClone2

if protector_recipe then

	local item_gold = "default:gold_ingot"
	local item_stone = "default:stone"

	if core.get_modpath("mcl_core") then
		item_gold = "mcl_core:gold_ingot"
		item_stone = "mcl_core:stone"
	end

	core.register_craft({
		output = "protector:protect",
		recipe = {
			{item_stone, item_stone, item_stone},
			{item_stone, item_gold, item_stone},
			{item_stone, item_stone, item_stone}
		}
	})
end

-- protection logo

def.description = S("Protection Logo") .. " (" .. S("USE for area check") .. ")"
def.tiles = {"protector_logo.png"}
def.wield_image = "protector_logo.png"
def.inventory_image = "protector_logo.png"
def.use_texture_alpha = "clip"
def.paramtype2 = "wallmounted"
def.legacy_wallmounted = true
def.sunlight_propagates = true
def.node_box = {
	type = "wallmounted",
	wall_top = {-0.375, 0.4375, -0.5, 0.375, 0.5, 0.5},
	wall_bottom = {-0.375, -0.5, -0.5, 0.375, -0.4375, 0.5},
	wall_side = {-0.5, -0.5, -0.375, -0.4375, 0.5, 0.375}
}
def.selection_box = {type = "wallmounted"}

core.register_node("protector:protect2", table.copy(def))

-- recipes to switch between protectors

core.register_craft({
	output = "protector:protect", recipe = {{"protector:protect2"}}
})

core.register_craft({
	output = "protector:protect2", recipe = {{"protector:protect"}}
})

-- check formspec buttons or when name entered

core.register_on_player_receive_fields(function(player, formname, fields)

	if formname ~= "protector:node" then return end

	local name = player:get_player_name()
	local pos = player_pos[name]

	if not name or not pos then return end

	local add_member_input = fields.protector_add_member

	-- reset formspec until close button pressed
	if (fields.close_me or fields.quit)
	and (not add_member_input or add_member_input == "") then
		player_pos[name] = nil
		return
	end

	-- only owner can add names
	if not protector.can_dig(1, pos, player:get_player_name(), true, 1) then
		return
	end

	-- are we adding member to a protection node ? (csm protection)
	local nod = core.get_node(pos).name

	if nod ~= "protector:protect" and nod ~= "protector:protect2" then
		player_pos[name] = nil
		return
	end

	local meta = core.get_meta(pos) ; if not meta then return end

	-- add faction members
	if factions_available and fields.faction_members ~= nil then
		meta:set_int("faction_members", fields.faction_members == "true" and 1 or 0)
	end

	-- add member [+]
	if add_member_input then

		for _, i in pairs(add_member_input:split(" ")) do
			add_member(meta, i)
		end
	end

	-- remove member [x]
	for field, value in pairs(fields) do

		if string.sub(field, 0,
				string.len("protector_del_member_")) == "protector_del_member_" then

			del_member(meta, string.sub(field,string.len("protector_del_member_") + 1))
		end
	end

	core.show_formspec(name, formname, protector_formspec(meta))
end)

-- display entity shown when protector node is punched

core.register_entity("protector:display", {

	initial_properties = {
		physical = false,
		collisionbox = {0, 0, 0, 0, 0, 0},
		visual = "wielditem",
		-- wielditem seems to be scaled to 1.5 times original node size
		visual_size = {x = 0.67, y = 0.67},
		textures = {"protector:display_node"},
		glow = 10
	},

	timer = 0,

	on_step = function(self, dtime)

		self.timer = self.timer + dtime

		-- remove after set number of seconds
		if self.timer > protector_show then self.object:remove() end
	end
})

-- Display-zone node, Do NOT place the display as a node,
-- it is made to be used as an entity (see above)

local r = protector.radius

core.register_node("protector:display_node", {
	tiles = {"protector_display.png"},
	use_texture_alpha = "clip",
	walkable = false,
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{-(r+.55), -(r+.55), -(r+.55), -(r+.45), (r+.55), (r+.55)}, -- sides
			{-(r+.55), -(r+.55), (r+.45), (r+.55), (r+.55), (r+.55)},
			{(r+.45), -(r+.55), -(r+.55), (r+.55), (r+.55), (r+.55)},
			{-(r+.55), -(r+.55), -(r+.55), (r+.55), (r+.55), -(r+.45)},
			{-(r+.55), (r+.45), -(r+.55), (r+.55), (r+.55), (r+.55)}, -- top
			{-(r+.55), -(r+.55), -(r+.55), (r+.55), -(r+.45), (r+.55)}, -- bottom
			{-.55,-.55,-.55, .55,.55,.55} -- middle (surrounding protector)
		}
	},
	selection_box = {type = "regular"},
	paramtype = "light",
	groups = {dig_immediate = 3, not_in_creative_inventory = 1},
	drop = "",
	on_blast = function() end
})

-- load mod sections

dofile(MP .. "/doors.lua")
dofile(MP .. "/chest.lua")
dofile(MP .. "/pvp.lua")
dofile(MP .. "/admin.lua")
dofile(MP .. "/tool.lua")
dofile(MP .. "/hud.lua")

if core.get_modpath("lucky_block") then
	dofile(MP .. "/lucky_block.lua")
end

-- stop mesecon pistons from pushing protectors

if core.get_modpath("mesecons_mvps") then
	mesecon.register_mvps_stopper("protector:protect")
	mesecon.register_mvps_stopper("protector:protect2")
	mesecon.register_mvps_stopper("protector:protect_hidden")
	mesecon.register_mvps_stopper("protector:chest")
end

-- player command to add member names to local protection

core.register_chatcommand("protector_add_member", {
	params = "",
	description = S("Add member names to local protection"),
	privs = {interact = true},

	func = function(name, param)

		if param == "" then return end

		local to_add = param:split(" ")
		local player = core.get_player_by_name(name)
		local pos = player:get_pos()

		-- find the protector nodes
		local pos = core.find_nodes_in_area(
				{x = pos.x - r, y = pos.y - r, z = pos.z - r},
				{x = pos.x + r, y = pos.y + r, z = pos.z + r},
				{"protector:protect", "protector:protect2", "protector:protect_hidden"})

		local meta, owner

		for n = 1, #pos do

			meta = core.get_meta(pos[n])
			owner = meta:get_string("owner") or ""

			if owner == name
			or core.check_player_privs(name, {protection_bypass = true}) then

				for m = 1, #to_add do
					add_member(meta, to_add[m])
				end

				core.add_entity(pos[n], "protector:display")
			end
		end
	end
})

-- player command to remove member names from local protection

core.register_chatcommand("protector_del_member", {
	params = "",
	description = S("Remove member names from local protection"),
	privs = {interact = true},

	func = function(name, param)

		if param == "" then return end

		local to_del = param:split(" ")
		local player = core.get_player_by_name(name)
		local pos = player:get_pos()

		-- find the protector nodes
		local pos = core.find_nodes_in_area(
				{x = pos.x - r, y = pos.y - r, z = pos.z - r},
				{x = pos.x + r, y = pos.y + r, z = pos.z + r},
				{"protector:protect", "protector:protect2", "protector:protect_hidden"})

		local meta, owner

		for n = 1, #pos do

			meta = core.get_meta(pos[n])
			owner = meta:get_string("owner") or ""

			if owner == name
			or core.check_player_privs(name, {protection_bypass = true}) then

				for m = 1, #to_del do
					del_member(meta, to_del[m])
				end

				core.add_entity(pos[n], "protector:display")
			end
		end
	end
})


print ("[MOD] Protector Redo loaded")
