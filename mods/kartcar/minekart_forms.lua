
--------------
-- Manual --
--------------

function minekart.getCarFromPlayer(player)
    local seat = player:get_attach()
    if seat then
        --local car = seat:get_attach()
        return seat
    end
    return nil
end

function minekart.driver_formspec(name)
    local player = minetest.get_player_by_name(name)
    local vehicle_obj = minekart.getCarFromPlayer(player)
    if vehicle_obj == nil then
        return
    end
    local ent = vehicle_obj:get_luaentity()

    local basic_form = table.concat({
        "formspec_version[3]",
        "size[6,6]",
	}, "")

    local yaw = "false"
    if ent._yaw_by_mouse then yaw = "true" end

	basic_form = basic_form.."button[1,1.0;4,1;go_out;Go Offboard]"
    basic_form = basic_form.."checkbox[1,3.0;yaw;Direction by mouse;"..yaw.."]"

    minetest.show_formspec(name, "minekart:driver_main", basic_form)
end

minetest.register_on_player_receive_fields(function(player, formname, fields)
	if formname == "minekart:driver_main" then
        local name = player:get_player_name()
        local car_obj = minekart.getCarFromPlayer(player)
        if car_obj then
            local ent = car_obj:get_luaentity()
            if ent then
		        if fields.go_out then
                    ent._engine_running = false
			        -- driver clicked the object => driver gets off the vehicle
			        ent.driver_name = nil
			        -- sound and animation
                    if ent.sound_handle then
                        minetest.sound_stop(ent.sound_handle)
                        ent.sound_handle = nil
                    end
			        
			        ent.object:set_animation_frame_speed(0)

                    -- detach the player
		            player:set_detach()
                    player:set_eye_offset({x=0,y=0,z=0},{x=0,y=0,z=0})
                    if minetest.global_exists("player_api") then
                        player_api.player_attached[name] = nil
                        player_api.set_animation(player, "stand")
                    end
		            ent.driver = nil
                    ent.object:set_acceleration(vector.multiply(minekart.vector_up, -minekart.gravity))

		        end
                if fields.yaw then
                    if ent._yaw_by_mouse == true then
                        ent._yaw_by_mouse = false
                    else
                        ent._yaw_by_mouse = true
                    end
                end
            end
        end
        minetest.close_formspec(name, "minekart:driver_main")
    end
end)
