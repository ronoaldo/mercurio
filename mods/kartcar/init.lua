--
-- constants
--
minekart={}
minekart.LONGIT_DRAG_FACTOR = 0.16*0.16
minekart.LATER_DRAG_FACTOR = 30.0
minekart.gravity = 9.8
minekart.is_creative = minetest.settings:get_bool("creative_mode", false)

minekart.fuel = {['biofuel:biofuel'] = 1,['biofuel:bottle_fuel'] = 1,
                ['biofuel:phial_fuel'] = 0.25, ['biofuel:fuel_can'] = 10}

--two variables to control sound event
minekart.last_time_collision_snd = 0
minekart.last_time_drift_snd =0
minekart.last_fuel_display =0

--kart colors
minekart.colors ={
    black='#2b2b2b',
    blue='#0063b0',
    brown='#8c5922',
    cyan='#07B6BC',
    dark_green='#567a42',
    dark_grey='#6d6d6d',
    green='#4ee34c',
    grey='#9f9f9f',
    magenta='#ff0098',
    orange='#ff8b0e',
    pink='#ff62c6',
    red='#dc1818',
    violet='#a437ff',
    white='#FFFFFF',
    yellow='#ffe400',
}

dofile(minetest.get_modpath("kartcar") .. DIR_DELIM .. "minekart_forms.lua")
dofile(minetest.get_modpath("kartcar") .. DIR_DELIM .. "minekart_control.lua")
dofile(minetest.get_modpath("kartcar") .. DIR_DELIM .. "minekart_fuel_management.lua")
dofile(minetest.get_modpath("kartcar") .. DIR_DELIM .. "minekart_custom_physics.lua")

--
-- helpers and co.
--

function minekart.get_hipotenuse_value(point1, point2)
    return math.sqrt((point1.x - point2.x) ^ 2 + (point1.y - point2.y) ^ 2 + (point1.z - point2.z) ^ 2)
end

function minekart.dot(v1,v2)
	return (v1.x*v2.x)+(v1.y*v2.y)+(v1.z*v2.z)
end

function minekart.sign(n)
	return n>=0 and 1 or -1
end

function minekart.minmax(v,m)
	return math.min(math.abs(v),m)*minekart.sign(v)
end

--painting
function minekart.paint(self, colstr)
    if colstr then
        self._color = colstr
        local l_textures = self.initial_properties.textures
        for _, texture in ipairs(l_textures) do
            local indx = texture:find('kart_painting.png')
            if indx then
                l_textures[_] = "kart_painting.png^[multiply:".. colstr
            end
        end
	    self.object:set_properties({textures=l_textures})
    end
end

--returns 0 for old, 1 for new
function minekart.detect_player_api(player)
    local player_proterties = player:get_properties()
    local mesh = "character.b3d"
    if player_proterties.mesh == mesh or player_proterties.mesh == "max.b3d" then
        local models = player_api.registered_models
        local character = models[mesh]
        if character then
            if character.animations.sit.eye_height then
                return 1
            else
                return 0
            end
        end
    end

    return 0
end

function minekart.engine_set_sound_and_animation(self, _longit_speed)
    --minetest.chat_send_all('test1 ' .. dump(self._engine_running) )
    if self.sound_handle then
        if (math.abs(self._longit_speed) > math.abs(_longit_speed) + 0.08) or (math.abs(self._longit_speed) + 0.08 < math.abs(_longit_speed)) then
            --minetest.chat_send_all('test2')
            minekart.engineSoundPlay(self)
        end
    end
end

function minekart.engineSoundPlay(self)
    --sound
    if self.sound_handle then minetest.sound_stop(self.sound_handle) end
    if self.object then
        self.sound_handle = minetest.sound_play({name = "engine"},
            {object = self.object, gain = 0.5,
                pitch = 0.6 + ((self._longit_speed/10)/2),
                max_hear_distance = 10,
                loop = true,})
    end
end

