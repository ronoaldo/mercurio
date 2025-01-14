local mod_player_api = minetest.get_modpath("player_api") ~= nil

local sitting = {}
local seats_occupied = {}

local function bottom_face(pointed_thing)
	if not pointed_thing then
		return
	end
	return pointed_thing.above.y < pointed_thing.under.y
end

local function stand_up(player_name)
	if not mod_player_api then
		return
	end
	local player = minetest.get_player_by_name(player_name)
	if not player then
		return
	end
	player_api.player_attached[player_name] = false

	local old_anim = player_api.get_animation(player)
	if old_anim and old_anim.animation == "sit" then
		player_api.set_animation(player, "stand")
	end

	local hash = minetest.hash_node_position(sitting[player_name])
	seats_occupied[hash] = nil
	sitting[player_name] = nil

	minetest.log("action", "[xdecor] "..player_name.." stands up at "..minetest.pos_to_string(player:get_pos(), 0))
end

--[[ Used when player interacts with "sittable" node to sit down
or stand up when interacting with that node again. Should
be used in `on_rightclick` handler
* `pos`: Position where to sit down player (MUST only use integers for coordinates!)
* `node`: Node table of node to sit on
* `clicker`: Player who interacted with node (from `on_rightclick`)
* `pointed_thing`: From `on_rightclick` ]]
function xdecor.sit(pos, node, clicker, pointed_thing)
	if not mod_player_api then
		return
	end
	-- Can't sit down if bottom face was pointed at
	if bottom_face(pointed_thing) then
		return
	end
	local player_name = clicker:get_player_name()
	local objs = minetest.get_objects_inside_radius(pos, 0.1)
	local vel = clicker:get_velocity()
	local ctrl = clicker:get_player_control()

	-- Stand up if sitting
	if sitting[player_name] then
		stand_up(player_name)

	-- Sit down if not sitting and not attached
	elseif not sitting[player_name] and not player_api.player_attached[player_name] and node.param2 <= 3 and
			not ctrl.sneak and vector.equals(vel, vector.new()) then

		-- Can't sit down on note already occupied by player
		local hash = minetest.hash_node_position(pos)
		if seats_occupied[hash] then
			return
		end

		player_api.player_attached[player_name] = true
		player_api.set_animation(clicker, "sit")
		sitting[player_name] = table.copy(pos)
		seats_occupied[hash] = player_name
		clicker:set_pos(pos)

		if node.param2 == 0 then
			clicker:set_look_horizontal(0)
		elseif node.param2 == 1 then
			clicker:set_look_horizontal(3*(math.pi/2))
		elseif node.param2 == 2 then
			clicker:set_look_horizontal(math.pi)
		elseif node.param2 == 3 then
			clicker:set_look_horizontal(math.pi/2)
		end

		minetest.log("action", "[xdecor] "..player_name.." sits down at "..minetest.pos_to_string(pos, 0))
	end
end

-- Called when `digger` (a player object) wants to
-- dig a node at pos. Returns true if it's allowed,
-- false otherwise. This checks if the node at pos
-- is an occupied sittable node.
-- Can be used for the `can_dig` node function.
function xdecor.sit_dig(pos, digger)
	if not mod_player_api then
		return true
	end
	local hash = minetest.hash_node_position(pos)
	if seats_occupied[hash] then
		return false
	end

	return true
end

-- To be called when a seat (sittable node) got destroyed
-- to clean up state. Precisely, this should be used
-- as the `after_destruct` handler.
function xdecor.sit_destruct(pos)
	local hash = minetest.hash_node_position(pos)
	local occupier = seats_occupied[hash]
	if occupier then
		stand_up(occupier)
		seats_occupied[hash] = nil
		sitting[occupier] = nil
	end
end

-- Automatically cause players to stand up if they pressed a control
-- or moved away from the seat
minetest.register_globalstep(function(dtime)
	local to_stand_up = {}
	for player_name, sitting_pos in pairs(sitting) do
		local player = minetest.get_player_by_name(player_name)
		if player then
			local ctrl = player:get_player_control()
			if ctrl.up or ctrl.down or ctrl.left or ctrl.right or ctrl.sneak or ctrl.jump then
				table.insert(to_stand_up, player_name)
			elseif vector.distance(player:get_pos(), sitting_pos) > 0.55 then
				table.insert(to_stand_up, player_name)
			end
		end
	end
	for s=1, #to_stand_up do
		stand_up(to_stand_up[s])
	end
end)

-- Force player to stand on death (to the seat is released)
minetest.register_on_dieplayer(function(player)
	local player_name = player:get_player_name()
	if sitting[player_name] then
		stand_up(player_name)
	end
end)

minetest.register_on_leaveplayer(function(player)
	local player_name = player:get_player_name()
	if sitting[player_name] then
		local hash = minetest.hash_node_position(sitting[player_name])
		seats_occupied[hash] = nil
		sitting[player_name] = nil
	end
end)
