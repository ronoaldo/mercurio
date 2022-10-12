--[[
Functions
Copyright (C) 2014-2022 ChaosWormz and contributors

This library is free software; you can redistribute it and/or
modify it under the terms of the GNU Lesser General Public
License as published by the Free Software Foundation; either
version 2.1 of the License, or (at your option) any later version.

This library is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
Lesser General Public License for more details.

You should have received a copy of the GNU Lesser General Public
License along with this library; if not, write to the Free Software
Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301
USA
--]]

-- Support for intllib
local S = tp.intllib

-- Placeholders
local chatmsg, source, target, name2,
target_coords, tpc_target_coords, old_tpc_target_coords

local spam_prevention = {}
local band = false

local muted_players = {}

local message_color = tp.message_color

local function color_string_to_number(color)
	if string.sub(color,1,1) == '#' then
		color = string.sub(color, 2)
	end
	if #color < 6 then
		local r = string.sub(color,1,1)
		local g = string.sub(color,2,2)
		local b = string.sub(color,3,3)
		color = r..r .. g..g .. b..b
	elseif #color > 6 then
		color = string.sub(color, 1, 6)
	end
	return tonumber(color, 16)
end

local message_color_number = color_string_to_number(message_color)

local function send_message(player, message)
	minetest.chat_send_player(player, minetest.colorize(message_color, message))
	if minetest.get_modpath("chat2") then
		chat2.send_message(minetest.get_player_by_name(player), message, message_color_number)
	end
end

local map_size = 30912
function tp.can_teleport(to)
	return to.x < map_size and to.x > -map_size and to.y < map_size and to.y > -map_size and to.z < map_size and to.z > -map_size
end

-- Teleport player to a player (used in "/tpr" and in "/tphr" command).
function tp.tpr_teleport_player()
	target_coords = source:get_pos()
	local target_sound = target:get_pos()
	target:set_pos(tp.find_free_position_near(target_coords))
	minetest.sound_play("tpr_warp", {pos = target_coords, gain = 0.5, max_hear_distance = 10})
	minetest.sound_play("tpr_warp", {pos = target_sound, gain = 0.5, max_hear_distance = 10})
	--tp.parti2(target_coords)
end

-- TPC & TPJ
function tp.tpc_teleport_player(player)
	local pname = minetest.get_player_by_name(player)
	minetest.sound_play("tpr_warp", {pos = pname:get_pos(), gain = 0.5, max_hear_distance = 10})
	pname:set_pos(tp.find_free_position_near(target_coords))
	minetest.sound_play("tpr_warp", {pos = target_coords, gain = 0.5, max_hear_distance = 10})
	--tp.parti2(target_coords)
end

-- TPP
function tp.tpp_teleport_player(player, pos)
	local pname = minetest.get_player_by_name(player)
	minetest.sound_play("tpr_warp", {pos = pname:get_pos(), gain = 0.5, max_hear_distance = 10})
	pname:set_pos(tp.find_free_position_near(pos))
	minetest.sound_play("tpr_warp", {pos = pos, gain = 0.5, max_hear_distance = 10})
	--tp.parti2(target_coords)
end

function tp.find_free_position_near(pos)
	local tries = {
		{x=1,y=0,z=0},
		{x=-1,y=0,z=0},
		{x=0,y=0,z=1},
		{x=0,y=0,z=-1},
	}
	for _,d in pairs(tries) do
		local p = vector.add(pos, d)
		local def = minetest.registered_nodes[minetest.get_node(p).name]
		if def and not def.walkable then
			return p, true
		end
	end
	return pos, false
end

function tp.parti(pos)
	minetest.add_particlespawner(50, 0.4,
		{x=pos.x + 0.5, y=pos.y, z=pos.z + 0.5}, {x=pos.x - 0.5, y=pos.y, z=pos.z - 0.5},
		{x=0, y=5, z=0}, {x=0, y=0, z=0},
		{x=0, y=5, z=0}, {x=0, y=0, z=0},
		3, 5,
		3, 5,
		false,
		"tps_portal_parti.png")
end

