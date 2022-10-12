--global constants
ju52.vector_up = vector.new(0, 1, 0)
ju52.ideal_step = 0.02
ju52.rudder_limit = 25
ju52.elevator_limit = 40

dofile(minetest.get_modpath("ju52") .. DIR_DELIM .. "ju52_utilities.lua")

function ju52.powerAdjust(self,dtime,factor,dir,max_power)
    local max = max_power or 100
    local add_factor = factor
    add_factor = add_factor * (dtime/ju52.ideal_step) --adjusting the command speed by dtime
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
        ju52.engineSoundPlay(self)
    end

end

function ju52.control(self, dtime, hull_direction, longit_speed, longit_drag,
                            later_speed, later_drag, accel, player, is_flying)
    if self._last_time_command > 2 then self._last_time_command = 2 end
    --if self.driver_name == nil then return end
    local retval_accel = accel

    local stop = false
    local ctrl = nil

	-- player control
	if player then
		ctrl = player:get_player_control()

        if ctrl.aux1 and self._last_time_command > 0.5 then
            self._last_time_command = 0
        end

        --engine and power control
        self._acceleration = 0
        if self._engine_running then
            --engine acceleration calc
            local engineacc = (self._power_lever * ju52.max_engine_acc) / 100;
            self.engine:set_animation_frame_speed(60 + self._power_lever)

            local factor = 1

            --increase power lever
            if ctrl.jump then
                ju52.powerAdjust(self, dtime, factor, 1)
            end
            --decrease power lever
            if ctrl.sneak then
                ju52.powerAdjust(self, dtime, factor, -1)
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

        local hull_acc = vector.multiply(hull_direction, self._acceleration)
        retval_accel= vector.add(retval_accel,hull_acc)
        --minetest.chat_send_all("x=" .. retval_accel.x .. " - y=" .. retval_accel.y .. " - z=" .. retval_accel.z)
        --minetest.chat_send_all(self._acceleration)

        --pitch
        local pitch_cmd = 0
        if ctrl.up then pitch_cmd = 1 elseif ctrl.down then pitch_cmd = -1 end
        ju52.set_pitch(self, pitch_cmd, dtime)

		-- yaw
        local yaw_cmd = 0
        if ctrl.right then yaw_cmd = 1 elseif ctrl.left then yaw_cmd = -1 end
        ju52.set_yaw(self, yaw_cmd, dtime)

        --I'm desperate, center all!
        if ctrl.right and ctrl.left then
            self._elevator_angle = 0
            self._rudder_angle = 0
        end

        ----------------------------------
        -- flap operation
        ----------------------------------
        if ctrl.aux1 and ctrl.sneak and self._last_time_command >= 0.3 then
            self._last_time_command = 0
            ju52.flap_operate(self, player)
        end

	end

    if longit_speed > 0 then
        if ctrl then
            if ctrl.right or ctrl.left then
            else
                ju52.rudder_auto_correction(self, longit_speed, dtime)
            end
        else
            ju52.rudder_auto_correction(self, longit_speed, dtime)
        end
        self._elevator_angle = airutils.elevator_auto_correction(self, longit_speed, self.dtime, ju52.max_speed, self._elevator_angle, ju52.elevator_limit, ju52.ideal_step, 100)
    end

    return retval_accel, stop
end

function ju52.set_pitch(self, dir, dtime)
    local pitch_factor = 7
	if dir == -1 then
		self._elevator_angle = math.max(self._elevator_angle-(pitch_factor*dtime),-ju52.elevator_limit)
	elseif dir == 1 then
        if self._angle_of_attack < 0 then pitch_factor = 1 end --lets reduce the command power to avoid accidents
		self._elevator_angle = math.min(self._elevator_angle+(pitch_factor*dtime),ju52.elevator_limit)
	end
end

function ju52.set_yaw(self, dir, dtime)
    local turn_factor = 1 --normal turn
    local correction_factor = 2 --index used when the turn is currently in opposite of desired direction

    local yaw_factor = 7
	if dir == 1 then
        if self._rudder_angle > 0 then turn_factor = correction_factor end
		self._rudder_angle = math.max(self._rudder_angle-(yaw_factor*dtime*turn_factor),-ju52.rudder_limit)
	elseif dir == -1 then
        if self._rudder_angle < 0 then turn_factor = correction_factor end
		self._rudder_angle = math.min(self._rudder_angle+(yaw_factor*dtime*turn_factor),ju52.rudder_limit)
	end
end

function ju52.rudder_auto_correction(self, longit_speed, dtime)
    local factor = 1
    if self._rudder_angle > 0 then factor = -1 end
    local correction = (ju52.rudder_limit*(longit_speed/8000)) * factor * (dtime/ju52.ideal_step)
    local before_correction = self._rudder_angle
    local new_rudder_angle = self._rudder_angle + correction
    if math.sign(before_correction) ~= math.sign(new_rudder_angle) then
        self._rudder_angle = 0
    else
        self._rudder_angle = new_rudder_angle
    end
end

function ju52.engineSoundPlay(self)
    --sound
    if self.sound_handle then minetest.sound_stop(self.sound_handle) end
    self.sound_handle = minetest.sound_play({name = "ju52_engine"},
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