-- destroy the kart
function minekart.destroy(self, puncher)
    if self.sound_handle then
        minetest.sound_stop(self.sound_handle)
        self.sound_handle = nil
    end

    if self.driver_name then
        -- detach the driver first (puncher must be driver)
        if puncher then
            puncher:set_detach()
            puncher:set_eye_offset({x = 0, y = 0, z = 0}, {x = 0, y = 0, z = 0})
        end
        if minetest.global_exists("player_api") then
            player_api.player_attached[self.driver_name] = nil
            -- player should stand again
            if puncher then player_api.set_animation(puncher, "stand") end
        end
        self.driver_name = nil
    end

    local pos = self.object:get_pos()
    if self.l_wheel then self.l_wheel:remove() end
    if self.r_wheel then self.r_wheel:remove() end
    if self.steering_base then self.steering_base:remove() end
    if self.steering_axis then self.steering_axis:remove() end
    if self.steering then self.steering:remove() end
    if self.dir_bar then self.dir_bar:remove() end

    local lua_ent = self.object:get_luaentity()
    local staticdata = lua_ent:get_staticdata(self)
    local obj_name = lua_ent.name

    local stack = ItemStack(obj_name)
    local stack_meta = stack:get_meta()
    stack_meta:set_string("staticdata", staticdata)

    if puncher then
        local inv = puncher:get_inventory()
        if inv then
            if inv:room_for_item("main", stack) then
                inv:add_item("main", stack)
            else
                minetest.add_item({x=pos.x+math.random()-0.5,y=pos.y,z=pos.z+math.random()-0.5}, stack)
            end
        end
    else
        minetest.add_item({x=pos.x+math.random()-0.5,y=pos.y,z=pos.z+math.random()-0.5}, stack)
    end

    self.object:remove()

    --[[pos.y=pos.y+2

    minetest.add_item({x=pos.x+math.random()-0.5,y=pos.y,z=pos.z+math.random()-0.5},'kartcar:kart')]]--
end


--
-- entity
--

minetest.register_entity('kartcar:left_wheel',{
initial_properties = {
	physical = false,
	collide_with_objects=false,
	pointable=false,
	visual = "mesh",
	mesh = "kart_left_wheel.b3d",
	textures = {"kart_black.png", "kart_black.png", "kart_metal.png",},
	},
	
    on_activate = function(self,std)
	    self.sdata = minetest.deserialize(std) or {}
	    if self.sdata.remove then self.object:remove() end
    end,
	    
    get_staticdata=function(self)
      self.sdata.remove=true
      return minetest.serialize(self.sdata)
    end,
	
})

minetest.register_entity('kartcar:right_wheel',{
initial_properties = {
	physical = false,
	collide_with_objects=false,
	pointable=false,
	visual = "mesh",
	mesh = "kart_right_wheel.b3d",
	textures = {"kart_black.png", "kart_black.png", "kart_metal.png",},
	},
	
    on_activate = function(self,std)
	    self.sdata = minetest.deserialize(std) or {}
	    if self.sdata.remove then self.object:remove() end
    end,
	    
    get_staticdata=function(self)
      self.sdata.remove=true
      return minetest.serialize(self.sdata)
    end,
	
})

minetest.register_entity('kartcar:steering_wheel_axis',{
initial_properties = {
	physical = false,
	collide_with_objects=false,
	pointable=false,
	visual = "mesh",
	mesh = "kart_steering_base.b3d",
    textures = {"kart_black.png",},
	},
	
    on_activate = function(self,std)
	    self.sdata = minetest.deserialize(std) or {}
	    if self.sdata.remove then self.object:remove() end
    end,
	    
    get_staticdata=function(self)
      self.sdata.remove=true
      return minetest.serialize(self.sdata)
    end,
	
})

minetest.register_entity('kartcar:steering_wheel',{
initial_properties = {
	physical = false,
	collide_with_objects=false,
	pointable=false,
	visual = "mesh",
	mesh = "kart_steering.b3d",
    textures = {"kart_u_black.png",},
	},
	
    on_activate = function(self,std)
	    self.sdata = minetest.deserialize(std) or {}
	    if self.sdata.remove then self.object:remove() end
    end,
	    
    get_staticdata=function(self)
      self.sdata.remove=true
      return minetest.serialize(self.sdata)
    end,
	
})

minetest.register_entity('kartcar:dir_bar',{
initial_properties = {
	physical = false,
	collide_with_objects=false,
	pointable=false,
	visual = "mesh",
	mesh = "kart_dir_bar.b3d",
    textures = {"kart_black.png",},
	},

    on_activate = function(self,std)
	    self.sdata = minetest.deserialize(std) or {}
	    if self.sdata.remove then self.object:remove() end
    end,
	    
    get_staticdata=function(self)
      self.sdata.remove=true
      return minetest.serialize(self.sdata)
    end,
	
})

