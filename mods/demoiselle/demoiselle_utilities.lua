dofile(minetest.get_modpath("demoiselle") .. DIR_DELIM .. "demoiselle_global_definitions.lua")
dofile(minetest.get_modpath("demoiselle") .. DIR_DELIM .. "demoiselle_hud.lua")

function demoiselle.get_hipotenuse_value(point1, point2)
    return math.sqrt((point1.x - point2.x) ^ 2 + (point1.y - point2.y) ^ 2 + (point1.z - point2.z) ^ 2)
end

function demoiselle.dot(v1,v2)
	return v1.x*v2.x+v1.y*v2.y+v1.z*v2.z
end

function demoiselle.sign(n)
	return n>=0 and 1 or -1
end

function demoiselle.minmax(v,m)
	return math.min(math.abs(v),m)*demoiselle.sign(v)
end

function demoiselle.get_gauge_angle(value, initial_angle)
    initial_angle = initial_angle or 90
    local angle = value * 18
    angle = angle - initial_angle
    angle = angle * -1
	return angle
end

-- attach player
function demoiselle.attach(self, player)
    local name = player:get_player_name()
    self.driver_name = name

    -- attach the driver
    player:set_attach(self.pilot_seat_base, "", {x = 0, y = 0, z = 0}, {x = 0, y = 0, z = 0})
    if airutils.detect_player_api(player) == 0 then
        player:set_eye_offset({x = 0, y = -4, z = 2}, {x = 0, y = 1, z = -30})
    else
        player:set_eye_offset({x = 0, y = 2, z = 2}, {x = 0, y = 1, z = -30})
    end
    player_api.player_attached[name] = true
    player_api.set_animation(player, "sit")
    -- make the driver sit
    minetest.after(1, function()
        player = minetest.get_player_by_name(name)
        if player then
            airutils.sit(player)
        end
    end)
end

function demoiselle.dettachPlayer(self, player)
    local name = self.driver_name
    airutils.setText(self, "Demoiselle")

    demoiselle.remove_hud(player)

    --self._engine_running = false

    -- driver clicked the object => driver gets off the vehicle
    self.driver_name = nil

    if self._engine_running then
	    self._engine_running = false
        self.engine:set_animation_frame_speed(0)
    end
    -- sound and animation
    if self.sound_handle then
        minetest.sound_stop(self.sound_handle)
        self.sound_handle = nil
    end

    -- detach the player
    player:set_detach()
    player_api.player_attached[name] = nil
    player:set_eye_offset({x=0,y=0,z=0},{x=0,y=0,z=0})
    player_api.set_animation(player, "stand")
    self.driver = nil
    --remove_physics_override(player, {speed=1,gravity=1,jump=1})
end

function demoiselle.checkAttach(self, player)
    if player then
        local player_attach = player:get_attach()
        if player_attach then
            if player_attach == self.pilot_seat_base or player_attach == self.passenger_seat_base then
                return true
            end
        end
    end
    return false
end

-- destroy the boat
function demoiselle.destroy(self)
    if self._engine_running then
	    self._engine_running = false
        self.engine:set_animation_frame_speed(0)
    end
    -- sound and animation
    if self.sound_handle then
        minetest.sound_stop(self.sound_handle)
        self.sound_handle = nil
    end

    if self.driver_name then
        -- detach the driver
        local player = minetest.get_player_by_name(self.driver_name)
        demoiselle.dettachPlayer(self, player)
    end

    local pos = self.object:get_pos()
    if self.engine then self.engine:remove() end
    if self.pilot_seat_base then self.pilot_seat_base:remove() end
    if self.stick then self.stick:remove() end

    self.object:remove()

    pos.y=pos.y+2
    minetest.add_item({x=pos.x+math.random()-0.5,y=pos.y,z=pos.z+math.random()-0.5},'demoiselle:wings')

    for i=1,6 do
	    minetest.add_item({x=pos.x+math.random()-0.5,y=pos.y,z=pos.z+math.random()-0.5},'default:steel_ingot')
    end

    for i=1,4 do
	    minetest.add_item({x=pos.x+math.random()-0.5,y=pos.y,z=pos.z+math.random()-0.5},'default:wood')
    end

    for i=1,6 do
	    minetest.add_item({x=pos.x+math.random()-0.5,y=pos.y,z=pos.z+math.random()-0.5},'default:mese_crystal')
    end

    --minetest.add_item({x=pos.x+math.random()-0.5,y=pos.y,z=pos.z+math.random()-0.5},'demoiselle:demoiselle')