function tp.parti2(pos)
	minetest.add_particlespawner(50, 0.4,
		{x=pos.x + 0.5, y=pos.y + 10, z=pos.z + 0.5}, {x=pos.x - 0.5, y=pos.y, z=pos.z - 0.5},
		{x=0, y=-5, z=0}, {x=0, y=0, z=0},
		{x=0, y=-5, z=0}, {x=0, y=0, z=0},
		3, 5,
		3, 5,
		false,
		"tps_portal_parti.png")
end

-- Mutes a player from sending you teleport requests
function tp.tpr_mute(player, muted_player)
	if muted_player == "" then
		send_message(player, S("Usage: /tpr_mute <player>"))
		return
	end

	if not minetest.get_player_by_name(muted_player) then
		send_message(player, S("There is no player by that name. Keep in mind this is case-sensitive, and the player must be online."))
		return
	end

	if minetest.check_player_privs(muted_player, {tp_admin = true}) and not minetest.check_player_privs(player, {server = true}) then
		send_message(player, S("tpr_mute: Failed to mute player @1: they have the tp_admin privilege.", muted_player))
		return
	end

	if muted_players[player] == muted_player then
		send_message(player, S("tpr_mute: Player @1 is already muted.", muted_player))
		return
	end

	muted_players[player] = muted_player
	send_message(player, S("tpr_mute: Player @1 successfully muted.", muted_player))
end

-- Unmutes a player from sending you teleport requests
function tp.tpr_unmute(player, muted_player)
	if muted_player == "" then
		send_message(player, S("Usage: /tpr_unmute <player>"))
		return
	end

	if not minetest.get_player_by_name(muted_player) then
		send_message(player, S("There is no player by that name. Keep in mind this is case-sensitive, and the player must be online."))
		return
	end

	if muted_players[player] ~= muted_player then
		send_message(player, S("tpr_mute: Player @1 is not muted yet.", muted_player))
		return
	end

	muted_players[player] = nil
	send_message(player, S("tpr_mute: Player @1 successfully unmuted.", muted_player))
end

-- Teleport Request System
function tp.tpr_send(sender, receiver)
	-- Check if the sender is muted
	if muted_players[receiver] == sender and not minetest.check_player_privs(sender, {server = true}) then
		send_message(sender, S("Cannot send request to @1 (you have been muted).", receiver))
		return
	end

	if receiver == "" then
		send_message(sender, S("Usage: /tpr <Player name>"))
		return
	end

	if not minetest.get_player_by_name(receiver) then
		send_message(sender, S("There is no player by that name. Keep in mind this is case-sensitive, and the player must be online"))
		return
	end

	-- Spam prevention
	if spam_prevention[receiver] == sender and not minetest.check_player_privs(sender, {tp_admin = true}) then
		send_message(sender, S("Wait @1 seconds before you can send teleport requests to @2 again.", tp.timeout_delay, receiver))

		minetest.after(tp.timeout_delay, function(sender_name, receiver_name)
			spam_prevention[receiver_name] = nil
			if band == true then return end

			if spam_prevention[receiver_name] == nil then
				send_message(sender_name, S("You can now send teleport requests to @1.", receiver_name))
				band = true
			end
		end, sender, receiver)

	else

	-- Compatibility with beerchat
		if minetest.get_modpath("beerchat") and not minetest.check_player_privs(sender, {tp_admin = true}) then
			if receiver == "" then
				send_message(sender, S("Usage: /tpr <Player name>"))
				return
			end

			if not minetest.get_player_by_name(receiver) then
				send_message(sender, S("There is no player by that name. Keep in mind this is case-sensitive, and the player must be online"))
				return
			end

			local player_receiver = minetest.get_player_by_name(receiver)
			if player_receiver:get_meta():get_string("beerchat:muted:" .. sender) == "true" then
				send_message(sender, S("You are not allowed to send requests because you're muted."))
				return
			end
		end

		if minetest.check_player_privs(sender, {tp_admin = true}) and tp.enable_immediate_teleport then
			if receiver == "" then
				send_message(sender, S("Usage: /tpr <Player name>"))
				return
			end

			if not minetest.get_player_by_name(receiver) then
				send_message(sender, S("There is no player by that name. Keep in mind this is case-sensitive, and the player must be online"))
				return
			end

			tp.tpr_list[receiver] = sender
			tp.tpr_accept(receiver)
			send_message(sender, S("You are teleporting to @1.", receiver))
			return
		end

		if receiver == "" then
			send_message(sender, S("Usage: /tpr <Player name>"))
			return
		end

		if not minetest.get_player_by_name(receiver) then
			send_message(sender, S("There is no player by that name. Keep in mind this is case-sensitive, and the player must be online"))
			return
		end

		if minetest.get_modpath("gamehub") then -- Compatibility with gamehub (UNTESTED)
			if gamehub.players[receiver] then
				send_message(sender, S("Teleport request denied, player is in the gamehub!"))
				return
			end
		end

		send_message(receiver, S("@1 is requesting to teleport to you. /tpy to accept.", sender))
		send_message(sender, S("Teleport request sent! It will timeout in @1 seconds.", tp.timeout_delay))

		-- Write name values to list and clear old values.
		tp.tpr_list[receiver] = sender
		tp.tpn_list[sender] = receiver

		-- Teleport timeout delay
		minetest.after(tp.timeout_delay, function(sender_name, receiver_name)
			if tp.tpr_list[receiver_name] and tp.tpn_list[sender_name] then
				tp.tpr_list[receiver_name] = nil
				tp.tpn_list[sender_name] = nil

				send_message(sender_name, S("Request timed-out."))
				send_message(receiver_name, S("Request timed-out."))
				return
			end
		end, sender, receiver)
	end
