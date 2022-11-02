dofile(minetest.get_modpath("pa28") .. DIR_DELIM .. "global_definitions.lua")

--------------
-- Manual --
--------------

function pa28.getPlaneFromPlayer(player)
    local seat = player:get_attach()
    if seat then
        local plane = seat:get_attach()
        return plane
    end
    return nil
end

function pa28.pilot_formspec(name)
    local basic_form = table.concat({
        "formspec_version[5]",
        "size[6,12.6]",
	}, "")

    local player = minetest.get_player_by_name(name)
    local plane_obj = pa28.getPlaneFromPlayer(player)
    if plane_obj == nil then
        return
    end
    local ent = plane_obj:get_luaentity()

    local pass_list = ""
    for k, v in pairs(ent._passengers) do
        pass_list = pass_list .. v .. ","
    end

    local flap_is_down = "false"
    if ent._flap then flap_is_down = "true" end
    local light = "false"
    if ent._land_light then light = "true" end
    local adf = "false"
    if ent._adf then adf = "true" end
    local x, z = 0
    if ent._adf_destiny then
        if ent._adf_destiny.x then
            if type(ent._adf_destiny.x) ~= nil then
                x = math.floor(ent._adf_destiny.x)
            end
        end
        if ent._adf_destiny.z then
            if type(ent._adf_destiny.z) ~= nil then
                z = math.floor(ent._adf_destiny.z)
            end
        end
    else
        return
    end

    local yaw = "false"
    if ent._yaw_by_mouse then yaw = "true" end

    local copilot_name = "test"
	basic_form = basic_form.."button[1,1.0;4,1;turn_on;Start/Stop Engines]"
    basic_form = basic_form.."button[1,2.0;4,1;hud;Show/Hide Gauges]"
    basic_form = basic_form.."button[1,3.0;4,1;turn_auto_pilot_on;Auto Pilot]"
    basic_form = basic_form.."button[1,4.0;4,1;pass_control;Pass the Control]"
    basic_form = basic_form.."checkbox[1,5.8;flap_is_down;Flaps down;"..flap_is_down.."]"
    basic_form = basic_form.."checkbox[1,6.6;light;Landing Light;"..light.."]"
    basic_form = basic_form.."checkbox[1,7.4;adf;Auto Direction Find;"..adf.."]"

    basic_form = basic_form.."field[1,8.0;1.5,0.6;adf_x;pos x;"..x.."]"
    basic_form = basic_form.."field[2.7,8.0;1.5,0.6;adf_z;pos z;"..z.."]"
    basic_form = basic_form.."button[4.5,8.0;0.6,0.6;save_adf;OK]"

    basic_form = basic_form.."label[1,9.2;Bring a copilot:]"
    basic_form = basic_form.."dropdown[1,9.4;4,0.6;copilot;"..pass_list..";0;false]"
    basic_form = basic_form.."button[1,10.2;4,1;go_out;Go Offboard]"

    basic_form = basic_form.."checkbox[1,11.5;yaw;Yaw by mouse;"..yaw.."]"

    minetest.show_formspec(name, "pa28:pilot_main", basic_form)
end

function pa28.pax_formspec(name)
    local basic_form = table.concat({
        "formspec_version[3]",
        "size[6,5]",
	}, "")

	basic_form = basic_form.."button[1,1.0;4,1;new_seat;Change Seat]"
	basic_form = basic_form.."button[1,2.5;4,1;go_out;Go Offboard]"

    minetest.show_formspec(name, "pa28:passenger_main", basic_form)
end

function pa28.go_out_confirmation_formspec(name)
    local basic_form = table.concat({
        "formspec_version[3]",
        "size[7,2.2]",
	}, "")

    basic_form = basic_form.."label[0.5,0.5;Do you really want to go offboard now?]"
	basic_form = basic_form.."button[1.3,1.0;2,0.8;no;No]"
	basic_form = basic_form.."button[3.6,1.0;2,0.8;yes;Yes]"

    minetest.show_formspec(name, "pa28:go_out_confirmation_form", basic_form)
end