end

function demoiselle.testImpact(self, velocity, position)
    local p = position --self.object:get_pos()
    local collision = false
    if self._last_vel == nil then return end
    --lets calculate the vertical speed, to avoid the bug on colliding on floor with hard lag
    if abs(velocity.y - self._last_vel.y) > 2 then
		local noded = airutils.nodeatpos(airutils.pos_shift(p,{y=-2.8}))
	    if (noded and noded.drawtype ~= 'airlike') then
		    collision = true
	    else
            self.object:set_velocity(self._last_vel)
            self.object:set_acceleration(self._last_accell)
        end
    end
    local impact = abs(demoiselle.get_hipotenuse_value(velocity, self._last_vel))
    --minetest.chat_send_all('impact: '.. impact .. ' - hp: ' .. self.hp_max)
    if impact > 2 then
        --minetest.chat_send_all('impact: '.. impact .. ' - hp: ' .. self.hp_max)
        if self.colinfo then
            collision = self.colinfo.collides
        end
    end

    if collision then
        --self.object:set_velocity({x=0,y=0,z=0})
        local damage = impact / 2
        self.hp_max = self.hp_max - damage --subtract the impact value directly to hp meter
        minetest.sound_play("demoiselle_collision", {
            --to_player = self.driver_name,
            object = self.object,
            max_hear_distance = 15,
            gain = 1.0,
            fade = 0.0,
            pitch = 1.0,
        }, true)

        if self.driver_name then
            local player_name = self.driver_name
            airutils.setText(self, "Demoiselle")

            --minetest.chat_send_all('damage: '.. damage .. ' - hp: ' .. self.hp_max)
            if self.hp_max <= 0 then --if acumulated damage is greater than 50, adieu
                demoiselle.destroy(self)
            end

            local player = minetest.get_player_by_name(player_name)
            if player then
		        if player:get_hp() > 0 then
			        player:set_hp(player:get_hp()-(damage/2))
		        end
            end
            if self._passenger ~= nil then
                local passenger = minetest.get_player_by_name(self._passenger)
                if passenger then
		            if passenger:get_hp() > 0 then
			            passenger:set_hp(passenger:get_hp()-(damage/2))
		            end
                end
            end
        end

    end
end

function demoiselle.checkattachBug(self)
    -- for some engine error the player can be detached from the submarine, so lets set him attached again
    if self.owner and self.driver_name then
        -- attach the driver again
        local player = minetest.get_player_by_name(self.owner)
        if player then
		    if player:get_hp() > 0 then
                demoiselle.attach(self, player)
            else
                demoiselle.dettachPlayer(self, player)
		    end
        end
    end
end