minetest.register_entity("kartcar:kart", {
	initial_properties = {
	    physical = true,
        collide_with_objects = true,
	    collisionbox = {-0.6, 0.0, -0.6, 0.6, 1, 0.6},
	    selectionbox = {-0.8, 0.0, -0.8, 0.8, 0.1, 0.8},
        stepheight = 0.5,
	    visual = "mesh",
	    mesh = "kart_body.b3d",
        textures = {"kart_black.png", "kart_painting.png", "kart_painting.png",
            "kart_red.png", "kart_black.png", "kart_white.png", "kart_black.png",
            "kart_black.png", "kart_black.png", "kart_black.png", "kart_metal.png",
            "kart_black.png", "kart_black.png", "kart_metal.png", "kart_black.png", "kart_metal.png",},
    },
    textures = {},
	driver_name = nil,
	sound_handle = nil,
    owner = "",
    static_save = true,
    infotext = "A very nice kart!",
    hp = 50,
    buoyancy = 2,
    physics = minekart.physics,
    lastvelocity = vector.new(),
    time_total = 0,
    _color = "#FFFFFF",
    _steering_angle = 0,
    _engine_running = false,
    _last_checkpoint = "",
    _total_laps = -1,
    _race_id = "",
    _energy = 1,
    _longit_speed = 0,
    _intensity = 4,

    get_staticdata = function(self) -- unloaded/unloads ... is now saved
        return minetest.serialize({
            stored_owner = self.owner,
            stored_hp = self.hp,
            stored_color = self._color,
            stored_steering = self._steering_angle,
            stored_energy = self._energy,
            --race data
            stored_last_checkpoint = self._last_checkpoint,
            stored_total_laps = self._total_laps,
            stored_race_id = self._race_id,
        })
    end,

	on_activate = function(self, staticdata, dtime_s)
        if staticdata ~= "" and staticdata ~= nil then
            local data = minetest.deserialize(staticdata) or {}
            self.owner = data.stored_owner
            self.hp = data.stored_hp
            self._color = data.stored_color
            self._steering_angle = data.stored_steering
            self._energy = data.stored_energy
            --minetest.debug("loaded: ", self.energy)
            --race data
            self._last_checkpoint = data.stored_last_checkpoint
            self._total_laps = data.stored_total_laps
            self._race_id = data.stored_race_id
        end

        self.object:set_animation({x = 1, y = 8}, 0, 0, true)

        minekart.paint(self, self._color)
        local pos = self.object:get_pos()

	    local l_wheel=minetest.add_entity(pos,'kartcar:left_wheel')
	    l_wheel:set_attach(self.object,'',{x=-6,y=2.1,z=10.7},{x=0,y=0,z=0})
		-- set the animation once and later only change the speed
        l_wheel:set_animation({x = 1, y = 8}, 0, 0, true)
	    self.l_wheel = l_wheel

	    local r_wheel=minetest.add_entity(pos,'kartcar:right_wheel')
	    r_wheel:set_attach(self.object,'',{x=6,y=2.1,z=10.7},{x=0,y=0,z=0})
		-- set the animation once and later only change the speed
        r_wheel:set_animation({x = 1, y = 8}, 0, 0, true)
	    self.r_wheel = r_wheel

        local steering_axis=minetest.add_entity(pos,'kartcar:steering_wheel_axis')
        steering_axis:set_attach(self.object,'',{x=0,y=7.49,z=7},{x=45,y=0,z=0})
	    self.steering_axis = steering_axis

	    local steering=minetest.add_entity(self.steering_axis:get_pos(),'kartcar:steering_wheel')
        steering:set_attach(self.steering_axis,'',{x=0,y=0,z=0},{x=0,y=0,z=0})
	    self.steering = steering

        local dir_bar=minetest.add_entity(self.object:get_pos(),'kartcar:dir_bar')
	    dir_bar:set_attach(self.object,'',{x=0,y=0,z=-4},{x=0,y=0,z=0})
	    self.dir_bar = dir_bar

		self.object:set_armor_groups({immortal=1})

        mobkit.actfunc(self, staticdata, dtime_s)
	end,

	on_step = function(self, dtime)
        mobkit.stepfunc(self, dtime)
        --[[sound play control]]--
        minekart.last_time_collision_snd = minekart.last_time_collision_snd + dtime
        if minekart.last_time_collision_snd > 1 then minekart.last_time_collision_snd = 1 end
        minekart.last_time_drift_snd = minekart.last_time_drift_snd + dtime
        if minekart.last_time_drift_snd > 1 then minekart.last_time_drift_snd = 1 end
        --[[end sound control]]--

        local rotation = self.object:get_rotation()
        local yaw = rotation.y
		local newyaw=yaw
        local pitch = rotation.x

        local hull_direction = minetest.yaw_to_dir(yaw)
        local nhdir = {x=hull_direction.z,y=0,z=-hull_direction.x}		-- lateral unit vector
        local velocity = self.object:get_velocity()

        local longit_speed = minekart.dot(velocity,hull_direction)
        local fuel_weight_factor = (5 - self._energy)/5000
        local longit_drag = vector.multiply(hull_direction,(longit_speed*longit_speed) *
            (minekart.LONGIT_DRAG_FACTOR - fuel_weight_factor) * -1 * minekart.sign(longit_speed))
        
		local later_speed = minekart.dot(velocity,nhdir)
        local later_drag = vector.multiply(nhdir,later_speed*
            later_speed*minekart.LATER_DRAG_FACTOR*-1*minekart.sign(later_speed))

        local accel = vector.add(longit_drag,later_drag)

        local player = nil
        local is_attached = false
        if self.driver_name then
            player = minetest.get_player_by_name(self.driver_name)
            
            if player then
                local player_attach = player:get_attach()
                if player_attach then
                    if player_attach == self.object then is_attached = true end
                end

                --reload fuel at refuel point
                ------------------------------
                if self._energy < 1 then
                    local speed = minekart.get_hipotenuse_value(vector.new(), self.lastvelocity)
                    local pos = self.object:get_pos()
                    if minetest.find_node_near(pos, 5, {"checkpoints:refuel"}) ~= nil and
                            self._engine_running == false and speed <= 0.1 then
                        minekart.loadFuel(self, self.driver_name, true)
                    end
                end
            end
        end

		if is_attached then --and self.driver_name == self.owner then
            local curr_pos = self.object:get_pos()
            local impact = minekart.get_hipotenuse_value(velocity, self.lastvelocity)
            if impact > 1 then
                --self.damage = self.damage + impact --sum the impact value directly to damage meter
                if minekart.last_time_collision_snd > 0.3 then
                    minekart.last_time_collision_snd = 0
                    minetest.sound_play("collision", {
                        to_player = self.driver_name,
	                    --pos = curr_pos,
	                    --max_hear_distance = 5,
	                    gain = 1.0,
                        fade = 0.0,
                        pitch = 1.0,
                    })
                end
                --[[if self.damage > 100 then --if acumulated damage is greater than 100, adieu
                    minekart.destroy(self)
                end]]--
            end

            local min_later_speed = 1.5
            if (later_speed > min_later_speed or later_speed < -min_later_speed) and
                    minekart.last_time_drift_snd > 0.6 then
                minekart.last_time_drift_snd = 0
                minetest.sound_play("drifting", {
                    to_player = self.driver_name,
                    pos = curr_pos,
                    max_hear_distance = 5,
                    gain = 1.0,
                    fade = 0.0,
                    pitch = 1.0,
                    ephemeral = true,
                })
            end

            --control
			accel = minekart.kart_control(self, dtime, hull_direction, longit_speed, longit_drag, later_drag, accel)
        else
            if self.sound_handle ~= nil then
	            minetest.sound_stop(self.sound_handle)
	            self.sound_handle = nil
            end
		end

        local angle_factor = self._steering_angle / 10
        self.object:set_animation_frame_speed(longit_speed * 10)
        self.l_wheel:set_animation_frame_speed(longit_speed * (10 - angle_factor))
        self.r_wheel:set_animation_frame_speed(longit_speed * (10 + angle_factor))

        self.steering:set_attach(self.steering_axis,'',{x=0,y=0,z=0},{x=0,y=0,z=self._steering_angle*2})
        self.l_wheel:set_attach(self.object,'',{x=-6,y=2.1,z=10.7},{x=0,y=-self._steering_angle,z=0})
        self.dir_bar:set_attach(self.object,'',{x=(-1*(self._steering_angle / 25)),y=0,z=-4},{x=0,y=0,z=0})
        self.r_wheel:set_attach(self.object,'',{x= 6,y=2.1,z=10.7},{x=0,y=-self._steering_angle,z=0})

		if math.abs(self._steering_angle)>5 then
            local turn_rate = math.rad(60)
			newyaw = yaw + dtime*(1 - 1 / (math.abs(longit_speed) + 1)) *
                self._steering_angle / 30 * turn_rate * minekart.sign(longit_speed)
		end

        --[[if player and is_attached then
            player:set_look_horizontal(newyaw)
        end]]--

		local newpitch = velocity.y * math.rad(6)

        --[[
        accell correction
        under some circunstances the acceleration exceeds the max value accepted by set_acceleration and
        the game crashes with an overflow, so limiting the max acceleration in each axis prevents the crash
        ]]--
        local max_factor = 25
        local acc_adjusted = 10
        if accel.x > max_factor then accel.x = acc_adjusted end
        if accel.x < -max_factor then accel.x = -acc_adjusted end
        if accel.z > max_factor then accel.z = acc_adjusted end
        if accel.z < -max_factor then accel.z = -acc_adjusted end
        -- end correction
        accel.y = -minekart.gravity

        minekart.engine_set_sound_and_animation(self, longit_speed)

        self.object:set_acceleration(accel)
        self._longit_speed = longit_speed

		if newyaw~=yaw or newpitch~=pitch then self.object:set_rotation({x=newpitch,y=newyaw,z=0}) end

        --saves last velocity for collision detection (abrupt stop)
        self.lastvelocity = self.object:get_velocity()

        -- calculate energy consumption --
        ----------------------------------
        if self._energy > 0 and self._engine_running and not minekart.is_creative then
            local zero_reference = vector.new()
            local acceleration = minekart.get_hipotenuse_value(accel, zero_reference)
            local consumed_power = acceleration/200000
            self._energy = self._energy - consumed_power;

            --report fuel
            if self._energy < 0.75 and minekart.last_fuel_display == 0 then
                minekart.last_fuel_display = 50
                minetest.chat_send_player(self.driver_name, "fuel now bellow 75%")
            end
            if self._energy < 0.5 and minekart.last_fuel_display == 50 then
                minekart.last_fuel_display = 25
                minetest.chat_send_player(self.driver_name, "fuel now bellow 50%")
            end
            if self._energy < 0.25 and minekart.last_fuel_display == 25 then
                minekart.last_fuel_display = 10
                minetest.chat_send_player(self.driver_name, "fuel now bellow 25%")
            end
            if self._energy < 0.1 and minekart.last_fuel_display == 10 then
                minekart.last_fuel_display = 0
                minetest.chat_send_player(self.driver_name, "Danger! Fuel now bellow 10%")
            end
        end
        if self._energy <= 0 and self._engine_running then
            self._engine_running = false
            if self.sound_handle then minetest.sound_stop(self.sound_handle) end
            minetest.chat_send_player(self.driver_name, "Out of fuel")
        end
        ----------------------------
        -- end energy consumption --
	end,

	on_punch = function(self, puncher, ttime, toolcaps, dir, damage)
		if not puncher or not puncher:is_player() then
			return
		end

		local name = puncher:get_player_name()
        --[[if self.owner and self.owner ~= name and self.owner ~= "" then return end]]--
        if self.owner == nil then
            self.owner = name
        end
        	
        if self.driver_name and self.driver_name ~= name then
			-- do not allow other players to remove the object while there is a driver
			return
		end
        
        local is_attached = false
        if puncher:get_attach() == self.object then is_attached = true end

        local itmstck=puncher:get_wielded_item()
        local item_name = ""
        if itmstck then item_name = itmstck:get_name() end

        --refuel procedure
        --[[
        refuel works it car is stopped and engine is off
        ]]--
        local velocity = self.object:get_velocity()
        local speed = minekart.get_hipotenuse_value(vector.new(), velocity)
        if self._engine_running == false and speed <= 0.1 then
            if minekart.loadFuel(self, puncher:get_player_name()) then return end
        end
        -- end refuel

        if is_attached == false then

            -- deal with painting or destroying
		    if itmstck then
                --race status restart
                if item_name == "checkpoints:status_restarter" and self._engine_running == false then
                    --restart race current status
                    self._last_checkpoint = ""
                    self._total_laps = -1
                    self._race_id = ""
                    return
                end

                --painting
                local split = string.split(item_name, ":")
                local color, indx, _
                if split[1] then _,indx = split[1]:find('dye') end
                if indx then
                    for clr,_ in pairs(minekart.colors) do
                        local _,x = split[2]:find(clr)
                        if x then color = clr end
                    end
                else
                    color = false
                end
                    
			    if color then

                    --lets paint!!!!
				    --local color = item_name:sub(indx+1)
				    local colstr = minekart.colors[color]
                    --minetest.chat_send_all(color ..' '.. dump(colstr))
				    if colstr then
                        minekart.paint(self, colstr)
					    itmstck:set_count(itmstck:get_count()-1)
					    puncher:set_wielded_item(itmstck)
				    end
                    -- end painting

			    else -- deal damage

                    local is_admin = false
                    is_admin = minetest.check_player_privs(puncher, {server=true})
                    --minetest.chat_send_all('owner '.. self.owner ..' - name '.. name)
				    if not self.driver and (self.owner == name or is_admin == true) and toolcaps and
                            toolcaps.damage_groups and toolcaps.damage_groups.fleshy then
                        self.hp = self.hp - 10
                        minetest.sound_play("collision", {
	                        object = self.object,
	                        max_hear_distance = 5,
	                        gain = 1.0,
                            fade = 0.0,
                            pitch = 1.0,
                        })
				    end
			    end
            end

            if self.hp <= 0 then
                minekart.destroy(self, puncher)
            end

        end
        
	end,

	on_rightclick = function(self, clicker)
		if not clicker or not clicker:is_player() then
			return
		end

		local name = clicker:get_player_name()
        --[[if self.owner and self.owner ~= name and self.owner ~= "" then return end]]--
        if self.owner == "" then
            self.owner = name
        end

		if name == self.driver_name then
            minekart.driver_formspec(name)
       
		elseif not self.driver_name then
	        -- no driver => clicker is new driver
	        self.driver_name = name

            -- temporary------
            self.hp = 50 -- why? cause I can desist from destroy
            ------------------

	        -- attach the driver
	        clicker:set_attach(self.object, "", {x = 0, y = 3, z = 2}, {x = 0, y = 0, z = 0})
            local eye_y = 0
            if minekart.detect_player_api(clicker) == 1 then
                eye_y = 4.5
            end

	        clicker:set_eye_offset({x = 0, y = eye_y, z = 2.5}, {x = 0, y = eye_y, z = -14})
            if minetest.global_exists("player_api") then
	            player_api.player_attached[name] = true
            end
            player_api.set_animation(clicker, "sit")

	        -- make the driver sit
	        minetest.after(0.2, function()
		        local player = minetest.get_player_by_name(name)
		        if player and minetest.global_exists("player_api") then
                    local speed = 30.01
                    local mesh = player:get_properties().mesh
                    if mesh then
                        local character = player_api.registered_models[mesh]
                        if character and character.animation_speed then
                            speed = character.animation_speed + 0.01
                        end
                    end
                    player_api.set_animation(player, "sit", speed)
				    self._engine_running = true
		            -- sound and animation
	                self.sound_handle = minetest.sound_play({name = "engine"},
			                {object = self.object, gain = 2.0, pitch = 0.5, max_hear_distance = 32, loop = true,})

		        end
	        end)
	        self.object:set_acceleration(vector.multiply(minekart.vector_up, -minekart.gravity))
		end
	end,
})

