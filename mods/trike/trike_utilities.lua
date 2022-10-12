dofile(minetest.get_modpath("trike") .. DIR_DELIM .. "trike_global_definitions.lua")

function trike.get_hipotenuse_value(point1, point2)
    return math.sqrt((point1.x - point2.x) ^ 2 + (point1.y - point2.y) ^ 2 + (point1.z - point2.z) ^ 2)
end

function trike.dot(v1,v2)
	return v1.x*v2.x+v1.y*v2.y+v1.z*v2.z
end

function trike.sign(n)
	return n>=0 and 1 or -1
end

function trike.minmax(v,m)
	return math.min(math.abs(v),m)*trike.sign(v)
end

function trike.get_gauge_angle(value)
    local angle = value * 18
    angle = angle - 90
    angle = angle * -1
	return angle
end

-- attach player
function trike.attach(self, player)
    local name = player:get_player_name()
    self.driver_name = name

    -- attach the driver
    player:set_attach(self.pilot_seat_base, "", {x = 0, y = 0, z = 0}, {x = 0, y = 0, z = 0})
    local eye_y = -6
    if airutils.detect_player_api(player) == 1 then
        eye_y = 0.5
    end
    player:set_eye_offset({x = 0, y = eye_y, z = 2}, {x = 0, y = 1, z = -30})
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

-- attach passenger
function trike.attach_pax(self, player)
    local name = player:get_player_name()
    self._passenger = name

    -- attach the driver
    player:set_attach(self.passenger_seat_base, "", {x = 0, y = 0, z = 0}, {x = 0, y = 0, z = 0})
    local eye_y = -3
    if airutils.detect_player_api(player) == 1 then
        eye_y = 3.5
    end
    player:set_eye_offset({x = 0, y = eye_y, z = 3}, {x = 0, y = 3, z = -30})
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

function trike.dettachPlayer(self, player)
    local name = self.driver_name
    airutils.setText(self,"ultralight trike")

    trike.remove_hud(player)
    self._engine_running = false

    -- driver clicked the object => driver gets off the vehicle
    self.driver_name = nil
    -- sound and animation
    if self.sound_handle then
        minetest.sound_stop(self.sound_handle)
        self.sound_handle = nil
    end
    
    self.engine:set_animation_frame_speed(0)

    -- detach the player
    if player then
        player:set_detach()
        player_api.player_attached[name] = nil
        player:set_eye_offset({x=0,y=0,z=0},{x=0,y=0,z=0})
        player_api.set_animation(player, "stand")
    end
    self.driver = nil
    --remove_physics_override(player, {speed=1,gravity=1,jump=1})
end

function trike.dettach_pax(self, player)
    local name = self._passenger

    -- passenger clicked the object => driver gets off the vehicle
    self._passenger = nil

    -- detach the player
    if player then
        player:set_detach()
        player_api.player_attached[name] = nil
        player_api.set_animation(player, "stand")
        player:set_eye_offset({x=0,y=0,z=0},{x=0,y=0,z=0})
        --remove_physics_override(player, {speed=1,gravity=1,jump=1})
    end
end

function trike.checkAttach(self, player)
    if player then
        local player_attach = player:get_attach()
        if player_attach then
            if player_attach == self.pilot_seat_base then
                return true
            end
        end
    end
    return false
end

-- destroy the boat
function trike.destroy(self)
    if self.sound_handle then
        minetest.sound_stop(self.sound_handle)
        self.sound_handle = nil
    end

    if self._passenger then
        -- detach the passenger
        local passenger = minetest.get_player_by_name(self._passenger)
        if passenger then
            trike.dettach_pax(self, passenger)
        end
    end

    if self.driver_name then
        -- detach the driver
        local player = minetest.get_player_by_name(self.driver_name)
        trike.dettachPlayer(self, player)
    end

    local pos = self.object:get_pos()
    if self.fuel_gauge then self.fuel_gauge:remove() end
    if self.power_gauge then self.power_gauge:remove() end
    if self.climb_gauge then self.climb_gauge:remove() end
    if self.engine then self.engine:remove() end
    if self.wheel then self.wheel:remove() end
    if self.pilot_seat_base then self.pilot_seat_base:remove() end
    if self.passenger_seat_base then self.passenger_seat_base:remove() end

    airutils.destroy_inventory(self)
    self.object:remove()

    pos.y=pos.y+2
    minetest.add_item({x=pos.x+math.random()-0.5,y=pos.y,z=pos.z+math.random()-0.5},'trike:wing')

    for i=1,6 do
	    minetest.add_item({x=pos.x+math.random()-0.5,y=pos.y,z=pos.z+math.random()-0.5},'default:mese_crystal')
        minetest.add_item({x=pos.x+math.random()-0.5,y=pos.y,z=pos.z+math.random()-0.5},'default:diamond')
    end

    for i=1,3 do
	    minetest.add_item({x=pos.x+math.random()-0.5,y=pos.y,z=pos.z+math.random()-0.5},'default:steel_ingot')
    end

    --minetest.add_item({x=pos.x+math.random()-0.5,y=pos.y,z=pos.z+math.random()-0.5},'trike:trike')

    --local total_biofuel = math.floor(self._energy) - 1
    --for i=0,total_biofuel do
        --minetest.add_item({x=pos.x+math.random()-0.5,y=pos.y,z=pos.z+math.random()-0.5},'biofuel:biofuel')
    --end