function demoiselle.flightstep(self)
    local velocity = self.object:get_velocity()
    --hack to avoid glitches
    local curr_pos = self.object:get_pos()

    self._last_time_command = self._last_time_command + self.dtime
    local player = nil
    if self.driver_name then player = minetest.get_player_by_name(self.driver_name) end

    if player then
        local ctrl = player:get_player_control()
        ----------------------------------
        -- shows the hud for the player
        ----------------------------------
        if ctrl.up == true and ctrl.down == true and self._last_time_command >= 1 then
            self._last_time_command = 0
            if self._show_hud == true then
                self._show_hud = false
            else
                self._show_hud = true
            end
        end
    end

    local accel_y = self.object:get_acceleration().y
    local rotation = self.object:get_rotation()
    local yaw = rotation.y
	local newyaw=yaw
    local pitch = rotation.x
	local roll = rotation.z
	local newroll=roll
    if newroll > 360 then newroll = newroll - 360 end
    if newroll < -360 then newroll = newroll + 360 end

    local hull_direction = airutils.rot_to_dir(rotation) --minetest.yaw_to_dir(yaw)
    local nhdir = {x=hull_direction.z,y=0,z=-hull_direction.x}		-- lateral unit vector

    local longit_speed = vector.dot(velocity,hull_direction)
    self._longit_speed = longit_speed
    local longit_drag = vector.multiply(hull_direction,longit_speed*
            longit_speed*DEMOISELLE_LONGIT_DRAG_FACTOR*-1*demoiselle.sign(longit_speed))
	local later_speed = demoiselle.dot(velocity,nhdir)
    --minetest.chat_send_all('later_speed: '.. later_speed)
	local later_drag = vector.multiply(nhdir,later_speed*later_speed*
            DEMOISELLE_LATER_DRAG_FACTOR*-1*demoiselle.sign(later_speed))
    local accel = vector.add(longit_drag,later_drag)
    local stop = false

    local node_bellow = airutils.nodeatpos(airutils.pos_shift(curr_pos,{y=-0.1}))
    local is_flying = true
    if self.colinfo then
        is_flying = not self.colinfo.touching_ground
    end
    --if is_flying then minetest.chat_send_all('is flying') end

    local is_attached = demoiselle.checkAttach(self, player)

	if not is_attached then
        -- for some engine error the player can be detached from the machine, so lets set him attached again
        demoiselle.checkattachBug(self)
    end

    if longit_speed == 0 and is_flying == false and is_attached == false and self._engine_running == false then
        return
    end

    --ajustar angulo de ataque
    if longit_speed then
        local percentage = math.abs(((longit_speed * 100)/(demoiselle.min_speed + 5))/100)
        if percentage > 1.5 then percentage = 1.5 end
        self._angle_of_attack = self._angle_of_attack - ((self._elevator_angle / 20)*percentage)
        if self._angle_of_attack < -0.5 then
            self._angle_of_attack = -0.1
            self._elevator_angle = self._elevator_angle - 0.1
        end --limiting the negative angle]]--
        if self._angle_of_attack > 20 then
            self._angle_of_attack = 20
            self._elevator_angle = self._elevator_angle + 0.1
        end --limiting the very high climb angle due to strange behavior]]--

        --set the plane on level
        if airutils.adjust_attack_angle_by_speed then
            self._angle_of_attack = airutils.adjust_attack_angle_by_speed(self._angle_of_attack, 2.7, 5, 30, longit_speed, demoiselle.ideal_step, self.dtime)
        end
    end

    --minetest.chat_send_all(self._angle_of_attack)

    -- pitch
    local newpitch = math.rad(0)
    if airutils.get_plane_pitch then
        newpitch = airutils.get_plane_pitch(velocity, longit_speed, demoiselle.min_speed, self._angle_of_attack)
    end

    -- wheels
    if is_flying == false then --isn't flying?
        --animate wheels
        self.object:set_animation_frame_speed(longit_speed * 10)
    else
        --stop wheels
        self.object:set_animation_frame_speed(0)
    end
    
    -- adjust pitch at ground (got from supercub, I have to put it in lib in future)
    if is_flying == false then
        local tail_lift_min_speed = demoiselle.min_speed
        local tail_lift_max_speed = tail_lift_min_speed + 1
        local tail_angle = 0
        if math.abs(longit_speed) > tail_lift_min_speed then
            if math.abs(longit_speed) < tail_lift_max_speed then
                --minetest.chat_send_all(math.abs(longit_speed))
                local speed_range = tail_lift_max_speed - tail_lift_min_speed
                percentage = 1-((math.abs(longit_speed) - tail_lift_min_speed)/speed_range)
                if percentage > 1 then percentage = 1 end
                if percentage < 0 then percentage = 0 end
                local angle = tail_angle * percentage
                local calculated_newpitch = math.rad(angle)
                if newpitch < calculated_newpitch then newpitch = calculated_newpitch end --ja aproveita o pitch atual se ja estiver cerrto
                if newpitch > math.rad(tail_angle) then newpitch = math.rad(tail_angle) end --não queremos arrastar o cauda no chão
            end
        else
            if math.abs(longit_speed) < tail_lift_min_speed then
                newpitch = math.rad(tail_angle)
            end
        end
    end

    -- new yaw
	if math.abs(self._rudder_angle)>1 then
        local turn_rate = math.rad(14)
        local yaw_turn = self.dtime * math.rad(self._rudder_angle) * turn_rate *
                demoiselle.sign(longit_speed) * math.abs(longit_speed/2)
		newyaw = yaw + yaw_turn
	end

    --roll adjust
    ---------------------------------
    local delta = 0.002
    if is_flying then
        local roll_reference = newyaw
        local sdir = minetest.yaw_to_dir(roll_reference)
        local snormal = {x=sdir.z,y=0,z=-sdir.x}	-- rightside, dot is negative
        local prsr = demoiselle.dot(snormal,nhdir)
        local rollfactor = -90
        local roll_rate = math.rad(15)
        newroll = (prsr*math.rad(rollfactor)) * (later_speed * roll_rate) * demoiselle.sign(longit_speed)
        --minetest.chat_send_all('newroll: '.. newroll)
    else
        delta = 0.2
        if roll > 0 then
            newroll = roll - delta
            if newroll < 0 then newroll = 0 end
        end
        if roll < 0 then
            newroll = roll + delta
            if newroll > 0 then newroll = 0 end
        end
    end

    ---------------------------------
    -- end roll

    local pilot = player
    if self._command_is_given and passenger then
        pilot = passenger
    else
        self._command_is_given = false
    end

    ------------------------------------------------------
    --accell calculation block
    ------------------------------------------------------
    if is_attached or passenger then
        accel, stop = demoiselle.control(self, self.dtime, hull_direction,
            longit_speed, longit_drag, later_speed, later_drag, accel, pilot, is_flying)
    end

    --end accell

    if accel == nil then accel = {x=0,y=0,z=0} end

    --lift calculation
    accel.y = accel_y --accel.y

    --lets apply some bob in water
	if self.isinliquid then
        self._engine_running = false
        local bob = demoiselle.minmax(demoiselle.dot(accel,hull_direction),0.4)	-- vertical bobbing
        accel.y = accel.y + bob
        local max_pitch = 6
        local h_vel_compensation = (((longit_speed * 4) * 100)/max_pitch)/100
        if h_vel_compensation < 0 then h_vel_compensation = 0 end
        if h_vel_compensation > max_pitch then h_vel_compensation = max_pitch end
        newpitch = newpitch + (velocity.y * math.rad(max_pitch - h_vel_compensation))
    end

    local new_accel = accel
    if longit_speed > 1.5 then
        
        new_accel = airutils.getLiftAccel(self, velocity, new_accel, longit_speed, roll, curr_pos, demoiselle.lift, 7000)
    end
    -- end lift

    if stop ~= true then
        self.object:move_to(curr_pos)
        --self.object:set_velocity(velocity)
        self._last_accell = new_accel
        --[[if player then
            demoiselle.attach(self, player)
        end]]--
        self.object:set_acceleration(new_accel)
    elseif stop == true then
        self.object:set_velocity({x=0,y=0,z=0})
    end
    ------------------------------------------------------
    -- end accell
    ------------------------------------------------------

    --self.object:get_luaentity() --hack way to fix jitter on climb

    --adjust climb indicator
    local climb_rate = velocity.y * 1.5
    if climb_rate > 5 then climb_rate = 5 end
    if climb_rate < -5 then
        climb_rate = -5
    end

    --in a command compression during a dive, force the control to recover
    local longit_initial_speed = 10
    --minetest.chat_send_all(longit_speed)
    if longit_speed > longit_initial_speed and climb_rate < 0 and is_flying then
        local recover_command = -0.2
        self._elevator_angle = recover_command
    end

    --is an stall, force a recover
    if longit_speed < (demoiselle.min_speed / 2) and climb_rate < -3 and is_flying then
        self._elevator_angle = 0
        self._angle_of_attack = -2
        newpitch = math.rad(self._angle_of_attack)
    end

    --minetest.chat_send_all('rate '.. climb_rate)
    local climb_angle = demoiselle.get_gauge_angle(climb_rate)

    local indicated_speed = longit_speed
    if indicated_speed < 0 then indicated_speed = 0 end
    local speed_angle = demoiselle.get_gauge_angle(indicated_speed, -45)
    --adjust power indicator
    local power_indicator_angle = demoiselle.get_gauge_angle(self._power_lever/10) + 90
    local energy_indicator_angle = (demoiselle.get_gauge_angle((DEMOISELLE_MAX_FUEL - self._energy)*2)) - 90

    if is_attached then
        if self._show_hud then
            demoiselle.update_hud(player, climb_angle, speed_angle, power_indicator_angle, energy_indicator_angle)
        else
            demoiselle.remove_hud(player)
        end
    end

    if is_flying == false then
        -- new yaw
        local turn_rate = math.rad(30)
        local yaw_turn = self.dtime * math.rad(self._rudder_angle) * turn_rate *
                    demoiselle.sign(longit_speed) * math.abs(longit_speed/2)
	    newyaw = yaw + yaw_turn
    end

    --apply rotations
    self.object:set_rotation({x=newpitch,y=newyaw,z=newroll})

    --adjust elevator pitch (3d model)
    self.object:set_bone_position("empenagem", {x=0, y=33.5, z=-0.5}, {x=-self._elevator_angle/2.5, y=0, z=self._rudder_angle/2.5})

    -- calculate energy consumption --
    demoiselle.consumptionCalc(self, accel)

    --test collision
    demoiselle.testImpact(self, velocity, curr_pos)

    --saves last velocity for collision detection (abrupt stop)
    self._last_vel = self.object:get_velocity()
end

