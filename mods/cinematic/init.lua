-- Copyright (c) 2021 Dmitry Kostenko. Licensed under AGPL v3

-- Parsing utilities

local function starts_with(str, prefix)
	return str:sub(1, #prefix) == prefix
end

local function skip_prefix(str, prefix)
	return str:sub(#prefix + 1)
end

local function string_split(str, char)
	result = {}
	for part in str:gmatch("[^"..char.."]+") do
		table.insert(result, part)
	end
	return result
end

local function is_in(item, set)
	for _,valid in ipairs(set) do
		if item == valid then return true end
	end
	return false
end

-- Position helpers

local position = {}
function position.save(player, slot)
	local state = { pos = player:get_pos(), look = { h = player:get_look_horizontal(), v = player:get_look_vertical() }}
	player:get_meta():set_string("cc_pos_"..slot, minetest.serialize(state))
end

function position.get(player, slot)
	local state = player:get_meta():get_string("cc_pos_"..slot)
	if state == nil then
		return nil, "Saved position not found"
	end

	state = minetest.deserialize(state)
	if state == nil then
		return nil, "Saved position could not be restored"
	end

	return state
end

function position.restore(player, slot)
	local state,message = position.get(player, slot)
	if state == nil then
		minetest.chat_send_player(player:get_player_name(), message)
		return
	end

	player:set_pos(state.pos)
	player:set_look_horizontal(state.look.h)
	player:set_look_vertical(state.look.v)
end

function position.clear(player, slot)
	player:get_meta():set_string("cc_pos_"..slot, "")
end

function position.list(player)
	local result = {}
  for key,_ in pairs(player:get_meta():to_table().fields) do
		if starts_with(key, "cc_pos_") then
			table.insert(result, skip_prefix(key, "cc_pos_"))
		end
	end
	return result
end

-- Core API
local cinematic
cinematic = {
	motions = {},
	register_motion = function(name, definition)
		definition.name = name
		cinematic.motions[name] = definition
		table.insert(cinematic.motions, definition)
	end,

	commands = {},
	register_command = function(name, definition)
		definition.name = name
		cinematic.commands[name] = definition
		table.insert(cinematic.commands, definition)
	end,

	players = {},
	start = function(player, motion, params)
		local player_name = player:get_player_name()
		-- Stop previous motion and clean up
		if cinematic.players[player_name] ~= nil then
			player:set_fov(unpack(cinematic.players[player_name].fov))
			cinematic.players[player_name] = nil
		end

		local state = cinematic.motions[motion].initialize(player, params)
		-- motion can return nil from initialize to abort the process
		if state ~= nil then
			position.save(player, "auto")
			cinematic.players[player_name] = { player = player, motion = motion, state = state, fov = {player:get_fov()} }

			if params.fov == "wide" then
				params.fov = 1.4
			elseif params.fov == "narrow" then
				params.fov = 0.5
			elseif params.fov ~= nil then
				params.fov = tonumber(params.fov)
			end
			if params.fov ~= nil then
				player:set_fov(params.fov, true)
			end
		end
	end,
	stop = function(player)
		cinematic.start(player, "stop", {})
	end,
}

-- Update loop

minetest.register_globalstep(function()
	for _, entry in pairs(cinematic.players) do
		cinematic.motions[entry.motion].tick(entry.player, entry.state)
	end
end)

-- Motions

cinematic.register_motion("360", {
	initialize = function(player, params)
		local player_pos = player:get_pos()
		local center = vector.add(player_pos, vector.multiply(vector.normalize(player:get_look_dir()), params.radius or 50))
		return {
			center = center,
			distance = vector.distance(vector.new(center.x, 0, center.z), vector.new(player_pos.x, 0, player_pos.z)),
			angle = minetest.dir_to_yaw(vector.subtract(player_pos, center)) + math.pi / 2,
			height = player_pos.y - center.y,
			speed = params:get_speed({"l", "left"}, "right"),
		}
	end,
	tick = function(player, state)
		state.angle = state.angle + state.speed * math.pi / 3600
		if state.angle < 0 then state.angle = state.angle + 2 * math.pi end
		if state.angle > 2 * math.pi then state.angle = state.angle - 2 * math.pi end

		player_pos = vector.add(state.center, vector.new(state.distance * math.cos(state.angle), state.height, state.distance * math.sin(state.angle)))
		player:set_pos(player_pos)
		player:set_look_horizontal(state.angle + math.pi / 2)
	end
})

cinematic.register_motion("dolly", {
	initialize = function(player, params)
		return {
			speed = params:get_speed({"b", "back", "backwards", "out"}, "forward"),
			direction = vector.normalize(vector.new(player:get_look_dir().x, 0, player:get_look_dir().z)),
		}
	end,
	tick = function(player, state)
		local player_pos = player:get_pos()

		player_pos = vector.add(player_pos, vector.multiply(state.direction, state.speed * 0.05))
		player:set_pos(player_pos)
	end
})

cinematic.register_motion("truck", {
	initialize = function(player, params)
		return {
			speed = params:get_speed({"l", "left"}, "right"),
			direction = vector.normalize(vector.cross(vector.new(0,1,0), player:get_look_dir())),
		}
	end,
	tick = function(player, state)
		local player_pos = player:get_pos()

		player_pos = vector.add(player_pos, vector.multiply(state.direction, state.speed * 0.05))
		player:set_pos(player_pos)
	end
})

cinematic.register_motion("pedestal", {
	initialize = function(player, params)
		return {
			speed = params:get_speed({"d", "down"}, "up"),
			direction = vector.new(0,1,0)
		}
	end,
	tick = function(player, state)
		local player_pos = player:get_pos()

		player_pos = vector.add(player_pos, vector.multiply(state.direction, state.speed * 0.05))
		player:set_pos(player_pos)
	end
})

cinematic.register_motion("pan", {
	initialize = function(player, params)
		return {
			speed = params:get_speed({"l", "left"}, "right"),
			angle = player:get_look_horizontal()
		}
	end,
	tick = function(player, state)
		state.angle = state.angle - state.speed * math.pi / 3600
		if state.angle < 0 then state.angle = state.angle + 2 * math.pi end
		if state.angle > 2 * math.pi then state.angle = state.angle - 2 * math.pi end
		player:set_look_horizontal(state.angle)
	end
})

cinematic.register_motion("tilt", {
	initialize = function(player, params)
		return {
			speed = params:get_speed({"d", "down"}, "up"),
			angle = player:get_look_vertical()
		}
	end,
	tick = function(player, state)
		state.angle = state.angle - state.speed * math.pi / 3600
		if state.angle < 0 then state.angle = state.angle + 2 * math.pi end
		if state.angle > 2 * math.pi then state.angle = state.angle - 2 * math.pi end
		player:set_look_vertical(state.angle)
	end
})

cinematic.register_motion("zoom", {
	initialize = function(player, params)
		return {
			speed = params:get_speed({"out"}, "in"),
		}
	end,
	tick = function(player, state)
		-- Capture initial FOV at the tick
		-- This is not possible in initialize because the FOV modifier has not been applied yet
		if state.fov == nil then
			local fov = {player:get_fov()}
			minetest.chat_send_all(dump(fov,""))
			if fov[1] == 0 then
				fov[1] = 1
				fov[2] = true
			end
			fov[3] = 0
			state.fov = fov
		end
		state.fov[1] = state.fov[1] - 0.001 * state.speed
		player:set_fov(unpack(state.fov))
	end
})

cinematic.register_motion("stop", {initialize = function() end})
cinematic.register_motion("revert", {initialize = function(player) position.restore(player, "auto") end})

cinematic.register_command("pos", {
	run = function(player, args)
		local slot = args[2] or "default"

		if args[1] == "save" then
			position.save(player, slot)
			return true
		elseif args[1] == "restore" then
			position.restore(player, slot)
			return true
		elseif args[1] == "clear" then
			position.clear(player, slot)
		elseif args[1] == "list" then
			for _,slot in ipairs(position.list(player)) do
				minetest.chat_send_player(player:get_player_name(), slot)
			end
		else
			return false, "Unknown subcommand"..args[1]
		end
	end
})


-- Chat command handler

minetest.register_chatcommand("cc", {
	params = "((360|tilt|pan|truck|dolly|pedestal) [direction=(right|left|in|out|up|down)] [speed=<speed>] [radius=<radius>] | pos ((save|restore|clear [<name>])|list)) | (stop|revert)",
	description = "Simulate cinematic camera motion",
	privs = { fly = true },
	func = function(name, cmdline)
		local player = minetest.get_player_by_name(name)
		local params = {}
		local parts = string_split(cmdline, " ")

		local command = parts[1]
		table.remove(parts, 1)
		-- Handle commands
		if cinematic.commands[command] ~= nil then
			return cinematic.commands[command].run(player, parts)
		end

		if cinematic.motions[command] == nil then
			return false, "Invalid command or motion, see /help cc"
		end

		-- Parse command line
		for i = 1,#parts do
			local parsed = false
			for _,setting in ipairs({ "direction", "dir", "speed", "v", "radius", "r", "fov" }) do
				if not parsed and starts_with(parts[i], setting.."=") then
					params[setting] = skip_prefix(parts[i], setting.."=")
					parsed = true
				end
			end
			if not parsed then
				return false, "Invalid parameter "..parts[i]
			end
		end

		-- Fix parameters
		params.direction = params.direction or params.dir
		params.speed = params.speed or params.v
		params.radius = params.radius or params.r

		params.speed = (params.speed and tonumber(params.speed))
		params.radius = (params.radius and tonumber(params.radius))

		params.get_speed = function(self, negative_dirs, default_dir)
			return (self.speed or 1) * (is_in(self.direction or default_dir, negative_dirs) and -1 or 1)
		end

		cinematic.start(player, command, params)
		return true,""
	end
})