end

function tp.tphr_send(sender, receiver)
	-- Check if the sender is muted
	if muted_players[receiver] == sender and not minetest.check_player_privs(sender, {server = true}) then
		send_message(sender, S("Cannot send request to @1 (you have been muted).", receiver))
		return
	end

	if receiver == "" then
		send_message(sender, S("Usage: /tphr <Player name>"))
		return
	end

	if not minetest.get_player_by_name(receiver) then
		send_message(sender, S("There is no player by that name. Keep in mind this is case-sensitive, and the player must be online."))
		return
	end

	-- Spam prevention
	if spam_prevention[receiver] == sender and not minetest.check_player_privs(sender, {tp_admin = true}) then
		send_message(sender, S("Wait @1 seconds before you can send teleport requests to @2 again.", tp.timeout_delay, receiver))

		minetest.after(tp.timeout_delay, function(sender_name, receiver_name)
			spam_prevention[receiver_name] = nil
			if band == true then return end

			if spam_prevention[receiver_name] == nil then
				send_message(sender_name, S("You can now send teleport requests to @1.", receiver_name))
				band = true
			end
		end, sender, receiver)

	else

	-- Compatibility with beerchat
		if minetest.get_modpath("beerchat") and not minetest.check_player_privs(sender, {tp_admin = true}) then
			if receiver == "" then
				send_message(sender, S("Usage: /tphr <Player name>"))
				return
			end

			if not minetest.get_player_by_name(receiver) then
				send_message(sender, S("There is no player by that name. Keep in mind this is case-sensitive, and the player must be online."))
				return
			end

			local player_receiver = minetest.get_player_by_name(receiver)
			if player_receiver:get_meta():get_string("beerchat:muted:" .. sender) == "true" then
				send_message(sender, S("You are not allowed to send requests because you're muted."))
				return
			end
		end

		if minetest.check_player_privs(sender, {tp_admin = true}) and tp.enable_immediate_teleport then
			if receiver == "" then
				send_message(sender, S("Usage: /tphr <Player name>"))
				return
			end

			if not minetest.get_player_by_name(receiver) then
				send_message(sender, S("There is no player by that name. Keep in mind this is case-sensitive, and the player must be online."))
				return
			end

			tp.tphr_list[receiver] = sender
			tp.tpr_accept(receiver)
			send_message(sender, S("@1 is teleporting to you.", receiver))
			return
		end

		if receiver == "" then
			send_message(sender, S("Usage: /tphr <Player name>"))
			return
		end

		if not minetest.get_player_by_name(receiver) then
			send_message(sender, S("There is no player by that name. Keep in mind this is case-sensitive, and the player must be online."))
			return
		end

		if minetest.get_modpath("gamehub") then -- Compatibility with gamehub (UNTESTED)
			if gamehub.players[receiver] then
				send_message(sender, S("Teleport request denied, player is in the gamehub!"))
				return
			end
		end

		send_message(receiver, S("@1 is requesting that you teleport to them. /tpy to accept; /tpn to deny.", sender))
		send_message(sender, S("Teleport request sent! It will timeout in @1 seconds.", tp.timeout_delay))

		-- Write name values to list and clear old values.
		tp.tphr_list[receiver] = sender
		tp.tpn_list[sender] = receiver

		-- Teleport timeout delay

		minetest.after(tp.timeout_delay, function(sender_name, receiver_name)
			if tp.tphr_list[receiver_name] and tp.tpn_list[sender_name] then
				tp.tphr_list[receiver_name] = nil
				tp.tpn_list[sender_name] = nil

				send_message(sender_name, S("Request timed-out."))
				send_message(receiver_name, S("Request timed-out."))
				return
			end
		end, sender, receiver)
	end
