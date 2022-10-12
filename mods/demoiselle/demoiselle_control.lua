--global constants
demoiselle.vector_up = vector.new(0, 1, 0)
demoiselle.ideal_step = 0.02
demoiselle.rudder_limit = 30
demoiselle.elevator_limit = 40

dofile(minetest.get_modpath("demoiselle") .. DIR_DELIM .. "demoiselle_utilities.lua")

function demoiselle.powerAdjust(self,dtime,factor,dir,max_power)
    local max = max_power or 100
    local add_factor = factor
    add_factor = add_factor * (dtime/demoiselle.ideal_step) --adjusting the command speed by dtime
    local power_index = self._power_lever

    if dir == 1 then
        if self._power_lever < max then
            self._power_lever = self._power_lever + add_factor
        end
        if self._power_lever > max then
            self._power_lever = max
        end
    end
    if dir == -1 then
        if self._power_lever > 0 then
            self._power_lever = self._power_lever - add_factor
            if self._power_lever < 0 then self._power_lever = 0 end
        end
        if self._power_lever <= 0 then
            self._power_lever = 0
        end
    end
    if power_index ~= self._power_lever then
        demoiselle.engineSoundPlay(self)
    end

end

function demoiselle.control(self, dtime, hull_direction, longit_speed, longit_drag,
                            later_speed, later_drag, accel, player, is_flying)
    if self._last_time_command > 1 then self._last_time_command = 1 end
    --if self.driver_name == nil then return end
    local retval_accel = accel

    local stop = false
    local ctrl = nil

	-- player control
	if player then
		ctrl = player:get_player_control()

        --engine and power control
        if ctrl.aux1 and self._last_time_command > 0.5 then
            self._last_time_command = 0
		    if self._engine_running then
			    self._engine_running = false
		        -- sound and animation
                if self.sound_handle then
                    minetest.sound_stop(self.sound_handle)
                    self.sound_handle = nil
                end
		        self.engine:set_animation_frame_speed(0)
                self._power_lever = 0 --zero power
		    elseif self._engine_running == false and self._energy > 0 then
			    self._engine_running = true
	            -- sound and animation
                demoiselle.engineSoundPlay(self)
                self.engine:set_animation_frame_speed(60)
		    end
        end

        self._acceleration = 0
        if self._engine_running then
            --engine acceleration calc
            local engineacc = (self._power_lever * demoiselle.max_engine_acc) / 100;
            self.engine:set_animation_frame_speed(60 + self._power_lever)

            local factor = 1

            --increase power lever
            if ctrl.jump then
                demoiselle.powerAdjust(self, dtime, factor, 1)
            end
            --decrease power lever
            if ctrl.sneak then
                demoiselle.powerAdjust(self, dtime, factor, -1)
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
	        local paddleacc = 0
	        if longit_speed < 1.0 then
                if ctrl.jump then paddleacc = 0.5 end
            end
	        if longit_speed > -1.0 then
                if ctrl.sneak then paddleacc = -0.5 end
	        end
	        self._acceleration = paddleacc
        end

        local hull_acc = vector.multiply(hull_direction,self._acceleration)
        retval_accel=vector.add(retval_accel,hull_acc)

        --pitch
        local pitch_cmd = 0
        if self._pitch_by_mouse == true then
		    local rot_x = math.deg(player:get_look_vertical())
            demoiselle.set_pitch_by_mouse(self, rot_x)
        else
            if ctrl.up then pitch_cmd = 1 elseif ctrl.down then pitch_cmd = -1 end
            demoiselle.set_pitch(self, pitch_cmd, dtime)
        end

		-- yaw
        local yaw_cmd = 0
        if self._yaw_by_mouse == true then
		    local rot_y = math.deg(player:get_look_horizontal())
            demoiselle.set_yaw_by_mouse(self, rot_y)
        else
            if ctrl.right then yaw_cmd = 1 elseif ctrl.left then yaw_cmd = -1 end
            demoiselle.set_yaw(self, yaw_cmd, dtime)
        end

        --I'm desperate, center all!
        if ctrl.right and ctrl.left then
            self._elevator_angle = 0
            self._rudder_angle = 0
        end
	end

    if longit_speed > 0 then
        if ctrl then
            if ctrl.right or ctrl.left then
            else
                demoiselle.rudder_auto_correction(self, longit_speed, dtime)
            end
        else
            demoiselle.rudder_auto_correction(self, longit_speed, dtime)
        end
        if airutils.elevator_auto_correction then
            self._elevator_angle = airutils.elevator_auto_correction(self, longit_speed, self.dtime, demoiselle.max_speed, self._elevator_angle, demoiselle.elevator_limit, demoiselle.ideal_step, 30)
        end
    end

    return retval_accel, stop
