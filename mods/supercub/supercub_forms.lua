dofile(minetest.get_modpath("supercub") .. DIR_DELIM .. "supercub_global_definitions.lua")

--------------
-- Manual --
--------------

function supercub.getPlaneFromPlayer(player)
    local seat = player:get_attach()
    if seat then
        local plane = seat:get_attach()
        return plane
    end
    return nil
end

function supercub.pilot_formspec(name)
    local basic_form = table.concat({
        "formspec_version[3]",
        "size[6,6]",
	}, "")

	basic_form = basic_form.."button[1,1.0;4,1;go_out;Go Offboard]"
	basic_form = basic_form.."button[1,2.5;4,1;hud;Show/Hide Gauges]"
    basic_form = basic_form.."button[1,4.0;4,1;manual;Show Manual]"

    minetest.show_formspec(name, "supercub:pilot_main", basic_form)
end

minetest.register_on_player_receive_fields(function(player, formname, fields)
	if formname == "supercub:pilot_main" then
        local name = player:get_player_name()
        local plane_obj = supercub.getPlaneFromPlayer(player)
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
                local touching_ground, liquid_below = airutils.check_node_below(plane_obj, 1.3)
                local is_on_ground = ent.isinliquid or touching_ground or liquid_below

                if is_on_ground then --or clicker:get_player_control().sneak then
                    if ent._passenger then --any pax?
                        local pax_obj = minetest.get_player_by_name(ent._passenger)
                        supercub.dettach_pax(ent, pax_obj)
                    end
                    ent._instruction_mode = false
                    --[[ sound and animation
                    if ent.sound_handle then
                        minetest.sound_stop(ent.sound_handle)
                        ent.sound_handle = nil
                    end
                    ent.engine:set_animation_frame_speed(0)]]--
                else
                    -- not on ground
                    if ent._passenger then
                        --give the control to the pax
                        ent._autopilot = false
                        airutils.transfer_control(ent, true)
                        ent._command_is_given = true
                        ent._instruction_mode = true
                    end
                end
                supercub.dettachPlayer(ent, player)
		    end
            if fields.manual then
                supercub.manual_formspec(name)
            end
        end
        minetest.close_formspec(name, "supercub:pilot_main")
    end
end)