end

function tp.tpc_send(sender, coordinates)
	local posx,posy,posz = string.match(coordinates, "^(-?%d+), (-?%d+), (-?%d+)$")
	local pname = minetest.get_player_by_name(sender)

	if posx ~= nil or posy ~= nil or posz ~= nil then
		posx = tonumber(posx) + 0.0
		posy = tonumber(posy) + 0.0
		posz = tonumber(posz) + 0.0
	end

	if posx==nil or posy==nil or posz==nil or string.len(posx) > 6 or string.len(posy) > 6 or string.len(posz) > 6 then
		send_message(sender, S("Usage: /tpc <x, y, z>"))
		return nil
	end

	target_coords = {x=posx, y=posy, z=posz}

	if tp.can_teleport(target_coords) == false then
		send_message(sender, S("You cannot teleport to a location outside the map!"))
		return nil
	end

	-- If the area is protected, reject the user's request to teleport to these coordinates
	-- Admin user (priv "tp_admin") overrides all protection
	if minetest.check_player_privs(pname, {tp_admin = true}) then
		tp.tpc_teleport_player(sender)
		target_coords = nil
		send_message(sender, S("Teleporting to: @1, @2, @3", posx, posy, posz))
	else
		if minetest.check_player_privs(pname, {tp_tpc = true}) then
			local protected = minetest.is_protected(target_coords, sender)
			if protected then
				if minetest.get_modpath("areas") then
					for _, area in pairs(areas:getAreasAtPos(target_coords)) do
						if minetest.get_player_by_name(area.owner) then -- Check if area owners are online

							if tpc_target_coords then
								old_tpc_target_coords = tpc_target_coords
								old_tpc_target_coords[area.owner] = tpc_target_coords[area.owner]

								tpc_target_coords[area.owner] = {x=posx, y=posy, z=posz}
							else
								tpc_target_coords = {x=posx, y=posy, z=posz}
								tpc_target_coords[area.owner] = {x=posx, y=posy, z=posz}
							end

							send_message(sender, S("Area request sent! Waiting for @1 to accept your request." ..
							" It will timeout in @2 seconds.", table.concat(areas:getNodeOwners(tpc_target_coords[area.owner]), S(", or ")), tp.timeout_delay))
							send_message(area.owner, S("@1 is requesting to teleport to a protected area" ..
							" of yours @2.", sender, minetest.pos_to_string(tpc_target_coords[area.owner])))

							tp.tpc_list[area.owner] = sender
							tp.tpn_list[sender] = area.owner

							minetest.after(tp.timeout_delay, function(sender_name, receiver_name)
								if tp.tpc_list[receiver_name] and tp.tpn_list[sender_name] then
									tp.tpc_list[receiver_name] = nil
									tp.tpn_list[sender_name] = nil

									send_message(sender_name, S("Request timed-out."))
									send_message(receiver_name, S("Request timed-out."))
									return
								end
							end, sender, area.owner)
						else
							minetest.record_protection_violation(target_coords, sender)
						end
					end
				else
					minetest.record_protection_violation(target_coords, sender)
				end
				return
			end

			tp.tpc_teleport_player(sender)
			target_coords = nil
			send_message(sender, S("Teleporting to: @1, @2, @3", posx, posy, posz))
		else
			send_message(sender, S("Error: You do not have permission to teleport to those coordinates."))
			return
		end
	end
end

