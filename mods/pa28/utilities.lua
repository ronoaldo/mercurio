dofile(minetest.get_modpath("pa28") .. DIR_DELIM .. "global_definitions.lua")
dofile(minetest.get_modpath("pa28") .. DIR_DELIM .. "hud.lua")

function pa28.get_hipotenuse_value(point1, point2)
    return math.sqrt((point1.x - point2.x) ^ 2 + (point1.y - point2.y) ^ 2 + (point1.z - point2.z) ^ 2)
end

function pa28.dot(v1,v2)
	return v1.x*v2.x+v1.y*v2.y+v1.z*v2.z
end

function pa28.sign(n)
	return n>=0 and 1 or -1
end

function pa28.minmax(v,m)
	return math.min(math.abs(v),m)*pa28.sign(v)
end

function pa28.get_gauge_angle(value, initial_angle)
    initial_angle = initial_angle or 90
    local angle = value * 18
    angle = angle - initial_angle
    angle = angle * -1
	return angle
end

-- attach player
function pa28.attach(self, player, instructor_mode)
    instructor_mode = instructor_mode or false
    local name = player:get_player_name()
    self.driver_name = name

    -- attach the driver
    local eye_y = 0
    if instructor_mode == true then
        eye_y = -2.5
        player:set_attach(self.passenger_seat_base, "", {x = 0, y = 0, z = 0}, {x = 0, y = 0, z = 0})
    else
        eye_y = -4
        player:set_attach(self.pilot_seat_base, "", {x = 0, y = 0, z = 0}, {x = 0, y = 0, z = 0})
    end
    if airutils.detect_player_api(player) == 1 then
        eye_y = eye_y + 6.5
    end

    player:set_eye_offset({x = 0, y = eye_y, z = 2}, {x = 0, y = 1, z = -30})
    player_api.player_attached[name] = true
    player_api.set_animation(player, "sit")
    --player:set_physics_override({gravity = 0})
    -- make the driver sit
    minetest.after(1, function()
        if player then
            --minetest.chat_send_all("okay")
            airutils.sit(player)
            --apply_physics_override(player, {speed=0,gravity=0,jump=0})
        end
    end)
end

-- attach passenger
function pa28.check_passenger_is_attached(self, name)
    local is_attached = false
    if self._passenger == name then is_attached = true end
    if is_attached == false then
        for i = 2,1,-1 
        do 
            if self._passengers[i] == name then
                is_attached = true
                break
            end
        end
    end
    return is_attached
end

