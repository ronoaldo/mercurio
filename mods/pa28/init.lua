

pa28={}
pa28.gravity = tonumber(minetest.settings:get("movement_gravity")) or 9.8
pa28.wing_angle_of_attack = 1.2
pa28.min_speed = 4
pa28.max_speed = 9
pa28.max_engine_acc = 8.5
pa28.lift = 8
pa28.trunk_slots = 16
pa28.plane_text = "PA28"
pa28.mode = 1 --1 -> velocity    2 -> acceleration

dofile(minetest.get_modpath("pa28") .. DIR_DELIM .. "global_definitions.lua")
dofile(minetest.get_modpath("pa28") .. DIR_DELIM .. "control.lua")
dofile(minetest.get_modpath("pa28") .. DIR_DELIM .. "fuel_management.lua")
dofile(minetest.get_modpath("pa28") .. DIR_DELIM .. "custom_physics.lua")
dofile(minetest.get_modpath("pa28") .. DIR_DELIM .. "utilities.lua")
dofile(minetest.get_modpath("pa28") .. DIR_DELIM .. "entities.lua")
dofile(minetest.get_modpath("pa28") .. DIR_DELIM .. "manual.lua")
dofile(minetest.get_modpath("pa28") .. DIR_DELIM .. "forms.lua")
dofile(minetest.get_modpath("pa28") .. DIR_DELIM .. "crafts.lua")

--
-- helpers and co.
--

--
-- items
--

settings = Settings(minetest.get_worldpath() .. "/settings.conf")
local function fetch_setting(name)
    local sname = name
    return settings and settings:get(sname) or minetest.settings:get(sname)
end

pa28.restricted = fetch_setting("restricted")

minetest.register_privilege("flight_licence", {
    description = "Gives a flight licence to the player",
    give_to_singleplayer = true
})

-- add chatcommand to eject from hydroplane

minetest.register_chatcommand("pa28_eject", {
	params = "",
	description = "Ejects from PA28",
	privs = {interact = true},
	func = function(name, param)
        local colorstring = core.colorize('#ff0000', " >>> you are not inside your PA28")
        local player = minetest.get_player_by_name(name)
        local attached_to = player:get_attach()

		if attached_to ~= nil then
            local seat = attached_to:get_attach()
            if seat ~= nil then
                local entity = seat:get_luaentity()
                if entity then
                    if entity.name == "pa28:pa28" then
                        if entity.driver_name == name then
                            pa28.dettachPlayer(entity, player)
                        elseif entity._passenger == name then
                            local passenger = minetest.get_player_by_name(entity._passenger)
                            pa28.dettach_pax(entity, passenger)
                        end
                    else
			            minetest.chat_send_player(name,colorstring)
                    end
                end
            end
		else
			minetest.chat_send_player(name,colorstring)
		end
	end
})

minetest.register_chatcommand("pa28_manual", {
	params = "",
	description = "PA28 operation manual",
	privs = {interact = true},
	func = function(name, param)
        pa28.manual_formspec(name)
	end
})

--[[minetest.register_chatcommand("pa28_up", {
	params = "",
	description = "Command for test the PA28, putting 100 blocks up - only works with server priv",
	privs = {server = true},
	func = function(name, param)
        local colorstring = core.colorize('#ff0000', " >>> you are not inside a PA28")
        local player = minetest.get_player_by_name(name)
        local attached_to = player:get_attach()

		if attached_to ~= nil then
            local seat = attached_to:get_attach()
            if seat ~= nil then
                local entity = seat:get_luaentity()
                if entity then
                    if entity.name == "pa28:pa28" then
                        local curr_pos = player:get_pos()
                        curr_pos.y = curr_pos.y + 100
                        entity.object:move_to(curr_pos)
                    else
			            minetest.chat_send_player(name,colorstring)
                    end
                end
            end
		else
			minetest.chat_send_player(name,colorstring)
		end
	end
})]]--