minetest.register_on_player_receive_fields(function(player, formname, fields)
    if formname == "pa28:go_out_confirmation_form" then
        local name = player:get_player_name()
        local plane_obj = pa28.getPlaneFromPlayer(player)
        if plane_obj == nil then
            minetest.close_formspec(name, "pa28:go_out_confirmation_form")
            return
        end
        local ent = plane_obj:get_luaentity()
        if ent then
		    if fields.yes then
                pa28.dettach_pax(ent, player)
		    end
        end
        minetest.close_formspec(name, "pa28:go_out_confirmation_form")
    end
	if formname == "pa28:passenger_main" then
        local name = player:get_player_name()
        local plane_obj = pa28.getPlaneFromPlayer(player)
        if plane_obj == nil then
            minetest.close_formspec(name, "pa28:passenger_main")
            return
        end
        local ent = plane_obj:get_luaentity()
        if ent then
		    if fields.new_seat then
                pa28.dettach_pax(ent, player)
                pa28.attach_pax(ent, player)
		    end
		    if fields.go_out then
                local touching_ground, liquid_below = airutils.check_node_below(plane_obj, 2.5)
                if ent.isinliquid or touching_ground then --isn't flying?
                    pa28.dettach_pax(ent, player)
                else
                    pa28.go_out_confirmation_formspec(name)
                end
		    end
        end
        minetest.close_formspec(name, "pa28:passenger_main")
	end
    if formname == "pa28:pilot_main" then
        local name = player:get_player_name()
        local plane_obj = pa28.getPlaneFromPlayer(player)
        if plane_obj == nil then
            minetest.close_formspec(name, "pa28:pilot_main")
            return
        end
        local ent = plane_obj:get_luaentity()
        if ent then
		    if fields.turn_on then
                pa28.start_engine(ent)
		    end
            if fields.hud then
                if ent._show_hud == true then
                    ent._show_hud = false
                else
                    ent._show_hud = true
                end
            end
		    if fields.turn_auto_pilot_on then
                ent._autopilot = true
                minetest.chat_send_player(ent.driver_name,core.colorize('#00ff00', " >>> Autopilot on"))
		    end
		    if fields.pass_control then
                if ent._command_is_given == true then
				    --take the control
				    airutils.transfer_control(ent, false)
                else
				    --trasnfer the control to student
				    airutils.transfer_control(ent, true)
                end
		    end
            if fields.flap_is_down then
                if fields.flap_is_down == "true" then
                    ent._flap = true
                else
                    ent._flap = false
                end
                minetest.sound_play("pa28_collision", {
                    object = ent.object,
                    max_hear_distance = 10,
                    gain = 1.0,
                    fade = 0.0,
                    pitch = 0.5,
                }, true)
            end
            if fields.light then
                if ent._land_light == true then
                    ent._land_light = false
                else
                    ent._land_light = true
                end
            end
            if fields.adf then
                if ent._adf == true then
                    ent._adf = false
                else
                    ent._adf = true
                end
            end
            if fields.save_adf then
                if ent._adf_destiny then
                    if fields.adf_x then
                        if tonumber(fields.adf_x, 10) ~= nil then
                            ent._adf_destiny.x = tonumber(fields.adf_x, 10)
                        end
                    end
                    if fields.adf_z then
                        if tonumber(fields.adf_z, 10) ~= nil then
                            ent._adf_destiny.z = tonumber(fields.adf_z, 10)
                        end
                    end
                end
            end
		    if fields.go_out then
                --=========================
                --  dettach player
                --=========================
                -- eject passenger if the plane is on ground
                local touching_ground, liquid_below = airutils.check_node_below(plane_obj, 2.5)
                if ent.isinliquid or touching_ground then --isn't flying?
                    --ok, remove pax
                    local passenger = nil
                    if ent._passenger then
                        passenger = minetest.get_player_by_name(ent._passenger)
                        if passenger then pa28.dettach_pax(ent, passenger) end
                    end
                    for i = 10,1,-1 
                    do 
                        if ent._passengers[i] then
                            passenger = minetest.get_player_by_name(ent._passengers[i])
                            if passenger then
                                pa28.dettach_pax(ent, passenger)
                                --minetest.chat_send_all('saiu')
                            end
                        end
                    end
                else
                    --give the control to the pax
                    if ent._passenger then
                        ent._autopilot = false
                        airutils.transfer_control(ent, true)
                    end
                end
                ent._instruction_mode = false
                pa28.dettachPlayer(ent, player)
		    end
		    if fields.copilot then
                --look for a free seat first
                local is_there_a_free_seat = false
                for i = 2,1,-1 
                do 
                    if ent._passengers[i] == nil then
                        is_there_a_free_seat = true
                        break
                    end
                end
                --then move the current copilot to a free seat
                if ent._passenger and is_there_a_free_seat then
                    local copilot_player_obj = minetest.get_player_by_name(ent._passenger)
                    if copilot_player_obj then
                        pa28.dettach_pax(ent, copilot_player_obj)
                        pa28.attach_pax(ent, copilot_player_obj)
                    else
                        ent._passenger = nil
                    end
                end
                --so bring the new copilot
                if ent._passenger == nil then
                    local new_copilot_player_obj = minetest.get_player_by_name(fields.copilot)
                    if new_copilot_player_obj then
                        pa28.dettach_pax(ent, new_copilot_player_obj)
                        pa28.attach_pax(ent, new_copilot_player_obj, true)
                    end
                end
		    end
            if fields.yaw then
                if ent._yaw_by_mouse == true then
                    ent._yaw_by_mouse = false
                else
                    ent._yaw_by_mouse = true
                end
            end
        end
        minetest.close_formspec(name, "pa28:pilot_main")
    end
end)