end

function trike.check_node_below(obj)
    local pos_below = obj:get_pos()
    if pos_below then
        pos_below.y = pos_below.y - 0.1
        local node_below = minetest.get_node(pos_below).name
        local nodedef = minetest.registered_nodes[node_below]
        local touching_ground = not nodedef or -- unknown nodes are solid
		        nodedef.walkable or false
        local liquid_below = not touching_ground and nodedef.liquidtype ~= "none"
        return touching_ground, liquid_below
    end
    return nil, nil
end

function trike.testImpact(self, velocity)
    local p = self.object:get_pos()
    local collision = false
    if self.lastvelocity == nil then return end
    --lets calculate the vertical speed, to avoid the bug on colliding on floor with hard lag
    if abs(velocity.y - self.lastvelocity.y) > 2 then
		local noded = airutils.nodeatpos(airutils.pos_shift(p,{y=-1}))
	    if (noded and noded.drawtype ~= 'airlike') then
		    collision = true
	    else
            self.object:set_velocity(self.lastvelocity)
            self.object:set_acceleration(self._last_accell)
        end
    end
    local impact = abs(trike.get_hipotenuse_value(velocity, self.lastvelocity))
    if impact > 2 then
        --minetest.chat_send_all('impact: '.. impact .. ' - hp: ' .. self.hp_max)
        if self.colinfo then
            collision = self.colinfo.collides
        end
    end

    if impact > 0.5  and self._longit_speed > 2 then
        local noded = airutils.nodeatpos(airutils.pos_shift(p,{y=-0.1}))
	    if (noded and noded.drawtype ~= 'airlike') then
            minetest.sound_play("trike_touch", {
                --to_player = self.driver_name,
                object = self.object,
                max_hear_distance = 15,
                gain = 1.0,
                fade = 0.0,
                pitch = 1.0,
            }, true)
	    end
    end

    if collision then
        --self.object:set_velocity({x=0,y=0,z=0})
        local damage = impact / 2
        self.hp_max = self.hp_max - damage --subtract the impact value directly to hp meter

        if self.driver_name then
            minetest.sound_play("trike_collision", {
                to_player = self.driver_name,
                --pos = curr_pos,
                --max_hear_distance = 5,
                gain = 1.0,
                fade = 0.0,
                pitch = 1.0,
            })

            local player_name = self.driver_name
            airutils.setText(self,"ultralight trike")

            --minetest.chat_send_all('damage: '.. damage .. ' - hp: ' .. self.hp_max)
            if self.hp_max < 0 then --if acumulated damage is greater than 50, adieu
                trike.destroy(self)
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

function trike.checkattachBug(self)
    -- for some engine error the player can be detached from the submarine, so lets set him attached again
    local can_stop = true
    if self.owner and self.driver_name then
        -- attach the driver again
        local player = minetest.get_player_by_name(self.owner)
        if player then
		    if player:get_hp() > 0 then
                trike.attach(self, player)
                can_stop = false
            else
                trike.dettachPlayer(self, player)
		    end
        end
    end

    if can_stop then
        --detach player
        if self.sound_handle ~= nil then
            minetest.sound_stop(self.sound_handle)
            self.sound_handle = nil
        end
    end
end

