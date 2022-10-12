--global constants
trike.trike_last_time_command = 0
trike.vector_up = vector.new(0, 1, 0)
trike.max_engine_acc = 4.5
trike.ideal_step = 0.02

dofile(minetest.get_modpath("trike") .. DIR_DELIM .. "trike_utilities.lua")

function trike.check_node_below(obj)
	local pos_below = obj:get_pos()
	pos_below.y = pos_below.y - 0.1
	local node_below = minetest.get_node(pos_below).name
	local nodedef = minetest.registered_nodes[node_below]
	local touching_ground = not nodedef or -- unknown nodes are solid
			nodedef.walkable or false
	local liquid_below = not touching_ground and nodedef.liquidtype ~= "none"
	return touching_ground, liquid_below
end

function trike.control(self, dtime, hull_direction, longit_speed,
            longit_drag, later_speed, later_drag, accel, player, is_flying)

    trike.trike_last_time_command = trike.trike_last_time_command + self.dtime
    if trike.trike_last_time_command > 1 then trike.trike_last_time_command = 1 end
    if self.driver_name == nil then return end
    local retval_accel = accel

    local rudder_limit = 30
    local stop = false

	-- player control
	if player then
		local ctrl = player:get_player_control()

        --engine and power control
        if ctrl.aux1 and trike.trike_last_time_command > 0.3 then
            trike.trike_last_time_command = 0
		    if self._engine_running then
			    self._engine_running = false
		        -- sound and animation
                if self.sound_handle then
                    minetest.sound_stop(self.sound_handle)
                    self.sound_handle = nil
                end
		        self.engine:set_animation_frame_speed(0)
		    elseif self._engine_running == false and self._energy > 0 then
			    self._engine_running = true
	            -- sound and animation
                self.sound_handle = minetest.sound_play({name = "trike_engine"},
	                {object = self.object, gain = 2.0,
                        pitch = 0.5 + ((self._power_lever/100)/2),max_hear_distance = 32,
                        loop = true,})
                self.engine:set_animation_frame_speed(60)
		    end
        end

        self._acceleration = 0
        if self._engine_running then
            --engine acceleration calc
            local engineacc = (self._power_lever * trike.max_engine_acc) / 100;
            self.engine:set_animation_frame_speed(60 + self._power_lever)

            local add_factor = 1
            add_factor = add_factor * (dtime/trike.ideal_step) --adjusting the command speed by dtime

            --increase power lever
            if ctrl.jump then
                if self._power_lever < 100 then
                    self._power_lever = self._power_lever + add_factor
                end
                if self._power_lever > 100 then
                    self._power_lever = 100
                    engineacc = trike.max_engine_acc
                else
                    --sound
                    if self.sound_handle then
                        minetest.sound_stop(self.sound_handle)
                        self.sound_handle = minetest.sound_play({name = "trike_engine"},
	                        {object = self.object, gain = 2.0,
                                pitch = 0.5 + ((self._power_lever/100)/2),max_hear_distance = 32,
                                loop = true,})
                    end
                end
            end
            --decrease power lever
            if ctrl.sneak then
                if self._power_lever > 0 then
                    self._power_lever = self._power_lever - add_factor
                    if self._power_lever < 0 then self._power_lever = 0 end
                end
                if self._power_lever <= 0 and is_flying == false then
                    --break
                    if longit_speed > 0 then
                        engineacc = -1
                        if (longit_speed + engineacc) < 0 then engineacc = longit_speed * -1 end
                    end
                    if longit_speed < 0 then
                        engineacc = 1
                        if (longit_speed + engineacc) > 0 then engineacc = longit_speed * -1 end
                    end
                    if abs(longit_speed) < 0.1 then
                        stop = true
                    end
                else
                    --sound
                    minetest.sound_stop(self.sound_handle)
                    self.sound_handle = minetest.sound_play({name = "trike_engine"},
		                {object = self.object, gain = 2.0,
                            pitch = 0.5 + ((self._power_lever/100)/2),
                            max_hear_distance = 32, loop = true,})
                end
            end
            --do not exceed
            local max_speed = 6
            if longit_speed > max_speed then
                engineacc = engineacc - (longit_speed-max_speed)
                if engineacc < 0 then engineacc = 0 end
            end
            self._acceleration = engineacc
        else
	        local pushacc = 0
	        if longit_speed < 1.0 then
                if ctrl.jump then pushacc = 0.5 end
            end
	        if longit_speed > -1.0 then
                if ctrl.sneak then pushacc = -0.5 end
	        end
	        self._acceleration = pushacc
        end

        local hull_acc = vector.multiply(hull_direction,self._acceleration)
        retval_accel=vector.add(retval_accel,hull_acc)

        --wing
        local wing_limit = 10
		if ctrl.down then
			self._angle_of_attack = math.max(self._angle_of_attack-10*self.dtime,2)
		elseif ctrl.up then
			self._angle_of_attack = math.min(self._angle_of_attack+10*self.dtime,wing_limit)
		end

		-- yaw
		if ctrl.right then
			self._rudder_angle = math.max(self._rudder_angle-30*self.dtime,-rudder_limit)
		elseif ctrl.left then
			self._rudder_angle = math.min(self._rudder_angle+30*self.dtime,rudder_limit)
		end
	end

    if longit_speed > 0 then
        local factor = 1
        if self._rudder_angle > 0 then factor = -1 end
        local correction = (rudder_limit*(longit_speed/1000)) * factor
        self._rudder_angle = self._rudder_angle + correction
    end

    return retval_accel, stop
end


