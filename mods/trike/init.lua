trike={}
trike.gravity = tonumber(minetest.settings:get("movement_gravity")) or 9.8

trike.colors ={
    black='#2b2b2b',
    blue='#0063b0',
    brown='#8c5922',
    cyan='#07B6BC',
    dark_green='#567a42',
    dark_grey='#6d6d6d',
    green='#4ee34c',
    grey='#9f9f9f',
    magenta='#ff0098',
    orange='#ff8b0e',
    pink='#ff62c6',
    red='#dc1818',
    violet='#a437ff',
    white='#FFFFFF',
    yellow='#ffe400',
}

trike.trunk_slots = 3

dofile(minetest.get_modpath("trike") .. DIR_DELIM .. "trike_global_definitions.lua")
dofile(minetest.get_modpath("trike") .. DIR_DELIM .. "trike_crafts.lua")
dofile(minetest.get_modpath("trike") .. DIR_DELIM .. "trike_control.lua")
dofile(minetest.get_modpath("trike") .. DIR_DELIM .. "trike_fuel_management.lua")
dofile(minetest.get_modpath("trike") .. DIR_DELIM .. "trike_custom_physics.lua")
dofile(minetest.get_modpath("trike") .. DIR_DELIM .. "trike_utilities.lua")
dofile(minetest.get_modpath("trike") .. DIR_DELIM .. "trike_entities.lua")
dofile(minetest.get_modpath("trike") .. DIR_DELIM .. "trike_hud.lua")
dofile(minetest.get_modpath("trike") .. DIR_DELIM .. "trike_forms.lua")

--
-- helpers and co.
--

--
-- items
--

settings = Settings(minetest.get_worldpath() .. "/trike_settings.conf")
local function fetch_setting(name)
    local sname = name
    return settings and settings:get(sname) or minetest.settings:get(sname)
end

trike.restricted = fetch_setting("restricted")

minetest.register_privilege("flight_licence", {
    description = "Gives a flight licence to the player",
    give_to_singleplayer = true
})


-- add chatcommand to eject from trike

minetest.register_chatcommand("trike_eject", {
	params = "",
	description = "Ejects from trike",
	privs = {interact = true},
	func = function(name, param)
        local colorstring = core.colorize('#ff0000', " >>> you are not inside your ultralight trike")
        local player = minetest.get_player_by_name(name)
        local attached_to = player:get_attach()

		if attached_to ~= nil then
            local parent = attached_to:get_attach()
            if parent ~= nil then
                local entity = parent:get_luaentity()
                if entity.driver_name == name and entity.name == "trike:trike" then
                    trike.dettachPlayer(entity, player)
                else
			        minetest.chat_send_player(name,colorstring)
                end
            end
		else
			minetest.chat_send_player(name,colorstring)
		end
	end
})
