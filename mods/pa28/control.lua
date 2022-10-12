--global constants
pa28.vector_up = vector.new(0, 1, 0)
pa28.ideal_step = 0.02
pa28.rudder_limit = 30
pa28.elevator_limit = 40

dofile(minetest.get_modpath("pa28") .. DIR_DELIM .. "utilities.lua")

function pa28.powerAdjust(self,dtime,factor,dir,max_power)
    local max = max_power or 100
    local add_factor = factor/2
    add_factor = add_factor * (dtime/pa28.ideal_step) --adjusting the command speed by dtime
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
end

function pa28.control(self, dtime, hull_direction, longit_speed, longit_drag,
                            later_speed, later_drag, accel, player, is_flying)
    --if self.driver_name == nil then return end
    local retval_accel = accel

    local stop = false
    local ctrl = nil

	-- player control
	if player then
		ctrl = player:get_player_control()

        --engine and power control
        --[[if ctrl.aux1 and self._last_time_command > 0.5 then
            self._last_time_command = 0
		    if self._engine_running then
			    self._engine_running = false
                self._autopilot = false
                self._power_lever = 0 --zero power
                self._last_applied_power = 0 --zero engine
		    elseif self._engine_running == false and self._energy > 0 then
			    self._engine_running = true
                self._last_applied_power = -1 --send signal to start
		    end
        end]]--

        self._acceleration = 0
        if self._engine_running then
            --engine acceleration calc
            local engineacc = (self._power_lever * pa28.max_engine_acc) / 100;

            local factor = 1

            --increase power lever
            if ctrl.jump then
                pa28.powerAdjust(self, dtime, factor, 1)
            end
            --decrease power lever
            if ctrl.sneak then
                pa28.powerAdjust(self, dtime, factor, -1)
                if self._power_lever <= 0 and is_flying == false then
                    --break
                    if longit_speed > 0 then
                        engineacc = -1
                        if (longit_speed + engineacc) < 0 then
                            engineacc = longit_speed * -1
                        end
                    end
                    if longit_speed < 0 then
                        engineacc = 1
                        if (longit_speed + engineacc) > 0 then
                            engineacc = longit_speed * -1
                        end
                    end
                    if abs(longit_speed) == 0 then
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
        if ctrl.up then pitch_cmd = 1 elseif ctrl.down then pitch_cmd = -1 end
        pa28.set_pitch(self, pitch_cmd, dtime)

		-- yaw
        local yaw_cmd = 0
        if self._yaw_by_mouse == true then
	        local rot_y = math.deg(player:get_look_horizontal())
            pa28.set_yaw_by_mouse(self, rot_y)
        else
            if ctrl.right then yaw_cmd = 1 elseif ctrl.left then yaw_cmd = -1 end
            pa28.set_yaw(self, yaw_cmd, dtime)
        end

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
            pa28.flap_operate(self, player)
        end
	end

    if longit_speed > 0 then
        if ctrl then
            if ctrl.right or ctrl.left then
            else
                pa28.rudder_auto_correction(self, longit_speed, dtime)
            end
        else
            pa28.rudder_auto_correction(self, longit_speed, dtime)
        end
        if airutils.elevator_auto_correction then
            self._elevator_angle = airutils.elevator_auto_correction(self, longit_speed, self.dtime, pa28.max_speed, self._elevator_angle, pa28.elevator_limit, pa28.ideal_step, 5000)
        end
    end

    return retval_accel, stop
end

function pa28.set_pitch(self, dir, dtime)
    local pitch_factor = 1
    local time_factor = dtime
	if dir == -1 then
        --minetest.chat_send_all("cabrando")
        if self._angle_of_attack > 0 then pitch_factor = pitch_factor * 2 end
		self._elevator_angle = math.max(self._elevator_angle-pitch_factor*time_factor,-pa28.elevator_limit)
	elseif dir == 1 then
        --minetest.chat_send_all("picando")
        if self._angle_of_attack < 2 then pitch_factor = 0.2 end --lets reduce the command power to avoid accidents
        --minetest.chat_send_all("picando: "..pitch_factor)
		self._elevator_angle = math.min(self._elevator_angle+pitch_factor*time_factor,pa28.elevator_limit)
	end