-- attach passenger
function pa28.attach_pax(self, player, is_copilot)
    local is_copilot = is_copilot or false
    local name = player:get_player_name()

    local eye_y = -4
    if airutils.detect_player_api(player) == 1 then
        eye_y = 2.5
    end

    if is_copilot == true then
        if self._passenger == nil and self.co_pilot_seat_base then
            self._passenger = name

            -- attach the driver
            player:set_attach(self.co_pilot_seat_base, "", {x = 0, y = 0, z = 0}, {x = 0, y = 0, z = 0})
            player:set_eye_offset({x = 0, y = eye_y, z = 2}, {x = 0, y = 3, z = -30})
            player_api.player_attached[name] = true
            player_api.set_animation(player, "sit")
            -- make the driver sit
            minetest.after(0.3, function()
                player = minetest.get_player_by_name(name)
                if player then
                    airutils.sit(player)
                    --apply_physics_override(player, {speed=0,gravity=0,jump=0})
                end
            end)
        end
    else
        --randomize the seat
        local t = {1,2}
        for i = 1, #t*2 do
            local a = math.random(#t)
            local b = math.random(#t)
            t[a],t[b] = t[b],t[a]
        end

        --for i = 1,10,1 do
        for k,v in ipairs(t) do
            i = t[k]
            if self._passengers[i] == nil then
                --minetest.chat_send_all(self.driver_name)
                self._passengers[i] = name
                player:set_attach(self._passengers_base[i], "", {x = 0, y = 0, z = 0}, {x = 0, y = 0, z = 0})
                if i > 2 then
                    player:set_eye_offset({x = 0, y = eye_y, z = 2}, {x = 0, y = 3, z = -30})
                else
                    player:set_eye_offset({x = 0, y = eye_y, z = 0}, {x = 0, y = 3, z = -30})
                end
                player_api.player_attached[name] = true
                player_api.set_animation(player, "sit")
                -- make the driver sit
                minetest.after(0.3, function()
                    player = minetest.get_player_by_name(name)
                    if player then
                        airutils.sit(player)
                        --apply_physics_override(player, {speed=0,gravity=0,jump=0})
                    end
                end)
                break
            end
        end

    end
end

function pa28.dettach_pax(self, player)
    local name = player:get_player_name() --self._passenger

    -- passenger clicked the object => driver gets off the vehicle
    if self._passenger == name then
        self._passenger = nil
    else
        for i = 4,1,-1 
        do 
            if self._passengers[i] == name then
                self._passengers[i] = nil
                break
            end
        end
    end

    -- detach the player
    if player then
        player:set_detach()
        player_api.player_attached[name] = nil
        player_api.set_animation(player, "stand")
        player:set_eye_offset({x=0,y=0,z=0},{x=0,y=0,z=0})
        --remove_physics_override(player, {speed=1,gravity=1,jump=1})
    end
end

function pa28.dettachPlayer(self, player)
    local name = self.driver_name
    airutils.setText(self, pa28.plane_text)

    pa28.remove_hud(player)

    --self._engine_running = false

    -- driver clicked the object => driver gets off the vehicle
    self.driver_name = nil

    -- detach the player
    --player:set_physics_override({speed = 1, jump = 1, gravity = 1, sneak = true})
    player:set_detach()
    player_api.player_attached[name] = nil
    player:set_eye_offset({x=0,y=0,z=0},{x=0,y=0,z=0})
    player_api.set_animation(player, "stand")
    self.driver = nil
    --remove_physics_override(player, {speed=1,gravity=1,jump=1})
end

function pa28.checkAttach(self, player)
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
function pa28.destroy(self)
    if self.sound_handle then
        minetest.sound_stop(self.sound_handle)
        self.sound_handle = nil
    end

    if self._passenger then
        -- detach the passenger
        local passenger = minetest.get_player_by_name(self._passenger)
        if passenger then
            pa28.dettach_pax(self, passenger)
        end
    end

    if self.driver_name then
        -- detach the driver
        local player = minetest.get_player_by_name(self.driver_name)
        pa28.dettachPlayer(self, player)
    end

    local pos = self.object:get_pos()
    if self.lights then self.lights:remove() end
    if self.light then self.light:remove() end
    if self.engine then self.engine:remove() end
    if self.pilot_seat_base then self.pilot_seat_base:remove() end
    if self.co_pilot_seat_base then self.co_pilot_seat_base:remove() end
    if self._passengers_base[1] then self._passengers_base[1]:remove() end
    if self._passengers_base[2] then self._passengers_base[2]:remove() end

    airutils.destroy_inventory(self)
    self.object:remove()
    if not minetest.settings:get_bool('pa28.disable_craftitems') then
        pos.y=pos.y+2
        minetest.add_item({x=pos.x+math.random()-0.5,y=pos.y,z=pos.z+math.random()-0.5},'pa28:wings')

        for i=1,2 do
	        minetest.add_item({x=pos.x+math.random()-0.5,y=pos.y,z=pos.z+math.random()-0.5},'default:tin_ingot')
        end

        for i=1,6 do
	        minetest.add_item({x=pos.x+math.random()-0.5,y=pos.y,z=pos.z+math.random()-0.5},'default:mese_crystal')
            minetest.add_item({x=pos.x+math.random()-0.5,y=pos.y,z=pos.z+math.random()-0.5},'default:diamond')
        end
    else
        minetest.add_item({x=pos.x+math.random()-0.5,y=pos.y,z=pos.z+math.random()-0.5},'pa28:pa28')
    end
end

function pa28.testDamage(self, velocity, position)
    if self._last_accell == nil then return end
    local p = position --self.object:get_pos()
    local collision = false
    local low_node_pos = -2.0
    if self._last_vel == nil then return end
    --lets calculate the vertical speed, to avoid the bug on colliding on floor with hard lag
    if abs(velocity.y - self._last_vel.y) > 2 then
		local noded = airutils.nodeatpos(airutils.pos_shift(p,{y=low_node_pos}))
	    if (noded and noded.drawtype ~= 'airlike') then
		    collision = true
	    else
            self.object:set_velocity(self._last_vel)
            --self.object:set_acceleration(self._last_accell)
            self.object:set_velocity(vector.add(velocity, vector.multiply(self._last_accell, self.dtime/8)))
        end
    end
    local impact = abs(pa28.get_hipotenuse_value(velocity, self._last_vel))
    --minetest.chat_send_all('impact: '.. impact .. ' - hp: ' .. self.hp_max)
    if impact > 2 then
        if self.colinfo then
            collision = self.colinfo.collides
        end
    end

    if impact > 1.2  and self._longit_speed > 3 then
        local noded = airutils.nodeatpos(airutils.pos_shift(p,{y=low_node_pos}))
	    if (noded and noded.drawtype ~= 'airlike') then
            minetest.sound_play("pa28_touch", {
                --to_player = self.driver_name,
                object = self.object,
                max_hear_distance = 15,
                gain = 1.0,
                fade = 0.0,
                pitch = 1.0,
            }, true)
	    end
    end

    --damage by speed
    if self._last_speed_damage_time == nil then self._last_speed_damage_time = 0 end
    self._last_speed_damage_time = self._last_speed_damage_time + self.dtime
    if self._last_speed_damage_time > 2 then self._last_speed_damage_time = 2 end
    if self._longit_speed > 14.7 and self._last_speed_damage_time >= 2 then
        self._last_speed_damage_time = 0
        minetest.sound_play("pa28_collision", {
            --to_player = self.driver_name,
            object = self.object,
            max_hear_distance = 15,
            gain = 1.0,
            fade = 0.0,
            pitch = 1.0,
        }, true)
        self.hp_max = self.hp_max - 5
        if self.driver_name then
            local player_name = self.driver_name
            airutils.setText(self, pa28.plane_text)
        end
        if self.hp_max < 0 then --if acumulated damage is greater than 50, adieu
            pa28.destroy(self)
        end
    end

    if collision then
        --self.object:set_velocity({x=0,y=0,z=0})
        local damage = impact -- / 2
        self.hp_max = self.hp_max - damage --subtract the impact value directly to hp meter
        minetest.sound_play("pa28_collision", {
            --to_player = self.driver_name,
            object = self.object,
            max_hear_distance = 15,
            gain = 1.0,
            fade = 0.0,
            pitch = 1.0,
        }, true)
        if damage > 5 then
            self._power_lever = 0
            self._engine_running = false
        end

        if self.driver_name then
            local player_name = self.driver_name
            airutils.setText(self, pa28.plane_text)

            --minetest.chat_send_all('damage: '.. damage .. ' - hp: ' .. self.hp_max)
            if self.hp_max < 0 then --if acumulated damage is greater than 50, adieu
                pa28.destroy(self)
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

function pa28.checkattachBug(self)
    -- for some engine error the player can be detached from the plane, so lets set him attached again
    if self.owner and self.driver_name then
        -- attach the driver again
        local player = minetest.get_player_by_name(self.owner)
        if player then
		    if player:get_hp() > 0 then
                pa28.attach(self, player, self._instruction_mode)
            else
                pa28.dettachPlayer(self, player)
		    end
        else
            if self._passenger ~= nil and self._command_is_given == false then
                self._autopilot = false
                airutils.transfer_control(self, true)
            end
        end
    end
end

function pa28.engineSoundPlay(self)
    --sound
    if self.sound_handle then minetest.sound_stop(self.sound_handle) end
    if self.object then
        self.sound_handle = minetest.sound_play({name = "pa28_engine"},
            {object = self.object, gain = 2.0,
                pitch = 0.5 + ((self._power_lever/100)/2),
                max_hear_distance = 32,
                loop = true,})
    end
end

function pa28.engine_set_sound_and_animation(self)
    --minetest.chat_send_all('test1 ' .. dump(self._engine_running) )
    if self._engine_running then
        if self._last_applied_power ~= self._power_lever then
            --minetest.chat_send_all('test2')
            self._last_applied_power = self._power_lever
            self.engine:set_animation_frame_speed(60 + self._power_lever)
            pa28.engineSoundPlay(self)
        end
    else
        if self.sound_handle then
            minetest.sound_stop(self.sound_handle)
            self.sound_handle = nil
            self.engine:set_animation_frame_speed(0)
        end
    end
end

function pa28.start_engine(self)
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
        pa28.engineSoundPlay(self)
        self.engine:set_animation_frame_speed(60)
    end
end

function pa28.flap_on(self)
    self._wing_configuration = 2.5
    self.object:set_bone_position("flap.l", {x=0, y=0, z=0}, {x=-30, y=0, z=0})
    self.object:set_bone_position("flap.r", {x=0, y=0, z=0}, {x=-30, y=0, z=0})
end

function pa28.flap_off(self)
    self._wing_configuration = pa28.wing_angle_of_attack
    self.object:set_bone_position("flap.l", {x=0, y=0, z=0}, {x=0, y=0, z=0})
    self.object:set_bone_position("flap.r", {x=0, y=0, z=0}, {x=0, y=0, z=0})
end

function pa28.flap_operate(self, player)
    if self._flap == false then
        minetest.chat_send_player(player:get_player_name(), ">>> Flap down")
        self._flap = true
        pa28.flap_on(self)
        minetest.sound_play("pa28_collision", {
            object = self.object,
            max_hear_distance = 15,
            gain = 1.0,
            fade = 0.0,
            pitch = 0.5,
        }, true)
    else
        minetest.chat_send_player(player:get_player_name(), ">>> Flap up")
        self._flap = false
        pa28.flap_off(self)
        minetest.sound_play("pa28_collision", {
            object = self.object,
            max_hear_distance = 15,
            gain = 1.0,
            fade = 0.0,
            pitch = 0.7,
        }, true)
    end
end

function pa28.flightstep(self)
    local velocity = self.object:get_velocity()
    local curr_pos = self.object:get_pos()

    self._last_time_command = self._last_time_command + self.dtime

    if self._last_time_command > 1.2 then self._last_time_command = 1.2 end

    local player = nil
    if self.driver_name then player = minetest.get_player_by_name(self.driver_name) end
    local passenger = nil
    if self._passenger then passenger = minetest.get_player_by_name(self._passenger) end

    local ctrl = nil
    if player then
        ctrl = player:get_player_control()
        ---------------------
        -- change the driver
        ---------------------
        if passenger and self._last_time_command >= 1 then
            if self._command_is_given == true then
                if ctrl.sneak or ctrl.jump or ctrl.up or ctrl.down or ctrl.right or ctrl.left then
                    self._last_time_command = 0
                    --take the control
                    airutils.transfer_control(self, false)
                end
            else
                if ctrl.aux1 == true and ctrl.jump == true then
                    self._last_time_command = 0
                    --trasnfer the control to student
                    airutils.transfer_control(self, true)
                end
            end
        end
        -----------
        --autopilot
        -----------
        if self._last_time_command >= 1 then
            if self._autopilot == true then
                if ctrl.sneak or ctrl.jump or ctrl.up or ctrl.down or ctrl.right or ctrl.left then
                    self._last_time_command = 0
                    self._autopilot = false
                    minetest.chat_send_player(self.driver_name," >>> Autopilot deactivated")
                end
            else
                if ctrl.sneak == true and ctrl.jump == true then
                    self._last_time_command = 0
                    self._autopilot = true
                    self._auto_pilot_altitude = curr_pos.y
                    minetest.chat_send_player(self.driver_name,core.colorize('#00ff00', " >>> Autopilot on"))
                end
            end
        end
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
            longit_speed*PA28_LONGIT_DRAG_FACTOR*-1*pa28.sign(longit_speed))
	local later_speed = pa28.dot(velocity,nhdir)
    --minetest.chat_send_all('later_speed: '.. later_speed)
	local later_drag = vector.multiply(nhdir,later_speed*later_speed*
            PA28_LATER_DRAG_FACTOR*-1*pa28.sign(later_speed))
    local accel = vector.add(longit_drag,later_drag)
    local stop = false

    local node_bellow = airutils.nodeatpos(airutils.pos_shift(curr_pos,{y=-2.0}))
    local is_flying = true
    if self.colinfo then
        is_flying = not self.colinfo.touching_ground
    end
    --if node_bellow and node_bellow.drawtype ~= 'airlike' then is_flying = false end
    
    --if is_flying then minetest.chat_send_all('is flying') end

    local is_attached = pa28.checkAttach(self, player)

    --landing light
    self._last_light_move = self._last_light_move + self.dtime
    if self._last_light_move > 0.15 then
        self._last_light_move = 0
        if self._land_light == true and is_attached then
            self._light_active_time = self._light_active_time + self.dtime
            --minetest.chat_send_all(self._light_active_time)
            if self._light_active_time > 24 then self._land_light = false end
            self.light:set_properties({textures={"pa28_landing_light.png"},glow=15})
            airutils.put_light(self)
        else
            self._land_light = false
            self._light_active_time = 0
            self.light:set_properties({textures={"pa28_metal.png"},glow=0})
            airutils.remove_light(self)
        end
    end

	if not is_attached then
        -- for some engine error the player can be detached from the machine, so lets set him attached again
        pa28.checkattachBug(self)
    end

    if longit_speed == 0 and is_flying == false and is_attached == false and self._engine_running == false then
        if pa28.mode == 1 then
            self.object:move_to(curr_pos)
            self.object:set_acceleration({x=0,y=airutils.gravity,z=0})
        end
        return
    end

    --ajustar angulo de ataque
    if longit_speed then
        local percentage = math.abs(((longit_speed * 100)/(pa28.min_speed + 5))/100)
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
            self._angle_of_attack = airutils.adjust_attack_angle_by_speed(self._angle_of_attack, 1, 5, 45, longit_speed, pa28.ideal_step, self.dtime)
        end
    end

    -- pitch
    local newpitch = math.rad(0)
    if airutils.get_plane_pitch then
        newpitch = airutils.get_plane_pitch(velocity, longit_speed, pa28.min_speed, self._angle_of_attack)
    end

    -- adjust pitch at ground
    if is_flying == false then
        if newpitch < 0 then newpitch = 0 end

        local min_speed = 4
        if longit_speed < min_speed then
            if newpitch > 0 then
                local percentage = ((longit_speed * 100)/min_speed)/100
                newpitch = newpitch * percentage
                if newpitch < 0 then newpitch = 0 end
            end
        end
    end

    -- new yaw
	if math.abs(self._rudder_angle)>1.5 then
        local turn_rate = math.rad(12)
        local yaw_turn = self.dtime * math.rad(self._rudder_angle) * turn_rate *
                pa28.sign(longit_speed) * math.abs(longit_speed/2)
		newyaw = yaw + yaw_turn
	end

    --roll adjust
    ---------------------------------
    local delta = 0.002
    if is_flying then
        local roll_reference = newyaw
        local sdir = minetest.yaw_to_dir(roll_reference)
        local snormal = {x=sdir.z,y=0,z=-sdir.x}	-- rightside, dot is negative
        local prsr = pa28.dot(snormal,nhdir)
        local rollfactor = -90
        local roll_rate = math.rad(10)
        newroll = (prsr*math.rad(rollfactor)) * (later_speed * roll_rate) * pa28.sign(longit_speed)
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
        if self._autopilot ~= true then
            accel, stop = pa28.control(self, self.dtime, hull_direction,
                longit_speed, longit_drag, later_speed, later_drag, accel, pilot, is_flying)
        else
            accel = pa28.autopilot(self, self.dtime, hull_direction, longit_speed, accel, curr_pos)
        end
    end

    --end accell

    if accel == nil then accel = {x=0,y=0,z=0} end

    --lift calculation
    accel.y = accel_y

    --lets apply some bob in water
	if self.isinliquid then
        self._engine_running = false
        local bob = pa28.minmax(pa28.dot(accel,hull_direction),0.2)	-- vertical bobbing
        accel.y = accel.y + bob
        local max_pitch = 6
        local h_vel_compensation = (((longit_speed * 2) * 100)/max_pitch)/100
        if h_vel_compensation < 0 then h_vel_compensation = 0 end
        if h_vel_compensation > max_pitch then h_vel_compensation = max_pitch end
        newpitch = newpitch + (velocity.y * math.rad(max_pitch - h_vel_compensation))
    end

    local new_accel = accel
    if longit_speed > 1.5 then
        --[[lets do something interesting:
        here I'll fake the longit speed effect for takeoff, to force the airplane
        to use more runway 
        ]]--
        local factorized_longit_speed = longit_speed
        if is_flying == false and airutils.quadBezier then
            local takeoff_speed = pa28.min_speed * 4  --so first I'll consider the takeoff speed 4x the minimal flight speed
            if longit_speed < takeoff_speed and longit_speed > pa28.min_speed then -- then if the airplane is above the mininam speed and bellow the take off
                local scale = (longit_speed*1)/takeoff_speed --get a scale of current longit speed relative to takeoff speed
                if scale == nil then scale = 0 end --lets avoid any nil
                factorized_longit_speed = airutils.quadBezier(scale, pa28.min_speed, longit_speed, longit_speed) --here the magic happens using a bezier curve
                --minetest.chat_send_all("factor: " .. factorized_longit_speed .. " - longit: " .. longit_speed .. " - scale: " .. scale)
                if factorized_longit_speed < 0 then factorized_longit_speed = 0 end --lets avoid negative numbers
                if factorized_longit_speed == nil then factorized_longit_speed = longit_speed end --and nil numbers
            end
        end
        --now gets the lift!
        new_accel = airutils.getLiftAccel(self, velocity, new_accel, factorized_longit_speed, roll, curr_pos, pa28.lift, 15000, 12) --I added more 3 meters for wingspan to increase the ground effect for the low wing (the wingspan variable is only used for ground effect)
    end
    -- end lift

    if stop ~= true then --maybe == nil
        self._last_accell = new_accel
        
        --solution to avoid rubber band bug
        --[[if player then 
            pa28.attach(self, player, false)
        end]]--

        --for mode==1, see at custom_physics
        if pa28.mode == 2 then
            self.object:move_to(curr_pos)
            airutils.set_acceleration(self.object, new_accel)
        end
    else
        if stop == true then
            self.object:set_acceleration({x=0,y=0,z=0})
            self.object:set_velocity({x=0,y=0,z=0})
        end
    end

    if is_flying == false then --isn't flying?
        --animate wheels
        if math.abs(longit_speed) > 0.2 then
            self.object:set_animation_frame_speed(longit_speed * 20)
        else
            self.object:set_animation_frame_speed(0)
        end
    else
        --stop wheels
        self.object:set_animation_frame_speed(0)
    end
    ------------------------------------------------------
    -- end accell
    ------------------------------------------------------

    ------------------------------------------------------
    -- sound and animation
    ------------------------------------------------------
    pa28.engine_set_sound_and_animation(self)
    ------------------------------------------------------

    --adjust climb indicator
    local climb_rate = velocity.y
    if self.isonground then climb_rate = 0 end
    if climb_rate > 5 then climb_rate = 5 end
    if climb_rate < -5 then
        climb_rate = -5
    end

    --in a command compression during a dive, force the control to recover
    local longit_initial_speed = 13.0
    --minetest.chat_send_all(longit_speed)
    if longit_speed > longit_initial_speed and climb_rate < 0 and is_flying then
        local recover_command = -0.2
        if ctrl then
            if not ctrl.up then
                self._elevator_angle = recover_command
            end
        else
            self._elevator_angle = recover_command
        end
    end

    --is an stall, force a recover
    if longit_speed < (pa28.min_speed) and climb_rate < -3 and is_flying then
        self._elevator_angle = 0
        self._angle_of_attack = -2
        newpitch = math.rad(self._angle_of_attack)
    end

    --minetest.chat_send_all("speed: "..longit_speed.." - climb: "..climb_rate.." - angle attack: "..self._angle_of_attack.." - elevator:"..self._elevator_angle)

    --minetest.chat_send_all('rate '.. climb_rate)
    local climb_angle = pa28.get_gauge_angle(climb_rate)
    self.object:set_bone_position("climber", {x=-1.98,y=2.40,z=10.2}, {x=0,y=0,z=climb_angle-90})

    local indicated_speed = longit_speed * 0.9
    if indicated_speed < 0 then indicated_speed = 0 end
    local speed_angle = pa28.get_gauge_angle(indicated_speed, -45)
    self.object:set_bone_position("speed", {x=-7.01,y=1.26,z=10.2}, {x=0,y=0,z=speed_angle})

    local energy_indicator_angle = pa28.get_gauge_angle((PA28_MAX_FUEL - self._energy)/1.5) - 90
    self.object:set_bone_position("fuel", {x=0, y=0, z=10.2}, {x=0, y=0, z=-energy_indicator_angle+180})

    self.object:set_bone_position("compass", {x=0, y=2.8, z=10.3}, {x=0, y=0, z=-(math.deg(newyaw))})
    local adf = 0
    if self._adf == true then
        if airutils.getAngleFromPositions then
            adf = airutils.getAngleFromPositions(curr_pos, self._adf_destiny)
            adf = -(adf + math.deg(newyaw))
            --minetest.chat_send_all(adf)
        else
            minetest.chat_send_player(self.driver_name," >>> Impossible to activate the ADF - the airutils lib is outdated")
        end
    end
    self.object:set_bone_position("compass_plan", {x=0, y=2.8, z=10.25}, {x=0, y=0, z=adf})

    --altimeter
    local altitude = (curr_pos.y / 0.32) / 100
    local hour, minutes = math.modf( altitude )
    hour = math.fmod (hour, 10)
    minutes = minutes * 100
    minutes = (minutes * 100) / 100
    local minute_angle = (minutes*-360)/100
    local hour_angle = (hour*-360)/10 + ((minute_angle*36)/360)
    self.object:set_bone_position("altimeter_pt_1", {x=-4.63, y=2.4, z=10.2}, {x=0, y=0, z=(hour_angle)})
    self.object:set_bone_position("altimeter_pt_2", {x=-4.63, y=2.4, z=10.2}, {x=0, y=0, z=(minute_angle)})


    if is_attached then
        if self._show_hud then
            pa28.update_hud(player, climb_angle, speed_angle)
        else
            pa28.remove_hud(player)
        end
    end

    --adjust power indicator
    local power_indicator_angle = pa28.get_gauge_angle(self._power_lever/6.5)
    self.object:set_bone_position("power", {x=2.8,y=2.40,z=10.2}, {x=0,y=0,z=power_indicator_angle - 90})

    if is_flying == false then
        -- new yaw
        local turn_rate = math.rad(30)
        local yaw_turn = self.dtime * math.rad(self._rudder_angle) * turn_rate *
                    pa28.sign(longit_speed) * math.abs(longit_speed/2)
	    newyaw = yaw + yaw_turn
    end
    --apply rotations
    self.object:set_rotation({x=newpitch,y=newyaw,z=newroll})
    --end

    --adjust elevator pitch (3d model)
    self.object:set_bone_position("elevator", {x=0, y=2.5, z=-45}, {x=(-self._elevator_angle/3) - 90, y=0, z=0})
    --adjust rudder
    self.object:set_bone_position("rudder", {x=0,y=0,z=0}, {x=0,y=self._rudder_angle,z=0})
    --adjust ailerons
    self.object:set_bone_position("aileron.r", {x=0,y=0,z=0}, {x=-self._rudder_angle - 90,y=0,z=0})
    self.object:set_bone_position("aileron.l", {x=0,y=0,z=0}, {x=self._rudder_angle - 90,y=0,z=0})

    --set stick position
    local stick_z = 9 + (self._elevator_angle / pa28.elevator_limit )
    self.object:set_bone_position("stick.l", {x=-4.25, y=0.5, z=stick_z}, {x=0,y=0,z=self._rudder_angle})
    self.object:set_bone_position("stick.r", {x=4.25, y=0.5, z=stick_z}, {x=0,y=0,z=self._rudder_angle})

    if self._wing_configuration == pa28.wing_angle_of_attack and self._flap then
        pa28.flap_on(self)
    end
    if self._wing_configuration ~= pa28.wing_angle_of_attack and self._flap == false then
        pa28.flap_off(self)
    end

    if longit_speed > 9.5 and self._flap == true then
        if is_attached and self.driver_name then
            minetest.chat_send_player(self.driver_name, core.colorize('#ff0000', " >>> Flaps retracted due for overspeed"))
        end
        self._flap = false
    end

    if self._engine_running == true then
        self.lights:set_properties({textures={"pa28_l_light.png^pa28_l_light.png","pa28_l_light.png","pa28_r_light.png"},glow=15})
    else
        self.lights:set_properties({textures={"pa28_l_light.png","pa28_l_light.png","pa28_r_light.png"},glow=0})
    end


    -- calculate energy consumption --
    pa28.consumptionCalc(self, accel)

    --test damage
    pa28.testDamage(self, self.object:get_velocity(), curr_pos)

    --saves last velocity for collision detection (abrupt stop)
    self._last_vel = self.object:get_velocity()
end


