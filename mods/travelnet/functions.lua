local S = minetest.get_translator("travelnet")


local function string_endswith(str, ends)
	local len = #ends
	if str:sub(-len) == ends then
		return str:sub(1, -len-1)
	end
end

local function string_startswith(str, start)
	local len = #start
	if str:sub(1, len) == start then
		return str:sub(len+1)
	end
end

function travelnet.is_falsey_string(str)
	return not str or str == ""
end

function travelnet.node_description(pos)

	local node = minetest.get_node_or_nil(pos)
	if not node then return end

	local description

	if minetest.get_item_group(node.name, "travelnet") == 1 then
		description = S("travelnet box")
	elseif minetest.get_item_group(node.name, "elevator") == 1 then
		description = S("elevator")
	elseif node.name == "locked_travelnet:travelnet" then
		description = S("locked travelnet")
	elseif node.name == "locked_travelnet:elevator" then
		description = S("locked elevator")
	else
		description = nil
	end

	return description, node.name

end

function travelnet.find_nearest_elevator_network(pos, owner_name)
	local nearest_network = false
	local nearest_dist = false
	local nearest_dist_x
	local nearest_dist_z

	local player_travelnets = travelnet.get_travelnets(owner_name)
	for target_network_name, network in pairs(player_travelnets) do
		local station_name = next(network, nil)
		if station_name then
			local station = network[station_name]
			if station.nr and station.pos then
				local dist_x = station.pos.x - pos.x
				local dist_z = station.pos.z - pos.z
				local dist = math.ceil(math.sqrt(dist_x * dist_x + dist_z * dist_z))
				-- find the nearest one; store network_name and (minimal) distance
				if not nearest_dist or dist < nearest_dist then
					nearest_dist = dist
					nearest_dist_x = dist_x
					nearest_dist_z = dist_z
					nearest_network = target_network_name
				end
			end
		end
	end
	return nearest_network, {
		x = nearest_dist_x,
		z = nearest_dist_z,
	}
end

function travelnet.elevator_network(pos)
	return tostring(pos.x) .. "," .. tostring(pos.z)
end

function travelnet.is_elevator(node_name)
	return node_name == "travelnet:elevator"
end

function travelnet.door_is_open(node, opposite_direction)
	return string.sub(node.name, -5) == "_open"
		-- handle doors that change their facedir
		or (
			node.param2 ~= opposite_direction
			and not (
				string_startswith(node.name, "travelnet:elevator_door")
				and string_endswith(node.name, "_closed")
			)
		)
end

function travelnet.door_is_closed(node, opposite_direction)
	return string.sub(node.name, -7) == "_closed"
		-- handle doors that change their facedir
		or (
			node.param2 == opposite_direction
			and not (
				string_startswith(node.name, "travelnet:elevator_door")
				and string_endswith(node.name, "_open")
			)
		)
end

function travelnet.param2_to_yaw(param2)
	if     param2 == 0 then
		return 180
	elseif param2 == 1 then
		return 90
	elseif param2 == 2 then
		return 0
	elseif param2 == 3 then
		return 270
	end
end

function travelnet.get_network(owner_name, network_name)
	local player_travelnets = travelnet.get_travelnets(owner_name)

	if not player_travelnets then return end

	return player_travelnets[network_name]
end

function travelnet.get_ordered_stations(owner_name, network_name, is_elevator)
	local travelnets = travelnet.get_travelnets(owner_name)
	local network = travelnets[network_name]
	if not network then
		return {}
	end

	local stations = {}
	for k in pairs(network) do
		table.insert(stations, k)
	end

	if is_elevator then
		local ground_level = 1
		table.sort(stations, function(a, b)
			return network[a].pos.y > network[b].pos.y
		end)

		-- find ground level
		local vgl_timestamp = 999999999999
		for index,k in ipairs(stations) do
			local station = network[k]
			if not station.timestamp then
				station.timestamp = os.time()
			end
			if station.timestamp < vgl_timestamp then
				vgl_timestamp = station.timestamp
				ground_level  = index
			end
		end

		for index,k in ipairs(stations) do
			local station = network[k]
			if index == ground_level then
				station.nr = "G"
			else
				station.nr = tostring(ground_level - index)
			end
		end
		-- TODO: hacky workaround for setting the "nr" field on the stations
		-- should be done on elevator placement instead
		travelnet.log("action", "creating ad-hoc elevator fields for player '" .. owner_name ..
			"' and network '" .. network_name .. "'")
		travelnet.set_travelnets(owner_name, travelnets)
	else
		-- sort the table according to the timestamp (=time the station was configured)
		table.sort(stations, function(a, b)
			return network[a].timestamp < network[b].timestamp
		end)
	end

	return stations
end

function travelnet.get_station(owner_name, station_network, station_name)

	local network = travelnet.get_network(owner_name, station_network)
	if not network then return end

	return network[station_name]
end

-- punching the travelnet updates its formspec and shows it to the player;
-- however, that would be very annoying when actually trying to dig the thing.
-- Thus, check if the player is wielding a tool that can dig nodes of the
-- group cracky
function travelnet.check_if_trying_to_dig(puncher)
	-- if in doubt: show formspec
	if not puncher or not puncher:get_wielded_item() then
		return false
	end
	-- show menu when in creative mode
	if creative and creative.is_enabled_for(puncher:get_player_name()) then
		return false
	end
	local tool_capabilities = puncher:get_wielded_item():get_tool_capabilities()
	if not tool_capabilities or not tool_capabilities["groupcaps"] or not tool_capabilities["groupcaps"]["cracky"] then
		return false
	end
	-- tools which can dig cracky items can start digging immediately
	return true
end

