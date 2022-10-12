dofile(minetest.get_modpath("ju52") .. DIR_DELIM .. "ju52_global_definitions.lua")
dofile(minetest.get_modpath("ju52") .. DIR_DELIM .. "ju52_hud.lua")

function ju52.get_hipotenuse_value(point1, point2)
    return math.sqrt((point1.x - point2.x) ^ 2 + (point1.y - point2.y) ^ 2 + (point1.z - point2.z) ^ 2)
end

function ju52.dot(v1,v2)
	return v1.x*v2.x+v1.y*v2.y+v1.z*v2.z
end

function ju52.sign(n)
	return n>=0 and 1 or -1
end

function ju52.minmax(v,m)
	return math.min(math.abs(v),m)*ju52.sign(v)
end

function ju52.get_gauge_angle(value, initial_angle)
    initial_angle = initial_angle or 90
    local angle = value * 18
    angle = angle - initial_angle
    angle = angle * -1
	return angle
end


-- attach player
function ju52.attach(self, player)
    local name = player:get_player_name()
    self.driver_name = name

    -- attach the driver
    player:set_attach(self.pilot_seat_base, "", {x = 0, y = 0, z = 0}, {x = 0, y = 0, z = 0})
    local eye_y = -4
    if airutils.detect_player_api(player) == 1 then
        eye_y = 2.5
    end
    player:set_eye_offset({x = 0, y = eye_y, z = 2}, {x = 0, y = 3, z = -30})
    player_api.player_attached[name] = true
    player_api.set_animation(player, "sit")
    -- make the driver sit
    minetest.after(1, function()
        --player = minetest.get_player_by_name(name)
        if player then
            airutils.sit(player)
            --apply_physics_override(player, {speed=0,gravity=0,jump=0})
        end
    end)
end

function ju52.dettachPlayer(self, player)
    local name = self.driver_name
    airutils.setText(self, "Ju 52")

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
    if player then
        ju52.remove_hud(player)

        player:set_detach()
        player_api.player_attached[name] = nil
        player:set_eye_offset({x=0,y=0,z=0},{x=0,y=0,z=0})
        player_api.set_animation(player, "stand")
    end
    self.driver = nil
    --remove_physics_override(player, {speed=1,gravity=1,jump=1})
end

