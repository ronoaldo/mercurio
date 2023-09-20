local mod_playerphysics = minetest.get_modpath("playerphysics") ~= nil
local mod_player_api = minetest.get_modpath("player_api") ~= nil

local function top_face(pointed_thing)
	if not pointed_thing then return end
	return pointed_thing.above.y > pointed_thing.under.y
end

function xdecor.sit(pos, node, clicker, pointed_thing)
	if not mod_player_api then return end
	if not top_face(pointed_thing) then return end
	local player_name = clicker:get_player_name()
	local objs = minetest.get_objects_inside_radius(pos, 0.1)
	local vel = clicker:get_velocity()
	local ctrl = clicker:get_player_control()

	for _, obj in pairs(objs) do
		if obj:is_player() and obj:get_player_name() ~= player_name then
			return
		end
	end

	if player_api.player_attached[player_name] then
		clicker:set_pos(pos)
		clicker:set_eye_offset(vector.new(), vector.new())
		if mod_playerphysics then
			playerphysics.remove_physics_factor(clicker, "speed", "xdecor:sit_speed")
			playerphysics.remove_physics_factor(clicker, "jump", "xdecor:sit_jump")
		else
			clicker:set_physics_override({speed = 1, jump = 1})
		end
		player_api.player_attached[player_name] = false
		player_api.set_animation(clicker, "stand", 30)

	elseif not player_api.player_attached[player_name] and node.param2 <= 3 and
			not ctrl.sneak and vector.equals(vel, vector.new()) then

		clicker:set_eye_offset({x = 0, y = -7, z = 2}, vector.new())
		if mod_playerphysics then
			playerphysics.add_physics_factor(clicker, "speed", "xdecor:sit_speed", 0)
			playerphysics.add_physics_factor(clicker, "jump", "xdecor:sit_jump", 0)
		else
			clicker:set_physics_override({speed = 0, jump = 0})
		end
		clicker:set_pos(pos)
		player_api.player_attached[player_name] = true
		player_api.set_animation(clicker, "sit", 30)

		if node.param2 == 0 then
			clicker:set_look_horizontal(0)
		elseif node.param2 == 1 then
			clicker:set_look_horizontal(3*(math.pi/2))
		elseif node.param2 == 2 then
			clicker:set_look_horizontal(math.pi)
		elseif node.param2 == 3 then
			clicker:set_look_horizontal(math.pi/2)
		end
	end
end

function xdecor.sit_dig(pos, digger)
	if not mod_player_api then
		return true
	end
	for _, player in pairs(minetest.get_objects_inside_radius(pos, 0.1)) do
		if player:is_player() and
			    player_api.player_attached[player:get_player_name()] then
			return false
		end
	end

	return true
end
