

supercub={}
supercub.gravity = tonumber(minetest.settings:get("movement_gravity")) or 9.8
supercub.wing_angle_of_attack = 1.5
supercub.min_speed = 6
supercub.max_speed = 8
supercub.max_engine_acc = 7.5
supercub.lift = 10
supercub.trunk_slots = 12

dofile(minetest.get_modpath("supercub") .. DIR_DELIM .. "supercub_global_definitions.lua")
dofile(minetest.get_modpath("supercub") .. DIR_DELIM .. "supercub_control.lua")
dofile(minetest.get_modpath("supercub") .. DIR_DELIM .. "supercub_fuel_management.lua")
dofile(minetest.get_modpath("supercub") .. DIR_DELIM .. "supercub_custom_physics.lua")
dofile(minetest.get_modpath("supercub") .. DIR_DELIM .. "supercub_utilities.lua")
dofile(minetest.get_modpath("supercub") .. DIR_DELIM .. "supercub_entities.lua")
dofile(minetest.get_modpath("supercub") .. DIR_DELIM .. "supercub_manual.lua")
dofile(minetest.get_modpath("supercub") .. DIR_DELIM .. "supercub_forms.lua")
dofile(minetest.get_modpath("supercub") .. DIR_DELIM .. "supercub_crafts.lua")

--
-- helpers and co.
--

--
-- items
--

settings = Settings(minetest.get_worldpath() .. "/supercub_settings.conf")
local function fetch_setting(name)
    local sname = name
    return settings and settings:get(sname) or minetest.settings:get(sname)
end

supercub.restricted = fetch_setting("restricted")

minetest.register_privilege("flight_licence", {
    description = "Gives a flight licence to the player",
    give_to_singleplayer = true
})

-- add chatcommand to eject from hydroplane

minetest.register_chatcommand("cub_eject", {
	params = "",
	description = "Ejects from Super Cub",
	privs = {interact = true},
	func = function(name, param)
        local colorstring = core.colorize('#ff0000', " >>> you are not inside your Super Cub")
        local player = minetest.get_player_by_name(name)
        local attached_to = player:get_attach()

		if attached_to ~= nil then
            local seat = attached_to:get_attach()
            if seat ~= nil then
                local entity = seat:get_luaentity()
                if entity then
                    if entity.name == "supercub:supercub" then
                        if entity.driver_name == name then
                            supercub.dettachPlayer(entity, player)
                        elseif entity._passenger == name then
                            local passenger = minetest.get_player_by_name(entity._passenger)
                            supercub.dettach_pax(entity, passenger)
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

minetest.register_chatcommand("cub_manual", {
	params = "",
	description = "Super Cub operation manual",
	privs = {interact = true},
	func = function(name, param)
        supercub.manual_formspec(name)
	end
})

