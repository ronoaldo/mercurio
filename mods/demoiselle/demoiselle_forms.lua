dofile(minetest.get_modpath("demoiselle") .. DIR_DELIM .. "demoiselle_global_definitions.lua")

--------------
-- Manual --
--------------

function demoiselle.getPlaneFromPlayer(player)
    local seat = player:get_attach()
    if seat then
        local plane = seat:get_attach()
        return plane
    end
    return nil
end

function demoiselle.pilot_formspec(name)
    local player = minetest.get_player_by_name(name)
    local plane_obj = demoiselle.getPlaneFromPlayer(player)
    if plane_obj == nil then
        return
    end
    local ent = plane_obj:get_luaentity()

    local basic_form = table.concat({
        "formspec_version[3]",
        "size[6,6]",
	}, "")

    local yaw = "false"
    if ent._yaw_by_mouse then yaw = "true" end
    local pitch = "false"
    if ent._pitch_by_mouse then pitch = "true" end

	basic_form = basic_form.."button[1,1.0;4,1;go_out;Go Offboard]"
	basic_form = basic_form.."button[1,2.5;4,1;hud;Show/Hide Gauges]"
    basic_form = basic_form.."checkbox[1,4.0;yaw;Yaw by mouse;"..yaw.."]"
    basic_form = basic_form.."checkbox[1,4.8;pitch;Pitch by mouse;"..pitch.."]"

    minetest.show_formspec(name, "demoiselle:pilot_main", basic_form)
end

minetest.register_on_player_receive_fields(function(player, formname, fields)
	if formname == "demoiselle:pilot_main" then
        local name = player:get_player_name()
        local plane_obj = demoiselle.getPlaneFromPlayer(player)
        if plane_obj then
            local ent = plane_obj:get_luaentity()
            if fields.hud then
                if ent._show_hud == true then
                    ent._show_hud = false
                else
                    ent._show_hud = true
                end
            end
		    if fields.go_out then
                demoiselle.dettachPlayer(ent, player)
		    end
            if fields.yaw then
                if ent._yaw_by_mouse == true then
                    ent._yaw_by_mouse = false
                else
                    ent._yaw_by_mouse = true
                end
            end
            if fields.pitch then
                if ent._pitch_by_mouse == true then
                    ent._pitch_by_mouse = false
                else
                    ent._pitch_by_mouse = true
                end
            end
        end
        minetest.close_formspec(name, "demoiselle:pilot_main")
    end
end)