function ju52.check_passenger_is_attached(self, name)
    local is_attached = false
    if self._passenger == name then is_attached = true end
    if is_attached == false then
        for i = 10,1,-1 
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
function ju52.attach_pax(self, player, is_copilot)
    local is_copilot = is_copilot or false
    local name = player:get_player_name()

    local eye_y = -4
    if airutils.detect_player_api(player) == 1 then
        eye_y = 2.5
    end

    if is_copilot == true then
        if self._passenger == nil then
            self._passenger = name

            -- attach the driver
            player:set_attach(self.co_pilot_seat_base, "", {x = 0, y = 0, z = 0}, {x = 0, y = 0, z = 0})
            player:set_eye_offset({x = 0, y = eye_y, z = 2}, {x = 0, y = 3, z = -30})
            player_api.player_attached[name] = true
            player_api.set_animation(player, "sit")
            -- make the driver sit
            minetest.after(1, function()
                player = minetest.get_player_by_name(name)
                if player then
                    airutils.sit(player)
                    --apply_physics_override(player, {speed=0,gravity=0,jump=0})
                end
            end)
        end
    else
        --randomize the seat
        local t = {1,2,3,4,5,6,7,8,9,10}
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
                minetest.after(1, function()
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

function ju52.dettach_pax(self, player)
    local name = player:get_player_name() --self._passenger

    -- passenger clicked the object => driver gets off the vehicle
    if self._passenger == name then
        self._passenger = nil
    else
        for i = 10,1,-1 
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

function ju52.checkAttach(self, player)
    if player then
        local player_attach = player:get_attach()
        if player_attach then
            if player_attach == self.pilot_seat_base or player_attach == self.co_pilot_seat_base then
                return true
            end
        end
    end
    return false
end

--painting
function ju52.paint(object, colstr, search_string)
    if colstr then
        local entity = object:get_luaentity()
        entity._color = colstr
        entity._skin = ju52.skin_texture
        local l_textures = ju52.textures_copy()
        for _, texture in ipairs(l_textures) do
            local indx = texture:find(search_string)
            if indx then
                l_textures[_] = search_string .."^[multiply:".. colstr
            end
        end
        object:set_properties({textures=l_textures})
    end
end

function ju52.set_skin(object, skin_image_name, search_string)
    if skin_image_name then
        local entity = object:get_luaentity()
        entity._color = nil
        entity._skin = skin_image_name
        local l_textures = ju52.textures_copy()
        for _, texture in ipairs(l_textures) do
            local indx = texture:find(search_string)
            if indx then
                l_textures[_] = skin_image_name
                --minetest.chat_send_all(l_textures[_])
            end
        end
        object:set_properties({textures=l_textures})
    end
end

function ju52.start_engine(self)
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
        ju52.engineSoundPlay(self)
        self.engine:set_animation_frame_speed(60)
    end
end

-- destroy the boat
function ju52.destroy(self)
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
        ju52.dettachPlayer(self, player)
    end

    local pos = self.object:get_pos()
    if self.engine then self.engine:remove() end
    if self.pilot_seat_base then self.pilot_seat_base:remove() end
    if self.co_pilot_seat_base then self.co_pilot_seat_base:remove() end

    if self._passengers_base[10] then self._passengers_base[10]:remove() end
    if self._passengers_base[9]  then self._passengers_base[9]:remove() end
    if self._passengers_base[8]  then self._passengers_base[8]:remove() end
    if self._passengers_base[7]  then self._passengers_base[7]:remove() end
    if self._passengers_base[6]  then self._passengers_base[6]:remove() end
    if self._passengers_base[5]  then self._passengers_base[5]:remove() end
    if self._passengers_base[4]  then self._passengers_base[4]:remove() end
    if self._passengers_base[3]  then self._passengers_base[3]:remove() end
    if self._passengers_base[2]  then self._passengers_base[2]:remove() end
    if self._passengers_base[1]  then self._passengers_base[1]:remove() end

    if self.stick then self.stick:remove() end

    airutils.destroy_inventory(self)
    self.object:remove()
    if not minetest.settings:get_bool('ju52.disable_craftitems') then
        pos.y=pos.y+2
        minetest.add_item({x=pos.x+math.random()-0.5,y=pos.y,z=pos.z+math.random()-0.5},'ju52:wings')

        for i=1,6 do
	        minetest.add_item({x=pos.x+math.random()-0.5,y=pos.y,z=pos.z+math.random()-0.5},'default:steel_ingot')
        end

        for i=1,4 do
	        minetest.add_item({x=pos.x+math.random()-0.5,y=pos.y,z=pos.z+math.random()-0.5},'default:wood')
        end

        for i=1,6 do
	        minetest.add_item({x=pos.x+math.random()-0.5,y=pos.y,z=pos.z+math.random()-0.5},'default:mese_crystal')
        end
    else
        minetest.add_item({x=pos.x+math.random()-0.5,y=pos.y,z=pos.z+math.random()-0.5},'ju52:ju52')
    end
end

function ju52.testDamage(self, velocity, position)
    local p = position --self.object:get_pos()
    local collision = false
    if self._last_vel == nil then return end
    --lets calculate the vertical speed, to avoid the bug on colliding on floor with hard lag
    if abs(velocity.y - self._last_vel.y) > 4 then
		local noded = airutils.nodeatpos(airutils.pos_shift(p,{y=-2.8}))
	    if (noded and noded.drawtype ~= 'airlike') then
		    collision = true
	    else
            self.object:set_velocity(self._last_vel)
            --self.object:set_acceleration(self._last_accell)
        end
    end
    local impact = abs(ju52.get_hipotenuse_value(velocity, self._last_vel))
    --minetest.chat_send_all('impact: '.. impact .. ' - hp: ' .. self.hp_max)
    if impact > 2 then
        --minetest.chat_send_all('impact: '.. impact .. ' - hp: ' .. self.hp_max)
        if self.colinfo then
            collision = self.colinfo.collides
        end
    end

    if impact > 1 and self._longit_speed > 2 then
        local noded = airutils.nodeatpos(airutils.pos_shift(p,{y=-2.8}))
	    if (noded and noded.drawtype ~= 'airlike') then
            minetest.sound_play("ju52_touch", {
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
    if self._last_speed_damage_time > 3 then self._last_speed_damage_time = 3 end
    if self._longit_speed > 14 and self._last_speed_damage_time >= 3 then
        self._last_speed_damage_time = 0
        minetest.sound_play("ju52_collision", {
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
            airutils.setText(self, "Ju 52")
        end
        if self.hp_max < 0 then --if acumulated damage is greater than 50, adieu
            ju52.destroy(self)
        end
    end

    if collision then
        --self.object:set_velocity({x=0,y=0,z=0})
        local damage = impact / 2
        self.hp_max = self.hp_max - damage --subtract the impact value directly to hp meter
        minetest.sound_play("ju52_collision", {
            --to_player = self.driver_name,
            object = self.object,
            max_hear_distance = 15,
            gain = 1.0,
            fade = 0.0,
            pitch = 1.0,
        }, true)

        if self.driver_name then
            local player_name = self.driver_name
            airutils.setText(self, "Ju 52")

            --minetest.chat_send_all('damage: '.. damage .. ' - hp: ' .. self.hp_max)
            if self.hp_max < 0 then --if acumulated damage is greater than 50, adieu
                ju52.destroy(self)
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

function ju52.checkattachBug(self)
    -- for some engine error the player can be detached from the submarine, so lets set him attached again
    if self.owner and self.driver_name then
        -- attach the driver again
        local player = minetest.get_player_by_name(self.owner)
        if player then
		    if player:get_hp() > 0 then
                ju52.attach(self, player)
            else
                ju52.dettachPlayer(self, player)
		    end
        else
            if self._passenger ~= nil and self._command_is_given == false then
                self._autopilot = false
                airutils.transfer_control(self, true)
            end
        end
    end
end

function ju52.flap_on(self)
    self._wing_configuration = 2.5
    self.object:set_bone_position("l_flap1", {x=-40.5, y=2.3, z=1}, {x=6, y=8, z=96.2}) --recolhido {x=6, y=-8, z=94.4}  extendido {x=6, y=8, z=96.2}
    --self.object:set_bone_position("l_flap2", {x=0, y=9, z=0}, {x=6, y=8, z=96.2}) --recolhido {x=2.4, y=0, z=91}  extendido {x=6, y=8, z=96.2}

    self.object:set_bone_position("r_flap1", {x=40.5, y=2.3, z=1}, {x=347, y=242, z=275.8}) --recolhido {x=338,y=254,z=286}  extendido {x=347, y=242, z=275.8}
    --self.object:set_bone_position("r_flap2", {x=0, y=9, z=0}, {x=145, y=290, z=122}) --recolhido {x=58, y=283, z=213}  extendido {x=145, y=290, z=122}

end

function ju52.flap_off(self)
    self._wing_configuration = ju52.wing_angle_of_attack
    self.object:set_bone_position("l_flap1", {x=-40.5, y=2.3, z=1}, {x=6, y=-8, z=94.4}) --recolhido {x=6, y=-8, z=94.4}  extendido {x=6, y=8, z=96.2}
    --self.object:set_bone_position("l_flap2", {x=0, y=9, z=0}, {x=2.4, y=4, z=91}) --recolhido {x=2.4, y=0, z=91}  extendido {x=6, y=8, z=96.2}

    self.object:set_bone_position("r_flap1", {x=40.5, y=2.3, z=1}, {x=338,y=254,z=286}) --recolhido {x=338,y=254,z=286}  extendido {x=347, y=242, z=275.8}
    --self.object:set_bone_position("r_flap2", {x=0, y=9, z=0}, {x=58, y=283, z=212}) --recolhido {x=58, y=283, z=213}  extendido {x=145, y=290, z=122}

end

function ju52.flap_operate(self, player)
    if self._flap == false then
        minetest.chat_send_player(player:get_player_name(), ">>> Flap down")
        self._flap = true
        ju52.flap_on(self)
        minetest.sound_play("ju52_collision", {
            object = self.object,
            max_hear_distance = 15,
            gain = 1.0,
            fade = 0.0,
            pitch = 0.5,
        }, true)
    else
        minetest.chat_send_player(player:get_player_name(), ">>> Flap up")
        self._flap = false
        ju52.flap_off(self)
        minetest.sound_play("ju52_collision", {
            object = self.object,
            max_hear_distance = 15,
            gain = 1.0,
            fade = 0.0,
            pitch = 0.7,
        }, true)
    end
end

function ju52.door_operate(self, player)
    if self._door_closed == true then
        minetest.chat_send_player(player:get_player_name(), ">>> Door open")
        self.object:set_bone_position("door", {x=-11.35, y=32.65, z=9.87}, {x=88.5, y=0, z=0})
        self._door_closed = false
        minetest.sound_play("ju52_door", {
            object = self.object,
            max_hear_distance = 10,
            gain = 1.0,
            fade = 0.0,
            pitch = 0.5,
        }, true)
    else
        minetest.chat_send_player(player:get_player_name(), ">>> Door closed")
        self.object:set_bone_position("door", {x=-11.35, y=32.65, z=9.87}, {x=91.5, y=0, z=180})
        self._door_closed = true
        minetest.sound_play("ju52_door", {
            object = self.object,
            max_hear_distance = 10,
            gain = 1.0,
            fade = 0.0,
            pitch = 0.7,
        }, true)
    end
end

function ju52.engine_set_sound_and_animation(self)
    --minetest.chat_send_all('test1 ' .. dump(self._engine_running) )
    if self._engine_running then
        if self._last_applied_power ~= self._power_lever then
            --minetest.chat_send_all('test2')
            self._last_applied_power = self._power_lever
            self.engine:set_animation_frame_speed(60 + self._power_lever)
            ju52.engineSoundPlay(self)
        end
    else
        if self.sound_handle then
            minetest.sound_stop(self.sound_handle)
            self.sound_handle = nil
            self.engine:set_animation_frame_speed(0)
        end
    end
end

function ju52.tail(self, longit_speed, pitch)
    -- adjust pitch at ground
    local tail_lift_min_speed = 5
    local tail_lift_max_speed = 14
    local tail_angle = 17.4
    local new_pitch = pitch
    if math.abs(longit_speed) > tail_lift_min_speed then
        if math.abs(longit_speed) < tail_lift_max_speed then
            local speed_range = tail_lift_max_speed - tail_lift_min_speed
            local percentage = 1-((math.abs(longit_speed) - tail_lift_min_speed)/speed_range)
            if percentage > 1 then percentage = 1 end
            if percentage < 0 then percentage = 0 end
            local angle = tail_angle * percentage
            local calculated_newpitch = math.rad(angle)
            if new_pitch < calculated_newpitch then new_pitch = calculated_newpitch end --ja aproveita o pitch atual se ja estiver cerrto
            if new_pitch > math.rad(tail_angle) then new_pitch = math.rad(tail_angle) end --não queremos arrastar o cauda no chão
        end
    else
        --minetest.chat_send_all(dump(self.isinliquid) .. " ---- " .. dump(self.isonground) )
        if (self.isinliquid and self.isonground) then
            new_pitch = math.rad(tail_angle)
        else
            if math.abs(longit_speed) < tail_lift_min_speed and not(self.isinliquid) then
                new_pitch = math.rad(tail_angle)
            end
        end
    end
    return new_pitch
end

function ju52.flightstep(self)
    local velocity = self.object:get_velocity()
    local curr_pos = self.object:get_pos()
    
    self._last_time_command = self._last_time_command + self.dtime
    local player = nil
    if self.driver_name then player = minetest.get_player_by_name(self.driver_name) end
    local passenger = nil
    if self._passenger then passenger = minetest.get_player_by_name(self._passenger) end

    if player then
        local ctrl = player:get_player_control()

        --[[ --debug bones
        local scale = 1
        if ctrl.left then --ctrl.up or ctrl.down or ctrl.right or ctrl.left
            if ctrl.sneak then --ctrl.up or ctrl.down or ctrl.right or ctrl.left
                xyz.x = xyz.x - scale
                if xyz.x < 0 then xyz.x = xyz.x + 360 end
            else
                xyz.x = xyz.x + scale
                if xyz.x > 360 then xyz.x = xyz.x - 360 end
            end
        end
        if ctrl.down then
            if ctrl.sneak then
                xyz.y = xyz.y - scale
                if xyz.y < 0 then xyz.y = xyz.y + 360 end
            else
                xyz.y = xyz.y + scale
                if xyz.y > 360 then xyz.y = xyz.y - 360 end
            end
        end
        if ctrl.right then
            if ctrl.sneak then
                xyz.z = xyz.z - scale
                if xyz.z < 0 then xyz.z = xyz.z + 360 end
            else
                xyz.z = xyz.z + scale
                if xyz.z > 360 then xyz.z = xyz.z - 360 end
            end
        end]]--
        
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
                if ctrl.sneak == true and ctrl.jump == true then
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
            longit_speed*JU52_LONGIT_DRAG_FACTOR*-1*ju52.sign(longit_speed))
	local later_speed = ju52.dot(velocity,nhdir)
    --minetest.chat_send_all('later_speed: '.. later_speed)
	local later_drag = vector.multiply(nhdir,later_speed*later_speed*
            JU52_LATER_DRAG_FACTOR*-1*ju52.sign(later_speed))
    local accel = vector.add(longit_drag,later_drag)
    local stop = false

    local is_flying = true
    if self.isonground then is_flying = false end
    --if is_flying then minetest.chat_send_all('is flying') end

    local is_attached = ju52.checkAttach(self, player)

	if not is_attached then
        -- for some engine error the player can be detached from the machine, so lets set him attached again
        ju52.checkattachBug(self)
    end

    if longit_speed == 0 and is_flying == false and is_attached == false and self._engine_running == false then
        return
    end

    --ajustar angulo de ataque
    if longit_speed then
        local percentage = math.abs(((longit_speed * 100)/(ju52.min_speed + 5))/100)
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
            self._angle_of_attack = airutils.adjust_attack_angle_by_speed(self._angle_of_attack, 2, 5, 45, longit_speed, ju52.ideal_step, self.dtime)
        end
    end

    --minetest.chat_send_all(self._angle_of_attack)

    if longit_speed > 2 and self._door_closed == false then
        self._door_command = 1
    end

    if player then
        if self._door_command == 1 and self._door_closed == false then
            ju52.door_operate(self, player)
        end
        if self._door_command == 0 and self._door_closed == true then
            ju52.door_operate(self, player)
        end
    end

    -- pitch
    local newpitch = pitch
    if airutils.get_plane_pitch then
        newpitch = airutils.get_plane_pitch(velocity, longit_speed, ju52.min_speed, self._angle_of_attack)
    end

    -- new yaw
	if math.abs(self._rudder_angle)>1 then
        local turn_rate = math.rad(10)
        local turn = math.rad(self._rudder_angle) * turn_rate
        local yaw_turn = self.dtime * (turn * ju52.sign(longit_speed) * math.abs(longit_speed/3))
		newyaw = yaw + yaw_turn
	end

    --roll adjust
    ---------------------------------
    local delta = 0.002
    if is_flying then
        local roll_reference = newyaw
        local sdir = minetest.yaw_to_dir(roll_reference)
        local snormal = {x=sdir.z,y=0,z=-sdir.x}	-- rightside, dot is negative
        local prsr = ju52.dot(snormal,nhdir)
        local rollfactor = -90
        local roll_rate = math.rad(10)
        newroll = (prsr*math.rad(rollfactor)) * (later_speed * roll_rate) * ju52.sign(longit_speed)
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
        accel, stop = ju52.control(self, self.dtime, hull_direction,
            longit_speed, longit_drag, later_speed, later_drag, accel, pilot, is_flying)
    end

    --end accell

    if accel == nil then accel = {x=0,y=0,z=0} end

    --lift calculation
    accel.y = accel_y
    --accel.y = accel.y + airutils.gravity

    --lets apply some bob in water
	if self.isinliquid then
        self._engine_running = false
        local bob = ju52.minmax(ju52.dot(accel,hull_direction),0.4)	-- vertical bobbing
        accel.y = accel.y + bob
        local max_pitch = 6
        local h_vel_compensation = (((longit_speed * 4) * 100)/max_pitch)/100
        if h_vel_compensation < 0 then h_vel_compensation = 0 end
        if h_vel_compensation > max_pitch then h_vel_compensation = max_pitch end
        newpitch = newpitch + (velocity.y * math.rad(max_pitch - h_vel_compensation))
    end

    local new_accel = accel
    if longit_speed > ju52.min_speed / 2 then
        --[[lets do something interesting:
        here I'll fake the longit speed effect for takeoff, to force the airplane
        to use more runway 
        ]]--
        local factorized_longit_speed = longit_speed
        if is_flying == false and airutils.quadBezier then
            local takeoff_speed = ju52.min_speed * 4  --so first I'll consider the takeoff speed 4x the minimal flight speed
            if longit_speed < takeoff_speed and longit_speed > ju52.min_speed then -- then if the airplane is above the mininam speed and bellow the take off
                local scale = (longit_speed*1)/takeoff_speed --get a scale of current longit speed relative to takeoff speed
                if scale == nil then scale = 0 end --lets avoid any nil
                factorized_longit_speed = airutils.quadBezier(scale, ju52.min_speed, longit_speed, longit_speed) --here the magic happens using a bezier curve
                --minetest.chat_send_all("factor: " .. factorized_longit_speed .. " - longit: " .. longit_speed .. " - scale: " .. scale)
                if factorized_longit_speed < 0 then factorized_longit_speed = 0 end --lets avoid negative numbers
                if factorized_longit_speed == nil then factorized_longit_speed = longit_speed end --and nil numbers
            end
        end
        --now gets the lift!
        new_accel = airutils.getLiftAccel(self, velocity, new_accel, longit_speed, roll, curr_pos, ju52.lift, 20000, 25)
    end
    -- end lift

    if stop ~= true then
        self._last_accell = new_accel
	    --self.object:move_to(curr_pos)
        --self.object:set_velocity(velocity)
        --[[if player then
            ju52.attach(self, player)
        end]]--
        airutils.set_acceleration(self.object, new_accel)
    elseif stop == true then
        self._last_accell = {x=0, y=0, z=0}
        self.object:set_velocity({x=0,y=0,z=0})
    end
    ------------------------------------------------------
    -- end accell
    ------------------------------------------------------

    ------------------------------------------------------
    -- sound and animation
    ------------------------------------------------------
    ju52.engine_set_sound_and_animation(self)
    ------------------------------------------------------

    --adjust climb indicator
    local climb_rate = velocity.y -- * 1.5
    if climb_rate > 5 then climb_rate = 5 end
    if climb_rate < -5 then
        climb_rate = -5
    end

    --in a command compression during a dive, force the control to recover
    local longit_initial_speed = 10.5
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
    if longit_speed < (ju52.min_speed / 2) and climb_rate < -3 and is_flying then
        --minetest.chat_send_all("speed: "..longit_speed.." - climb: "..climb_rate)
        self._elevator_angle = 0
        self._angle_of_attack = -2.0
        newpitch = math.rad(self._angle_of_attack)
    else
        newpitch = ju52.tail(self, longit_speed, newpitch)
    end

    --minetest.chat_send_all('rate '.. climb_rate)
    local climb_angle = ju52.get_gauge_angle(climb_rate)

    local indicated_speed = longit_speed
    if indicated_speed < 0 then indicated_speed = 0 end
    local speed_angle = ju52.get_gauge_angle(indicated_speed, -45)
    --adjust power indicator
    local power_indicator_angle = ju52.get_gauge_angle(self._power_lever/10) + 90
    local energy_indicator_angle = ju52.get_gauge_angle((JU52_MAX_FUEL - self._energy)/3) - 90

    if is_attached then
        if self._show_hud then
            ju52.update_hud(player, climb_angle, speed_angle, power_indicator_angle, energy_indicator_angle)
        else
            ju52.remove_hud(player)
        end
    end

    if is_flying == false then --isn't flying?
        -- new yaw
        local turn_rate = math.rad(30)
        local yaw_turn = self.dtime * math.rad(self._rudder_angle) * turn_rate *
                    ju52.sign(longit_speed) * math.abs(longit_speed/2)
	    newyaw = yaw + yaw_turn

        --animate wheels
        self.object:set_animation_frame_speed(longit_speed * 10)
    else
        --stop wheels
        self.object:set_animation_frame_speed(0)
    end

    --apply rotations
	if newyaw~=yaw or newpitch~=pitch or newroll~=roll then
        self.object:set_rotation({x=newpitch,y=newyaw,z=newroll})
    end

    self.object:set_bone_position("speed1", {x=-6.5, y=-40.6, z=16.6}, {x=0, y=-speed_angle, z=0})
    self.object:set_bone_position("speed2", {x=6.5, y=-40.6, z=16.6}, {x=0, y=-speed_angle, z=0})
    self.object:set_bone_position("climber1", {x=-9.5, y=-40.6, z=16.6}, {x=0, y=-(climb_angle-90), z=0})
    self.object:set_bone_position("climber2", {x=3.5, y=-40.6, z=16.6}, {x=0, y=-(climb_angle-90), z=0})
    self.object:set_bone_position("fuel", {x=0, y=-40.6, z=15.35}, {x=0, y=(energy_indicator_angle+180), z=0})
    self.object:set_bone_position("compass", {x=0, y=-40.55, z=18.2}, {x=0, y=(math.deg(newyaw)), z=0})

    local adf = 0
    if self._adf == true then
        if airutils.getAngleFromPositions then
            adf = airutils.getAngleFromPositions(curr_pos, self._adf_destiny)
            adf = (adf + math.deg(newyaw))
            --minetest.chat_send_all(adf)
        else
            minetest.chat_send_player(self.driver_name," >>> Impossible to activate the ADF - the airutils lib is outdated")
        end
    end

    self.object:set_bone_position("compass_plan", {x=0, y=-40.4, z=18.2}, {x=0, y=adf, z=0})

    --altimeters
    local altitude = (curr_pos.y / 0.32) / 100
    local hour, minutes = math.modf( altitude )
    hour = math.fmod (hour, 10)
    minutes = minutes * 100
    minutes = (minutes * 100) / 100
    local minute_angle = (minutes*-360)/100
    local hour_angle = (hour*-360)/10 + ((minute_angle*36)/360)

    self.object:set_bone_position("altimeter_p1_1", {x=-3.5, y=-40.6, z=16.6}, {x=0, y=-(hour_angle), z=0})
    self.object:set_bone_position("altimeter_p2_1", {x=-3.5, y=-41.1, z=16.6}, {x=0, y=-(minute_angle), z=0})

    self.object:set_bone_position("altimeter_p1_2", {x=9.5, y=-40.6, z=16.6}, {x=0, y=-(hour_angle), z=0})
    self.object:set_bone_position("altimeter_p2_2", {x=9.5, y=-41.1, z=16.6}, {x=0, y=-(minute_angle), z=0})

    --power
    local power_angle = ((self._power_lever*1.5)/4.5)
    self.object:set_bone_position("power", {x=1, y=-37.4, z=14}, {x=0, y=-(power_angle - 20), z=90}) --(power_indicator_angle-45)

    --adjust elevator pitch (3d model)
    self.object:set_bone_position("elevator", {x=0, y=77.5, z=23}, {x=-self._elevator_angle*1.2, y=0, z=0})
    self.object:set_bone_position("rudder", {x=0, y=82.1, z=26.4}, {x=1.4, y=180, z=self._rudder_angle})


    if self._wing_configuration == ju52.wing_angle_of_attack and self._flap then
        ju52.flap_on(self)
    end
    if self._wing_configuration ~= ju52.wing_angle_of_attack and self._flap == false then
        ju52.flap_off(self)
    end

    self.object:set_bone_position("aileron_base_r", {x=93.79, y=4.8, z=6.5}, {x=-90, y=174.7, z=-7.4})
    local r_aileron_rotation = {x=0, y=-self._rudder_angle + 90, z=90}
    self.object:set_bone_position("r_aileron", {x=0, y=0, z=0}, r_aileron_rotation)

    self.object:set_bone_position("aileron_base_l", {x=-93.79, y=4.8, z=6.5}, {x=90, y=5.3, z=7.4})
    local l_aileron_rotation = {x=0, y=-self._rudder_angle + 90, z=90}
    self.object:set_bone_position("l_aileron", {x=0, y=0, z=0}, r_aileron_rotation)

    -- calculate energy consumption --
    ju52.consumptionCalc(self, accel)

    --test collision
    ju52.testDamage(self, velocity, curr_pos)

    --saves last velocity for collision detection (abrupt stop)
    self._last_vel = self.object:get_velocity()
end

