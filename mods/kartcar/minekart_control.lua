--global constants

minekart.karttest_last_time_command = 0
minekart.vector_up = vector.new(0, 1, 0)
minekart.max_acc_factor = 8
minekart.max_speed = 25

function minekart.check_road_is_ok(obj)
	local pos_below = obj:get_pos()
	pos_below.y = pos_below.y - 0.1
	local node_below = minetest.get_node(pos_below).name
    --minetest.chat_send_all(node_below)
    local nodedef = minetest.registered_nodes[node_below]
    if nodedef.liquidtype == "none" then
        local slow_nodes = {['default:dirt'] = 0.3,
                            ['default:dirt_with_rainforest_litter'] = 0.3,
                            ['default:dirt_with_coniferous_litter'] = 0.3,
                            ['default:permafrost'] = 0.3,
                            ['default:permafrost_with_moss'] = 0.3,
                            ['default:permafrost_with_stones'] = 0.3,
                            ['default:dirt_with_grass'] = 0.2,
                            ['farming:soil'] = 0.2,
                            ['farming:soil_wet'] = 0.2,
                            ['farming:desert_sand_soil'] = 0.2,
                            ['farming:desert_sand_soil_wet'] = 0.2,
                            ['farming:dry_soil'] = 0.2,
                            ['farming:dry_soil_wet'] = 0.2,
                            ['default:sand'] = 0.1,
                            ['default:desert_sand'] = 0.1,
                            ['default:silver_sand'] = 0.1,
                            ['default:snow'] = 0.07,
                            ['default:dirt_with_snow'] = 0.07,
                            ['default:ice '] = 0.01,
                            ['default:cave_ice'] = 0.01,
                           }
        local acc = slow_nodes[node_below]
        if acc == nil then acc = minekart.max_acc_factor end
        return acc
    else
        return 0
    end
end

function minekart.set_yaw_by_mouse(self, dir, steering_limit)
    local rotation = self.object:get_rotation()
    local rot_y = math.deg(rotation.y)
    
    local total = math.abs(math.floor(rot_y/360))

    if rot_y < 0 then rot_y = rot_y + (360*total) end
    if rot_y > 360 then rot_y = rot_y - (360*total) end
    if rot_y >= 270 and dir <= 90 then dir = dir + 360 end
    if rot_y <= 90 and dir >= 270 then dir = dir - 360 end

    local intensity = 2
    if self._intensity then intensity = self._intensity end
    local command = (rot_y - dir) * intensity
    if command < -90 then command = -90 
    elseif command > 90 then command = 90 end
    --minetest.chat_send_all("rotation y: "..rot_y.." - dir: "..dir.." - command: "..(rot_y - dir))

    --minetest.chat_send_all("rotation y: "..rot_y.." - dir: "..dir.." - command: "..command)

	return (-command * steering_limit)/90
end

function minekart.kart_control(self, dtime, hull_direction, longit_speed, longit_drag, later_drag, accel)
    minekart.karttest_last_time_command = minekart.karttest_last_time_command + dtime
    if minekart.karttest_last_time_command > 1 then minekart.karttest_last_time_command = 1 end

	local player = minetest.get_player_by_name(self.driver_name)
    local retval_accel = accel;
    
	-- player control
	if player then
		local ctrl = player:get_player_control()
		
        local acc = 0
        if self._engine_running then
            --running
	        if longit_speed < minekart.max_speed and ctrl.up then
                --get acceleration factor
                acc = minekart.check_road_is_ok(self.object)
                --minetest.chat_send_all('engineacc: '.. engineacc)
                if acc > 1 and acc < minekart.max_acc_factor and longit_speed > 0 then
                    --improper road will reduce speed
                    acc = -1
                end
	        end
        else
            --slow maneuver
	        if longit_speed < 1.0 and ctrl.up then
                --get acceleration factor
                acc = minekart.check_road_is_ok(self.object)
                --minetest.chat_send_all('engineacc: '.. engineacc)
                if acc > 1 and acc < minekart.max_acc_factor and longit_speed > 0 then
                    --improper road will reduce speed
                    acc = -1
                end
	        end
        end

        --reversing
	    if ctrl.sneak and longit_speed <= 1.0 and longit_speed > -1.0 then
            acc = -1
	    end

        --break
        --break
        if ctrl.down then
            --[[if math.abs(longit_speed) > 0 then
                acc = -5 / (longit_speed / 2) -- lets set a brake efficience based on speed
            end]]--
        
            --total stop
            --wheel break
            if longit_speed > 0 then
                acc = -5
                if (longit_speed + acc) < 0 then
                    acc = longit_speed * -1
                end
            end
            if longit_speed < 0 then
                acc = 5
                if (longit_speed + acc) > 0 then
                    acc = longit_speed * -1
                end
            end
            if math.abs(longit_speed) <= 0.5 then
                -- do not like it here, but worked better
                acc = 0
                --self.object:set_acceleration(zero)
                self.object:set_velocity(vector.new())
            end
        end

        if acc then retval_accel=vector.add(accel,vector.multiply(hull_direction,acc)) end

		if ctrl.aux1 then
            --sets the engine running - but sets a delay also, cause keypress
            if minekart.karttest_last_time_command > 0.3 then
                minekart.karttest_last_time_command = 0
			    if self._engine_running then
				    self._engine_running = false
			        -- sound and animation
                    if self.sound_handle then
                        minetest.sound_stop(self.sound_handle)
                        self.sound_handle = nil
                    end
			        --self.engine:set_animation_frame_speed(0)

			    elseif self._engine_running == false and self._energy > 0 then
				    self._engine_running = true
		            -- sound and animation
	                self.sound_handle = minetest.sound_play({name = "engine"},
			                {object = self.object, gain = 2.0, pitch = 1.0, max_hear_distance = 32, loop = true,})
                    --self.engine:set_animation_frame_speed(30)
			    end
            end
		end

        local steering_limit = 30
        local yaw_cmd = 0
        if self._yaw_by_mouse == true then
		    local rot_y = math.deg(player:get_look_horizontal())
            self._steering_angle = minekart.set_yaw_by_mouse(self, rot_y, steering_limit)
        else
		    -- steering
		    if ctrl.right then
			    self._steering_angle = math.max(self._steering_angle-80*dtime,-steering_limit)
		    elseif ctrl.left then
			    self._steering_angle = math.min(self._steering_angle+80*dtime,steering_limit)
            else
                --center steering
                if longit_speed > 0 then
                    local factor = 1
                    if self._steering_angle > 0 then factor = -1 end
                    local correction = (steering_limit*(longit_speed/100)) * factor
                    local before_correction = self._steering_angle
                    self._steering_angle = self._steering_angle + correction
                    if math.sign(before_correction) ~= math.sign(self._steering_angle) then self._steering_angle = 0 end
                end
		    end
        end

        local angle_factor = self._steering_angle / 60
        if angle_factor < 0 then angle_factor = angle_factor * -1 end
        local deacc_on_curve = longit_speed * angle_factor
        deacc_on_curve = deacc_on_curve * -1
        if deacc_on_curve then retval_accel=vector.add(retval_accel,vector.multiply(hull_direction,deacc_on_curve)) end

	end

    return retval_accel
end