function trike.flightstep(self)
    local accel_y = self.object:get_acceleration().y
    local rotation = self.object:get_rotation()
    local yaw = rotation.y
	local newyaw=yaw
    local pitch = rotation.x
	local roll = rotation.z

    local velocity = self.object:get_velocity()
    --self.object:set_velocity(velocity) --hack to avoid glitches
    local hull_direction = airutils.rot_to_dir(rotation) --minetest.yaw_to_dir(yaw)
    local nhdir = {x=hull_direction.z,y=0,z=-hull_direction.x}		-- lateral unit vector

    local longit_speed = vector.dot(velocity,hull_direction)
    self._longit_speed = longit_speed
    local longit_drag = vector.multiply(hull_direction,longit_speed*longit_speed*LONGIT_DRAG_FACTOR*
                            -1*trike.sign(longit_speed))
	local later_speed = trike.dot(velocity,nhdir)
    --minetest.chat_send_all('later_speed: '.. later_speed)
	local later_drag = vector.multiply(nhdir,later_speed*later_speed*LATER_DRAG_FACTOR*-1*trike.sign(later_speed))
    local accel = vector.add(longit_drag,later_drag)
    local stop = false

    local player = nil
    if self.driver_name then player = minetest.get_player_by_name(self.driver_name) end

    local curr_pos = self.object:get_pos()
    self.object:move_to(curr_pos)

    local node_bellow = airutils.nodeatpos(airutils.pos_shift(curr_pos,{y=-1}))
    local is_flying = true
    if self.colinfo then
        is_flying = not self.colinfo.touching_ground
    end

    local is_attached = trike.checkAttach(self, player)

	if not is_attached then
        -- for some engine error the player can be detached from the machine, so lets set him attached again
        trike.checkattachBug(self)
    end

    if longit_speed == 0 and is_flying == false and is_attached == false and self._engine_running == false then
        return
    end

	if is_attached then
        --control
		accel, stop = trike.control(self, self.dtime, hull_direction,
            longit_speed, longit_drag, later_speed, later_drag, accel, player, is_flying)
	end
    trike.testImpact(self, velocity)

    -- new yaw
	if math.abs(self._rudder_angle)>5 then
        local turn_rate = math.rad(24)
		newyaw = yaw + self.dtime*(1 - 1 / (math.abs(longit_speed) + 1)) *
            self._rudder_angle / 30 * turn_rate * trike.sign(longit_speed)
	end

    -- calculate energy consumption --
    trike.consumptionCalc(self, accel)

    --roll adjust
    ---------------------------------
	local sdir = minetest.yaw_to_dir(newyaw)
	local snormal = {x=sdir.z,y=0,z=-sdir.x}	-- rightside, dot is negative
	local prsr = trike.dot(snormal,nhdir)
    local rollfactor = -20
    local newroll = (prsr*math.rad(rollfactor))*(later_speed)
    --minetest.chat_send_all('newroll: '.. newroll)
    ---------------------------------
    -- end roll

    -- pitch
    local newpitch = self._angle_of_attack/200 --(velocity.y * math.rad(6))

    -- adjust pitch by velocity
    if is_flying == false then --isn't flying?
        if newpitch < 0 then newpitch = 0 end
        newroll = 0

        local min_speed = 4
        if longit_speed < min_speed then
            if newpitch > 0 then
                local percentage = ((longit_speed * 100)/min_speed)/100
                newpitch = newpitch * percentage
                if newpitch < 0 then newpitch = 0 end
            end
        end

        --animate wheels
        self.object:set_animation_frame_speed(longit_speed * 10)
        self.wheel:set_animation_frame_speed(longit_speed * 10)
    else
        --stop wheels
        self.object:set_animation_frame_speed(0)
        self.wheel:set_animation_frame_speed(0)
    end
    
    local indicated_speed = longit_speed
    if indicated_speed < 0 then indicated_speed = 0 end
    local speed_angle = trike.get_gauge_angle(indicated_speed, -45)

    --adjust power indicator
    local power_indicator_angle = trike.get_gauge_angle(self._power_lever/10)
    self.power_gauge:set_attach(self.object,'',TRIKE_GAUGE_POWER_POSITION,{x=0,y=0,z=power_indicator_angle})

    --lift calculation
    accel.y = accel.y + airutils.gravity --accel_y
    local new_accel = accel
    if longit_speed > 2 then
        new_accel = airutils.getLiftAccel(self, velocity, new_accel, longit_speed, roll, curr_pos, 14, 2500)
    end

    if self.isinliquid then self._engine_running = false end

    --added accell check to avoid mercurio server problem
    if new_accel then
        if new_accel.x ~= nil and new_accel.y ~= nil and new_accel.z ~= nil then
            self.object:set_acceleration(new_accel)
        end
    end
    -- end lift

    --adjust wing pitch (3d model)
    self.object:set_bone_position("wing", {x=0,y=29,z=0}, {x=-self._angle_of_attack,y=0,z=(self._rudder_angle/3)})

    if is_flying == false then
        -- new yaw
        local turn_rate = math.rad(30)
        local yaw_turn = self.dtime * math.rad(self._rudder_angle) * turn_rate *
                    trike.sign(longit_speed) * math.abs(longit_speed/2)
	    newyaw = yaw + yaw_turn
    end

	if newyaw~=yaw or newpitch~=pitch or newroll~=roll then
        self.object:set_rotation({x=newpitch,y=newyaw,z=newroll})
    end

    
    if stop ~= true then
        self._last_accell = new_accel
    elseif stop == false then
        self.object:set_velocity({x=0,y=0,z=0})
    end

    --adjust climb indicator
    local climb_rate = velocity.y * 1.5
    if climb_rate > 5 then climb_rate = 5 end
    if climb_rate < -5 then climb_rate = -5 end
    --minetest.chat_send_all('rate '.. climb_rate)
    local climb_angle = trike.get_gauge_angle(climb_rate)
    self.climb_gauge:set_attach(self.object,'',TRIKE_GAUGE_CLIMBER_POSITION,{x=0,y=0,z=climb_angle})

    local energy_indicator_angle = trike.get_gauge_angle(self._energy)
    if self.fuel_gauge:get_luaentity() then
        self.fuel_gauge:set_attach(self.object,'',TRIKE_GAUGE_FUEL_POSITION,{x=0,y=0,z=energy_indicator_angle})
    end

    if is_attached then
        if self._show_hud then
            trike.update_hud(player, climb_angle, speed_angle - 130, power_indicator_angle - 270, (energy_indicator_angle*-1)-90)
        else
            trike.remove_hud(player)
        end
    end

    --saves last velocity for collision detection (abrupt stop)
    self.lastvelocity = self.object:get_velocity()
end