end

function demoiselle.set_pitch(self, dir, dtime)
    local pitch_factor = 15
	if dir == -1 then
		self._elevator_angle = math.max(self._elevator_angle-pitch_factor*dtime,-demoiselle.elevator_limit)
	elseif dir == 1 then
        if self._angle_of_attack < 0 then pitch_factor = 2 end --lets reduce the command power to avoid accidents
		self._elevator_angle = math.min(self._elevator_angle+pitch_factor*dtime,demoiselle.elevator_limit)
	end
end

function demoiselle.set_pitch_by_mouse(self, dir)
	self._elevator_angle = -(dir * demoiselle.elevator_limit)/270
end

function demoiselle.set_yaw(self, dir, dtime)
    local yaw_factor = 25
	if dir == 1 then
		self._rudder_angle = math.max(self._rudder_angle-yaw_factor*dtime,-demoiselle.rudder_limit)
	elseif dir == -1 then
		self._rudder_angle = math.min(self._rudder_angle+yaw_factor*dtime,demoiselle.rudder_limit)
	end
end

function demoiselle.set_yaw_by_mouse(self, dir)
    local rotation = self.object:get_rotation()
    local rot_y = math.deg(rotation.y)
    
    local total = math.abs(math.floor(rot_y/360))

    if rot_y < 0 then rot_y = rot_y + (360*total) end
    if rot_y > 360 then rot_y = rot_y - (360*total) end

    local command = rot_y - dir
    if command < -180 then command = command + 360 
    elseif command > 180 then command = command - 360 end
    --minetest.chat_send_all("rotation y: "..rot_y.." - dir: "..dir.." - command: "..command)
    
    if command > 80 then command = 80 end
    if command < -80 then command = -80 end

    --minetest.chat_send_all("rotation y: "..rot_y.." - dir: "..dir.." - command: "..command)

	self._rudder_angle = (-command * demoiselle.rudder_limit)/90
end

function demoiselle.rudder_auto_correction(self, longit_speed, dtime)
    local factor = 1
    if self._rudder_angle > 0 then factor = -1 end
    local correction = (demoiselle.rudder_limit*(longit_speed/2000)) * factor * (dtime/demoiselle.ideal_step)
    local before_correction = self._rudder_angle
    local new_rudder_angle = self._rudder_angle + correction
    if math.sign(before_correction) ~= math.sign(new_rudder_angle) then
        self._rudder_angle = 0
    else
        self._rudder_angle = new_rudder_angle
    end
end

function demoiselle.engineSoundPlay(self)
    --sound
    if self.sound_handle then minetest.sound_stop(self.sound_handle) end
    self.sound_handle = minetest.sound_play({name = "demoiselle_engine"},
        {object = self.object, gain = 2.0,
            pitch = 0.5 + ((self._power_lever/100)/2),max_hear_distance = 32,
            loop = true,})
end

function getAdjustFactor(curr_y, desired_y)
    local max_difference = 0.1
    local adjust_factor = 0.5
    local difference = math.abs(curr_y - desired_y)
    if difference > max_difference then difference = max_difference end
    return (difference * adjust_factor) / max_difference
end


