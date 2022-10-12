demoiselle={}

demoiselle.gravity = tonumber(minetest.settings:get("movement_gravity")) or 9.8
demoiselle.wing_angle_of_attack = 2
demoiselle.min_speed = 3
demoiselle.max_speed = 6
demoiselle.max_engine_acc = 5
demoiselle.lift = 16 --12

dofile(minetest.get_modpath("demoiselle") .. DIR_DELIM .. "demoiselle_global_definitions.lua")
dofile(minetest.get_modpath("demoiselle") .. DIR_DELIM .. "demoiselle_crafts.lua")
dofile(minetest.get_modpath("demoiselle") .. DIR_DELIM .. "demoiselle_control.lua")
dofile(minetest.get_modpath("demoiselle") .. DIR_DELIM .. "demoiselle_fuel_management.lua")
dofile(minetest.get_modpath("demoiselle") .. DIR_DELIM .. "demoiselle_custom_physics.lua")
dofile(minetest.get_modpath("demoiselle") .. DIR_DELIM .. "demoiselle_utilities.lua")
dofile(minetest.get_modpath("demoiselle") .. DIR_DELIM .. "demoiselle_entities.lua")
dofile(minetest.get_modpath("demoiselle") .. DIR_DELIM .. "demoiselle_forms.lua")

--
-- helpers and co.
--

--
-- items
--

-- add chatcommand to eject from demoiselle

minetest.register_chatcommand("demoiselle_eject", {
	params = "",
	description = "Ejects from demoiselle",
	privs = {interact = true},
	func = function(name, param)
        local colorstring = core.colorize('#ff0000', " >>> you are not inside your demoiselle")
        local player = minetest.get_player_by_name(name)
        local attached_to = player:get_attach()

		if attached_to ~= nil then
            local parent = attached_to:get_attach()
            if parent ~= nil then
                local entity = parent:get_luaentity()
                if entity.driver_name == name and entity.name == "demoiselle:demoiselle" then
                    demoiselle.dettachPlayer(entity, player)
                else
			        minetest.chat_send_player(name,colorstring)
                end
            end
		else
			minetest.chat_send_player(name,colorstring)
		end
	end
})