-- allow doors to open
function travelnet.open_close_door(pos, player, mode)
	local this_node = minetest.get_node_or_nil(pos)
	-- give up if the area is *still* not loaded
	if not this_node then
		return
	end

	local opposite_direction = (this_node.param2 + 2) % 4
	local door_pos = vector.add(pos, minetest.facedir_to_dir(opposite_direction))

	local door_node = minetest.get_node_or_nil(door_pos)

	if not door_node or door_node.name == "ignore" or door_node.name == "air"
			or not minetest.registered_nodes[door_node.name] then
		return
	end

	local right_click_action = minetest.registered_nodes[door_node.name].on_rightclick
	if not right_click_action then return end

	if not minetest.registered_nodes[door_node.name].groups["door"] then
		return
	end

	-- Map to old API in case anyone is using it externally
	if     mode == 0 then mode = "toggle"
	elseif mode == 1 then mode = "close"
	elseif mode == 2 then mode = "open"
	end

	-- at least for homedecor, same facedir would mean "door closed"
	-- do not close the elevator door if it is already closed
	if mode == "close" and travelnet.door_is_closed(door_node, opposite_direction) then
		return
	end

	-- do not open the doors if they are already open (works only on elevator-doors; not on doors in general)
	if mode == "open" and travelnet.door_is_open(door_node, opposite_direction) then
		return
	end

	if mode == "open" then
		local playername = player:get_player_name()
		minetest.after(1, function()
			-- Get the player again in case it doesn't exist anymore (logged out)
			local pplayer = minetest.get_player_by_name(playername)
			if pplayer then
				right_click_action(door_pos, door_node, pplayer, ItemStack(""))
			end
		end)
	else
		right_click_action(door_pos, door_node, player, ItemStack(""))
	end
end

travelnet.rotate_player = function(target_pos, player)
	local target_node = minetest.get_node_or_nil(target_pos)
	if target_node == nil then return end

	-- play sound at the target position as well
	if travelnet.travelnet_sound_enabled then
		local sound = "travelnet_travel"
		if travelnet.is_elevator(target_node.name) then
			sound = "travelnet_bell"
		end

		minetest.sound_play(sound, {
			pos = target_pos,
			gain = 0.75,
			max_hear_distance = 10
		})
	end

	-- do this only on servers where the function exists
	if player.set_look_horizontal then
		-- rotate the player so that they can walk straight out of the box
		local yaw = travelnet.param2_to_yaw(target_node.param2) or 0

		player:set_look_horizontal(math.rad(yaw))
		player:set_look_vertical(math.rad(0))
	end

	travelnet.open_close_door(target_pos, player, "open")
end


travelnet.remove_box_action = function(oldmetadata)
	if not oldmetadata or oldmetadata == "nil" or not oldmetadata.fields then
		return false, S("Could not find information about the station that is to be removed.")
	end

	local owner_name      = oldmetadata.fields["owner"]
	local station_name    = oldmetadata.fields["station_name"]
	local station_network = oldmetadata.fields["station_network"]

	-- station is not known? then just remove it
	if	not (owner_name and station_network and station_name)
		or not travelnet.get_station(owner_name, station_network, station_name)
	then
		return false, S("Could not find the station that is to be removed.")
	end

	local player_travelnets = travelnet.get_travelnets(owner_name)
	player_travelnets[station_network][station_name] = nil
	travelnet.set_travelnets(owner_name, player_travelnets)

	return true
end
travelnet.remove_box_message = function(oldmetadata, digger)
	local removal_message = S(
		"Station '@1'" .. " " .. "has been REMOVED from the network '@2'.",
		oldmetadata.fields["station_name"],
		oldmetadata.fields["station_network"]
	)
	local owner_name = oldmetadata.fields["owner"]
	minetest.chat_send_player(owner_name, removal_message)
	local digger_name = digger and digger:get_player_name()
	if digger and owner_name ~= digger_name then
		minetest.chat_send_player(digger_name, removal_message)
	end
end
travelnet.remove_box = function(_, _, oldmetadata, digger)
	local success, reason = travelnet.remove_box_action(oldmetadata)

	if success then
		travelnet.remove_box_message(oldmetadata, digger)
	else
		minetest.chat_send_player(digger:get_player_name(), S("Error") .. ": " ..reason)
	end
end

-- privs of player are already checked by on_receive_fields before sending
-- the edit form, but we need to check again in case somebody is cheating
function travelnet.edit_box(pos, fields, meta, player_name)
	local description, node_name = travelnet.node_description(pos)
	local is_elevator = travelnet.is_elevator(node_name)
	local success, result = travelnet.actions.update_station({
		meta = meta,
		pos = pos,
		props = {
			owner_name = meta:get_string("owner"),
			station_network = meta:get_string("station_network"),
			station_name	= meta:get_string("station_name"),
			description = description,
			is_elevator = is_elevator
		}
	}, fields, minetest.get_player_name(player_name))
	if not success then
		minetest.chat_send_player(player_name, result)
	end
end

function travelnet.edit_elevator(pos, fields, meta, player_name)
	local description, node_name = travelnet.node_description(pos)
	local is_elevator = travelnet.is_elevator(node_name)
	local success, result = travelnet.actions.update_elevator({
		meta = meta,
		pos = pos,
		props = {
			owner_name = meta:get_string("owner"),
			station_network = meta:get_string("station_network"),
			station_name	= meta:get_string("station_name"),
			description = description,
			is_elevator = is_elevator
		}
	}, fields, minetest.get_player_name(player_name))
	if not success then
		minetest.chat_send_player(player_name, result)
	end
end

travelnet.can_dig = function()
	-- forbid digging of the travelnet
	return false
end