end

function pa28.set_yaw(self, dir, dtime)
    local yaw_factor = 20
	if dir == 1 then
		self._rudder_angle = math.max(self._rudder_angle-(yaw_factor*dtime),-pa28.rudder_limit)
	elseif dir == -1 then
		self._rudder_angle = math.min(self._rudder_angle+(yaw_factor*dtime),pa28.rudder_limit)
	end
end

function pa28.set_yaw_by_mouse(self, dir)
    local rotation = self.object:get_rotation()
    local rot_y = math.deg(rotation.y)
    
    local total = math.abs(math.floor(rot_y/360))

    if rot_y < 0 then rot_y = rot_y + (360*total) end
    if rot_y > 360 then rot_y = rot_y - (360*total) end
    rot_y = math.fmod(rot_y, 360)
    if rot_y >= 270 and dir <= 90 then dir = dir + 360 end
    if rot_y <= 90 and dir >= 270 then dir = dir - 360 end

    local command = rot_y - dir
    command = math.max(-90,  math.min(command, 90))
    --minetest.chat_send_all("rotation y: "..rot_y.." - dir: "..dir.." - command: "..(rot_y - dir))

    --minetest.chat_send_all("rotation y: "..rot_y.." - dir: "..dir.." - command: "..command)

	self._rudder_angle = (-command * pa28.rudder_limit)/90
end

function pa28.rudder_auto_correction(self, longit_speed, dtime)
    local factor = 1
    if self._rudder_angle > 0 then factor = -1 end
    local correction = (pa28.rudder_limit*(longit_speed/1000)) * factor * (dtime/pa28.ideal_step)
    local before_correction = self._rudder_angle
    local new_rudder_angle = self._rudder_angle + correction
    if math.sign(before_correction) ~= math.sign(new_rudder_angle) then
        self._rudder_angle = 0
    else
        self._rudder_angle = new_rudder_angle
    end
end

function pa28.autopilot(self, dtime, hull_direction, longit_speed, accel, curr_pos)

    local retval_accel = accel

    local max_autopilot_power = 85
    local max_attack_angle = 1.8

    --climb
    local velocity = self.object:get_velocity()
    local climb_rate = velocity.y * 1.5
    if climb_rate > 5 then climb_rate = 5 end
    if climb_rate < -5 then
        climb_rate = -5
    end

    self._acceleration = 0
    if self._engine_running then
        --engine acceleration calc
        local engineacc = (self._power_lever * pa28.max_engine_acc) / 100;
        --self.engine:set_animation_frame_speed(60 + self._power_lever)

        local factor = math.abs(climb_rate * 0.1)
        --increase power lever
        if climb_rate > 0.2 then
            pa28.powerAdjust(self, dtime, factor, -1)
        end
        --decrease power lever
        if climb_rate < 0 then
            pa28.powerAdjust(self, dtime, factor, 1, max_autopilot_power)
        end
        --do not exceed
        local max_speed = pa28.max_speed
        if longit_speed > max_speed then
            engineacc = engineacc - (longit_speed-max_speed)
            if engineacc < 0 then engineacc = 0 end
        end
        self._acceleration = engineacc
    end

    local hull_acc = vector.multiply(hull_direction,self._acceleration)
    retval_accel=vector.add(retval_accel,hull_acc)

    --pitch
    if self._angle_of_attack > max_attack_angle then
        pa28.set_pitch(self, 1, dtime)
    elseif self._angle_of_attack < max_attack_angle then
        pa28.set_pitch(self, -1, dtime)
    end

	-- yaw
    pa28.set_yaw(self, 0, dtime)

    if longit_speed > 0 then
        pa28.rudder_auto_correction(self, longit_speed, dtime)
        if airutils.elevator_auto_correction then
            self._elevator_angle = airutils.elevator_auto_correction(self, longit_speed, self.dtime, pa28.max_speed, self._elevator_angle, pa28.elevator_limit, pa28.ideal_step, 500)
        end
    end

    return retval_accel
end
