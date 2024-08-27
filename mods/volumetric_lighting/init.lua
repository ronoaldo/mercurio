
local S = minetest.get_translator('volumetric_lighting')
local storage = minetest.get_mod_storage()

local default_strength = tonumber(minetest.settings:get("volumetric_lighting_default_strength") or 0.1)
local strength = tonumber(storage:get("strength") or default_strength)

minetest.register_on_joinplayer(function(player)
	player:set_lighting({
		volumetric_light = { strength = strength }
	})
end)

core.register_chatcommand("light_strength", {
	params = "<strength>",
	description = S("Set volumetric lighting strength for the current world."),
	func = function(name, param)
		local new_strength
		if param ~= "" then
			new_strength = tonumber(param) or nil
		else
			new_strength = tonumber(default_strength) or nil
		end

		if new_strength < 0 or new_strength > 1 or new_strength == nil then
			minetest.chat_send_player(name, minetest.colorize("#ff0000", S("Invalid strength.")))
			return true
		end

		if new_strength ~= default_strength then
			minetest.chat_send_player(name, S("Set strength to @1.", new_strength))
			storage:set_float("strength", new_strength)
		else
			minetest.chat_send_player(name, S("Set strength to default value (@1).", default_strength))
			storage:set_string("strength", "")
		end

		strength = new_strength
		for _,player in pairs(minetest.get_connected_players()) do
			player:set_lighting({
				volumetric_light = { strength = new_strength }
			})
		end
	end
})
