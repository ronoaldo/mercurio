
-- translation and default name vars

local S = core.get_translator("protector")
local removal_names = ""
local replace_names = ""

-- remove protection command

core.register_chatcommand("protector_remove", {
	params = S("<names list>"),
	description = S("Remove Protectors around players (separate names with spaces)"),
	privs = {server = true},

	func = function(name, param)

		if param == "-" then

			core.chat_send_player(name, S("Name List Reset"))

			removal_names = "" ; return
		end

		if param ~= "" then
			removal_names = param
		end

		core.chat_send_player(name,
				S("Protector Names to remove: @1", removal_names))
	end
})

-- replace protection command

core.register_chatcommand("protector_replace", {
	params = S("<owner name> <name to replace with>"),
	description = S("Replace Protector Owner with name provided"),
	privs = {server = true},

	func = function(name, param)

		-- reset list to empty
		if param == "-" then

			core.chat_send_player(name, S("Name List Reset"))

			replace_names = "" ; return
		end

		-- check and set replacement name
		if param ~= "" then

			local names = param:split(" ") ; if not names[2] then return end

			if names[2] ~= string.match(names[2], "[%w_-]+") then
				core.chat_send_player(name, S("Invalid player name!")) ; return
			end

			if names[2]:len() > 25 then
				core.chat_send_player(name, S("Player name too long")) ; return
			end

			replace_names = param
		end

		-- show name info
		if replace_names ~= "" then

			local names = replace_names:split(" ")

			core.chat_send_player(name, S("Replacing Protector name @1 with @2",
					names[1] or "", names[2] or ""))
		end
	end
})

-- Abm to remove or replace protectors within active player area

core.register_abm({
	nodenames = {"protector:protect", "protector:protect2", "protector:protect_hidden"},
	interval = 5,
	chance = 1,
	catch_up = false,

	action = function(pos, node)

		if removal_names == "" and replace_names == "" then return end

		local meta = core.get_meta(pos) ; if not meta then return end
		local owner = meta:get_string("owner")

		if removal_names ~= "" then

			local names = removal_names:split(" ")

			for _, n in pairs(names) do

				if n == owner then
					core.set_node(pos, {name = "air"}) ; return
				end
			end
		end

		if replace_names ~= "" then

			local names = replace_names:split(" ")

			if names[1] and names[2] and owner == names[1] then

				meta:set_string("owner", names[2])
				meta:set_string("infotext", S("Protection (owned by @1)", names[2]))
			end
		end
	end
})

-- show protection areas of nearby protectors owned by you (thanks agaran)

local r = protector.radius

core.register_chatcommand("protector_show_area", {
	params = "",
	description = S("Show protected areas of your nearby protectors"),
	privs = {},

	func = function(name, param)

		local player = core.get_player_by_name(name)
		local pos = player:get_pos()

		-- find the protector nodes
		local pos = core.find_nodes_in_area(
				{x = pos.x - r, y = pos.y - r, z = pos.z - r},
				{x = pos.x + r, y = pos.y + r, z = pos.z + r},
				{"protector:protect", "protector:protect2", "protector:protect_hidden"})

		local meta, owner

		-- show a maximum of 5 protected areas only
		for n = 1, math.min(#pos, 5) do

			meta = core.get_meta(pos[n])
			owner = meta:get_string("owner") or ""

			if owner == name
			or core.check_player_privs(name, {protection_bypass = true}) then
				core.add_entity(pos[n], "protector:display")
			end
		end
	end
})

-- ability to hide protection blocks (borrowed from doors mod :)

core.register_node("protector:protect_hidden", {
	description = "Hidden Protector",
	drawtype = "airlike",
	paramtype = "light",
	paramtype2 = "facedir",
	sunlight_propagates = true,
	-- has to be walkable for falling nodes to stop falling
	walkable = true,
	pointable = false,
	diggable = false,
	buildable_to = false,
	floodable = false,
	drop = "",
	groups = {not_in_creative_inventory = 1, unbreakable = 1},
	is_ground_content = false,
	on_blast = function() end,
	-- 1px block to stop falling nodes replacing protector
	collision_box = {
		type = "fixed", fixed = {-15/32, 13/32, -15/32, -13/32, 1/2, -13/32}
	}
})

-- make own protectors visible in area

core.register_chatcommand("protector_show", {
	params = "",
	description = S("Show your nearby protection blocks"),
	privs = {interact = true},

	func = function(name, param)

		local player = core.get_player_by_name(name)

		if not player then
			return false, S("Player not found.")
		end

		local pos = player:get_pos()

		local a = core.find_nodes_in_area(
				{x = pos.x - r, y = pos.y - r, z = pos.z - r},
				{x = pos.x + r, y = pos.y + r, z = pos.z + r},
				{"protector:protect_hidden"})

		local meta, owner

		for _, row in pairs(a) do

			meta = core.get_meta(row)
			owner = meta:get_string("owner") or ""

			if owner == name
			or core.check_player_privs(name, {protection_bypass = true}) then
				core.swap_node(row, {name = "protector:protect"})
			end
		end
	end
})

-- make own protectors invisible in area

core.register_chatcommand("protector_hide", {
	params = "",
	description = S("Hide your nearby protection blocks"),
	privs = {interact = true},

	func = function(name, param)

		local player = core.get_player_by_name(name)

		if not player then
			return false, S("Player not found.")
		end

		local pos = player:get_pos()

		local a = core.find_nodes_in_area(
				{x = pos.x - r, y = pos.y - r, z = pos.z - r},
				{x = pos.x + r, y = pos.y + r, z = pos.z + r},
				{"protector:protect", "protector:protect2"})

		local meta, owner

		for _, row in pairs(a) do

			meta = core.get_meta(row)
			owner = meta:get_string("owner") or ""

			if owner == name
			or core.check_player_privs(name, {protection_bypass = true}) then
				core.swap_node(row, {name = "protector:protect_hidden"})
			end
		end
	end
})