--
-- items
--

-- Kart
--[[minetest.register_craftitem("kartcar:kart", {
	description = "Kart",
	inventory_image = "kart_inv.png",
    liquids_pointable = false,]]--

-- boat
minetest.register_tool("kartcar:kart", {
	description = "Kart",
	inventory_image = "kart_inv.png",
    liquids_pointable = false,
    stack_max = 1,

	on_place = function(itemstack, placer, pointed_thing)
		if pointed_thing.type ~= "node" then
			return
		end

        local stack_meta = itemstack:get_meta()
        local staticdata = stack_meta:get_string("staticdata")
        
        local pointed_pos = pointed_thing.above
		--pointed_pos.y=pointed_pos.y+0.2
		local kart = minetest.add_entity(pointed_pos, "kartcar:kart", staticdata)
		if kart and placer then
            local ent = kart:get_luaentity()
            local owner = placer:get_player_name()
            ent.owner = owner
            ent.hp = 50
			kart:set_yaw(placer:get_look_horizontal())
			itemstack:take_item()
            ent.object:set_acceleration({x=0,y=-minekart.gravity,z=0})
		end

		return itemstack
	end,
})

--
-- crafting
--

if minetest.get_modpath("default") then
	minetest.register_craft({
		output = "kartcar:kart",
		recipe = {
			{"default:obsidian_block", "default:steel_ingot", "default:obsidian_block"},
			{"default:steel_ingot",    "default:mese_block",  "default:steel_ingot"},
			{"default:obsidian_block", "default:steel_ingot", "default:obsidian_block"},
		}
	})
end