function tp.tpr_deny(name)
	if not tp.tpr_list[name] and not tp.tphr_list[name]
	and not tp.tpc_list[name] and not tp.tpn_list[name] then
		send_message(name, S("Usage: /tpn allows you to deny teleport/area requests sent to you by other players."))
		return
	end

	-- Area requests
	if tp.tpc_list[name] then
		name2 = tp.tpc_list[name]
		send_message(name2, S("Area request denied."))
		send_message(name, S("You denied the request @1 sent you.", name2))
		tp.tpc_list[name] = nil

		-- Don't allow re-denying requests.
		tp.tpn_list[name2] = nil
		return
	end

	-- Teleport requests
	if tp.tpr_list[name] then
		name2 = tp.tpr_list[name]
		send_message(name2, S("Teleport request denied."))
		send_message(name, S("You denied the request @1 sent you.", name2))

		tp.tpr_list[name] = nil
		spam_prevention[name] = name2

		-- Don't allow re-denying requests.
		tp.tpn_list[name2] = nil

	elseif tp.tphr_list[name] then
		name2 = tp.tphr_list[name]
		send_message(name2, S("Teleport request denied."))
		send_message(name, S("You denied the request @1 sent you.", name2))

		tp.tphr_list[name] = nil
		spam_prevention[name] = name2

		-- Don't allow re-denying requests.
		tp.tpn_list[name2] = nil

	elseif tp.tpn_list[name] then
		name2 = tp.tpn_list[name]
		send_message(name, S("You denied your request sent to @1.", name2))
		send_message(name2, S("@1 denied their request sent to you.", name))

		if tp.tpr_list[name2] then
			tp.tpr_list[name2] = nil

		elseif tp.tphr_list[name2] then
			tp.tphr_list[name2] = nil

		elseif tp.tpc_list[name2] then
			tp.tpc_list[name2] = nil
		end

		tp.tpn_list[name] = nil
		return
	end
end

-- Teleport Accept Systems
function tp.tpr_accept(name)
	-- Check to prevent constant teleporting
	if not tp.tpr_list[name] and not tp.tphr_list[name]
	and not tp.tpc_list[name] then
		send_message(name, S("Usage: /tpy allows you to accept teleport/area requests sent to you by other players."))
		return
	end

	-- Area requests
	if tp.tpc_list[name] then

		if tp.tpc_list[name] then
			name2 = tp.tpc_list[name]
			source = minetest.get_player_by_name(name)
			target = minetest.get_player_by_name(name2)
			chatmsg = S("@1 is teleporting to your protected area @2.", name2, minetest.pos_to_string(tpc_target_coords[name]))
			tp.tpc_list[name] = nil
		else
			return
		end

		-- If source or target are not present, abort request.
		if not source or not target then
			send_message(name, S("@1 is not online right now.", name2))
			tp.tpc_list[name] = nil
			return
		end

		if not tpc_target_coords[name] then
			tpc_target_coords[name2] = old_tpc_target_coords[name]
			tp.tpp_teleport_player(name2, tpc_target_coords[name2])

			chatmsg = S("@1 is teleporting to your protected area @2.", name2, minetest.pos_to_string(tpc_target_coords[name2]))
		else
			tp.tpp_teleport_player(name2, tpc_target_coords[name])
			chatmsg = S("@1 is teleporting to your protected area @2.", name2, minetest.pos_to_string(tpc_target_coords[name]))
		end

		-- Don't allow re-denying requests.
		if tp.tpn_list[name] or tp.tpn_list[name2] then
			tp.tpn_list[name] = nil
			tp.tpn_list[name2] = nil
		end

		send_message(name, chatmsg)
		send_message(name2, S("Request Accepted!"))

		-- Avoid abusing with area requests
		target_coords = nil
	end

	-- Teleport requests.
	if tp.tpr_list[name] then
		name2 = tp.tpr_list[name]
		source = minetest.get_player_by_name(name)
		target = minetest.get_player_by_name(name2)
		chatmsg = S("@1 is teleporting to you.", name2)
		tp.tpr_list[name] = nil

	elseif tp.tphr_list[name] then
		name2 = tp.tphr_list[name]
		source = minetest.get_player_by_name(name2)
		target = minetest.get_player_by_name(name)
		chatmsg = S("You are teleporting to @1.", name2)
		tp.tphr_list[name] = nil
	else
		return
	end

	-- Could happen if either player disconnects (or timeout); if so just abort
	if not source
	or not target then
		send_message(name, S("@1 is not online right now.", name2))
		tp.tpr_list[name] = nil
		tp.tphr_list[name] = nil
		return
	end

	tp.tpr_teleport_player()

	-- Avoid abusing with area requests
	target_coords = nil

	-- Don't allow re-denying requests.
	if tp.tpn_list[name] or tp.tpn_list[name2] then
		tp.tpn_list[name] = nil
		tp.tpn_list[name2] = nil
	end

	send_message(name, chatmsg)

	if minetest.check_player_privs(name2, {tp_admin = true}) == false then
		send_message(name2, S("Request Accepted!"))
	else
		if tp.enable_immediate_teleport then return end

		send_message(name2, S("Request Accepted!"))
		return
	end
