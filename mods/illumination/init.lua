
local player_lights = {}

local function can_replace(pos)
	local nn = minetest.get_node(pos).name
	return nn == "air" or minetest.get_item_group(nn, "illumination_light") > 0
end

local function remove_light(pos)
	if pos and can_replace(pos) then
		minetest.set_node(pos, {name = "air"})
	end
end

local function get_light_node(player)
	local light = 0
	-- Light from wielded item/tool/node
	local item = player:get_wielded_item():get_name()
	local def = minetest.registered_items[item]
	if def and def.light_source then
		light = def.light_source
	end
	-- Light from armor or other worn items
	local name = player:get_player_name()
	local armor_light = player_lights[name].armor_light
	if armor_light and armor_light > light then
		light = armor_light
	end
	if light >= 14 then
		return "illumination:light_14"
	elseif light < 1 then
		return nil
	end
	return "illumination:light_"..light
end

local function find_light_pos(pos)
	-- Check feet and head positions first
	if can_replace(pos) then
		return pos
	end
	pos.y = pos.y + 1
	if can_replace(pos) then
		return pos
	end
	-- Otherwise look around player's head
	return minetest.find_node_near(pos, 1, {"air", "group:illumination_light"})
end

local function update_illumination(player, dtime)
	local name = player:get_player_name()
	if not player_lights[name] then
		return  -- Player has just joined/left
	end
	local pos = vector.round(vector.add(player:get_pos(), vector.multiply(player:get_velocity(), dtime*2)))
	local old_pos = player_lights[name].pos
	local player_pos = player_lights[name].player_pos
	local node = get_light_node(player)
	-- Check if illumination needs updating
	if old_pos and player_pos then
		if node == minetest.get_node(old_pos).name and vector.equals(pos, player_pos) then
			return  -- Already has illumination
		end
	end
	-- Update illumination
	player_lights[name].player_pos = pos
	if node then
		local new_pos = find_light_pos(pos)
		if new_pos then
			minetest.set_node(new_pos, {name = node})
			if old_pos and not vector.equals(old_pos, new_pos) then
				remove_light(old_pos)
			end
			player_lights[name].pos = new_pos
			return
		end
	end
	-- No illumination
	remove_light(old_pos)
	player_lights[name].pos = nil
end

minetest.register_globalstep(function(dtime)
	for _, player in pairs(minetest.get_connected_players()) do
		update_illumination(player, dtime)
	end
end)

minetest.register_on_joinplayer(function(player)
	local name = player:get_player_name()
	if not player_lights[name] then
		player_lights[name] = {}
	end
end)

minetest.register_on_leaveplayer(function(player)
	local name = player:get_player_name()
	if player_lights[name] then
		remove_light(player_lights[name].pos)
	end
	player_lights[name] = nil
end)

-- Support for luminescent armor
if minetest.get_modpath("3d_armor") then
	armor:register_on_update(function(player)
		local name, inv = armor:get_valid_player(player)
		if name then
			local light = 0
			for i=1, inv:get_size("armor") do
				local item = inv:get_stack("armor", i):get_name()
				local def = minetest.registered_items[item]
				if def and def.light_source and def.light_source > light then
					light = def.light_source
				end
			end
			if player_lights[name] then
				player_lights[name].armor_light = light
			else
				-- Armor updated before illumination
				player_lights[name] = {armor_light = light}
			end
		end
	end)
end

-- Light node for every light level
for n = 1, 14 do
	minetest.register_node("illumination:light_"..n, {
		drawtype = "airlike",
		paramtype = "light",
		light_source = n,
		sunlight_propagates = true,
		walkable = false,
		pointable = false,
		buildable_to = true,
		groups = {
			not_in_creative_inventory = 1,
			not_blocking_trains = 1,
			illumination_light = 1,
		},
		drop = "",
	})
end

-- Cleanup for leftover and player-placed illumination lights
minetest.register_lbm({
	label = "Illumination light cleanup",
	name = "illumination:light_cleanup",
	nodenames = {"group:illumination_light"},
	run_at_every_load = true,
	action = function(pos)
		minetest.set_node(pos, {name = "air"})
	end,
})

-- Aliases for old illumination lights
minetest.register_alias("illumination:light_faint", "illumination:light_4")
minetest.register_alias("illumination:light_dim", "illumination:light_8")
minetest.register_alias("illumination:light_mid", "illumination:light_12")
minetest.register_alias("illumination:light_full", "illumination:light_14")