end

-- Teleport Jump - Relative Position Teleportation by number of nodes
function tp.tpj(player, param)
	if param == "" then
		send_message(player, S("Usage: <x|y|z> <number>"))
		return false
	end

	local args = param:split(" ") -- look into this. Can it crash if the player does not have two parameters?
	if #args < 2 then
		send_message(player, S("Usage: <x|y|z> <number>"))
		return false
	end

	if not tonumber(args[2]) then
		send_message(player, S("Not a number!"))
		return false, S("Not a number!")
	end

	-- Initially generate the target coords from the player's current position (since it's relative) and then perform the math.
	target_coords = minetest.get_player_by_name(player):get_pos()
	if args[1] == "x" then
		target_coords["x"] = target_coords["x"] + tonumber(args[2])
	elseif args[1] == "y" then
		target_coords["y"] = target_coords["y"] + tonumber(args[2])
	elseif args[1] == "z" then
		target_coords["z"] = target_coords["z"] + tonumber(args[2])
	else
		send_message(player, S("Not a valid axis. Valid options are X, Y or Z"))
		return
	end

	if tp.can_teleport(target_coords) == false then
		send_message(player, S("You cannot teleport to a location outside the map!"))
		return
	end
	tp.tpc_teleport_player(player)

	-- Avoid abusing with area requests
	target_coords = nil
end

-- Evade
function tp.tpe(player)
	send_message(player, S("EVADE!"))
	local mindistance = 15
	local maxdistance = 50
	local times = math.random(6,20) -- how many times to jump - minimum,maximum
	local negatives = { '-','' } -- either it's this way or that way: the difference between -10 and 10
	local options = { 'x', 'y', 'z' }
	local isnegative = ''
	local distance = 0
	local axis = ''
	local iteration = 0
	for i = 1,times do
		-- do this every 1 second
		minetest.after(iteration,
			function()
				isnegative = negatives[math.random(2)] -- choose randomly whether this is this way or that
				distance = isnegative .. math.random(mindistance,maxdistance) -- the distance to jump
				axis = options[math.random(3)]
				local command = axis .. " " .. distance
				tp.tpj(player, command)
			end
		)
		iteration = iteration + 0.5
	end
end

-- Teleport To Place (TPP) system.
if tp.enable_tpp_command then
	function tp.tpp(player, param)
		-- Show the available places to the player (taken from shivajiva101's POI mod, thanks!).
		if param == "" then
			local places = {}
			if not tp.available_places then tp.available_places = {} end
			for key, value in pairs(tp.available_places) do
				send_message(player, key)
				table.insert(places, key)
			end
			if #places == 0 then
				send_message(player, S("There are no places yet."))
				return true, S("There are no places yet.")
			end
				send_message(player, S("Usage: /tpp <place>"))
				table.insert(places, S("Usage: /tpp <place>"))
				return true, table.concat(places, "\n")

		-- Teleport player to the specified place (taken from shivajiva101's POI mod, thanks!).
		elseif tp.available_places[param] then
			local pos = {x = tp.available_places[param].x, y = tp.available_places[param].y, z = tp.available_places[param].z}
			tp.tpp_teleport_player(player, pos)
			send_message(player, S("Teleporting to @1.", param))

		-- Check if the place exists.
		elseif not tp.available_places[param] then
			send_message(player, S("There is no place by that name. Keep in mind this is case-sensitive."))
			return
		end
	end

	minetest.register_chatcommand("tpp", {
		description = S("Teleport to a place (i.e., spawn, shop)."),
		params = S("<place> | leave empty to see available places"),
		privs = {},
		func = tp.tpp
	})
end
