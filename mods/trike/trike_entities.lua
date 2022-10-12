dofile(minetest.get_modpath("trike") .. DIR_DELIM .. "trike_global_definitions.lua")

--
-- entity
--

trike.vector_up = vector.new(0, 1, 0)

minetest.register_entity('trike:engine',{
initial_properties = {
	physical = false,
	collide_with_objects=false,
	pointable=false,
	visual = "mesh",
	mesh = "trike_propeller.b3d",
    --visual_size = {x = 3, y = 3, z = 3},
	textures = {"trike_rotor.png", "trike_black.png",},
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

minetest.register_entity('trike:front_wheel',{
initial_properties = {
	physical = false,
	collide_with_objects=false,
	pointable=false,
	visual = "mesh",
	mesh = "trike_front_wheel.b3d",
    --visual_size = {x = 3, y = 3, z = 3},
	textures = {"trike_metal.png", "trike_black.png", "trike_metal.png",},
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

--
-- fuel
--
minetest.register_entity('trike:pointer',{
initial_properties = {
	physical = false,
	collide_with_objects=false,
	pointable=false,
	visual = "mesh",
	mesh = "pointer.b3d",
    visual_size = {x = 0.4, y = 0.4, z = 0.4},
	textures = {"trike_grey.png"},
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

--
-- seat pivot
--
minetest.register_entity('trike:seat_base',{
initial_properties = {
	physical = false,
	collide_with_objects=false,
	pointable=false,
	visual = "mesh",
	mesh = "trike_seat_base.b3d",
    textures = {"trike_black.png",},
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

minetest.register_entity("trike:trike", {
	initial_properties = {
	    physical = true,
        collide_with_objects = true,
	    collisionbox = {-1.2, 0.0, -1.2, 1.2, 3, 1.2}, --{-1,0,-1, 1,0.3,1},
	    selectionbox = {-2, 0, -2, 2, 1, 2},
	    visual = "mesh",
	    mesh = "trike_body.b3d",
        backface_culling = false,
        stepheight = 0.5,
        textures = {
                        "trike_black.png", --bancos
                        "trike_metal.png", --freios
                        "trike_metal.png", --montante trem
                        "trike_metal.png", --haste trem
                        "trike_metal.png", --suporte asa
                        "trike_metal.png", --haste trem
                        "trike_painting.png", --pintura
                        "trike_grey.png", --motor
                        "trike_white.png", --tanque
                        "trike_black.png", --tampa do tanque
                        "trike_black.png", --carburador
                        "trike_black.png", --escape
                        "trike_grey.png", --interior
                        "trike_metal.png", --estrutura asa
                        "trike_black.png", -- cabos
                        "trike_wing.png", --bordo de fuga
                        "trike_painting.png", --bordo de ataque
                        "trike_panel.png", --painel
                        "trike_black.png", --pneus
                        "trike_metal.png", --rodas
                    }
    },
    textures = {},
	driver_name = nil,
	sound_handle = nil,
    owner = "",
    static_save = true,
    infotext = "A nice ultralight",
    hp_max = 50,
    shaded = true,
    show_on_minimap = true,
    buoyancy = 2,
    physics = trike.physics,
    springiness = 0.3,
    _passenger = nil,
    _color = "#0063b0",
    _rudder_angle = 0,
    _acceleration = 0,
    _engine_running = false,
    _angle_of_attack = 2,
    _power_lever = 0,
    _energy = 0.001,
    _longit_speed = 0,
    _lastrot = {x=0,y=0,z=0},
    _last_accell = {x=0,y=0,z=0},
    _show_hud = false,
    lastvelocity = nil,
    _inv = nil,
    _inv_id = "",

    _change_color = function(self, colstr)
        airutils.paint(self, colstr, "trike_painting.png")
    end,

    get_staticdata = function(self) -- unloaded/unloads ... is now saved
        return minetest.serialize({
            stored_energy = self._energy,
            stored_owner = self.owner,
            stored_hp = self.hp_max,
            stored_color = self._color,
            stored_power_lever = self._power_lever,
            stored_driver_name = self.driver_name,
            stored_inv_id = self._inv_id,
        })
    end,

	on_deactivate = function(self)
        airutils.save_inventory(self)
	end,

	on_activate = function(self, staticdata, dtime_s)
        airutils.actfunc(self, staticdata, dtime_s)
        if staticdata ~= "" and staticdata ~= nil then
            local data = minetest.deserialize(staticdata) or {}
            self._energy = data.stored_energy
            self.owner = data.stored_owner
            self.hp_max = data.stored_hp
            self._color = data.stored_color
            self._power_lever = data.stored_power_lever
            self.driver_name = data.stored_driver_name
            self._inv_id = data.stored_inv_id
            --minetest.debug("loaded: ", self._energy)
        end
        airutils.setText(self, "ultralight trike")
        self.object:set_animation({x = 1, y = 12}, 0, 0, true)

        local pos = self.object:get_pos()

	    local engine=minetest.add_entity(pos,'trike:engine')
	    engine:set_attach(self.object,'',{x=0,y=0,z=0},{x=0,y=0,z=0})
		-- set the animation once and later only change the speed
        engine:set_animation({x = 1, y = 12}, 0, 0, true)
	    self.engine = engine

	    local wheel=minetest.add_entity(pos,'trike:front_wheel')
	    wheel:set_attach(self.object,'',{x=0,y=0,z=0},{x=0,y=0,z=0})
		-- set the animation once and later only change the speed
        wheel:set_animation({x = 1, y = 12}, 0, 0, true)
	    self.wheel = wheel

	    local fuel_gauge=minetest.add_entity(pos,'trike:pointer')
        local energy_indicator_angle = trike.get_gauge_angle(self._energy)
	    fuel_gauge:set_attach(self.object,'',TRIKE_GAUGE_FUEL_POSITION,{x=0,y=0,z=energy_indicator_angle})
	    self.fuel_gauge = fuel_gauge

	    local power_gauge=minetest.add_entity(pos,'trike:pointer')
        local power_indicator_angle = trike.get_gauge_angle(self._power_lever)
	    power_gauge:set_attach(self.object,'',TRIKE_GAUGE_POWER_POSITION,{x=0,y=0,z=power_indicator_angle})
	    self.power_gauge = power_gauge

	    local climb_gauge=minetest.add_entity(pos,'trike:pointer')
        local climb_angle = trike.get_gauge_angle(0)
	    climb_gauge:set_attach(self.object,'',TRIKE_GAUGE_CLIMBER_POSITION,{x=0,y=0,z=climb_angle})
	    self.climb_gauge = climb_gauge

        local pilot_seat_base=minetest.add_entity(pos,'trike:seat_base')
        pilot_seat_base:set_attach(self.object,'',{x=0,y=7,z=8},{x=0,y=0,z=0})
	    self.pilot_seat_base = pilot_seat_base

        local passenger_seat_base=minetest.add_entity(pos,'trike:seat_base')
        passenger_seat_base:set_attach(self.object,'',{x=0,y=9,z=1.6},{x=0,y=0,z=0})
	    self.passenger_seat_base = passenger_seat_base

        airutils.paint(self, self._color, "trike_painting.png")

		self.object:set_armor_groups({immortal=1})

		local inv = minetest.get_inventory({type = "detached", name = self._inv_id})
		-- if the game was closed the inventories have to be made anew, instead of just reattached
		if not inv then
            airutils.create_inventory(self, trike.trunk_slots)
		else
		    self.inv = inv
        end
	end,

    --on_step = airutils.stepfunc,
    on_step = function(self,dtime,colinfo)
	    self.dtime = math.min(dtime,0.2)
	    self.colinfo = colinfo
	    self.height = airutils.get_box_height(self)
	    
    --  physics comes first
	    local vel = self.object:get_velocity()
	    
	    if colinfo then 
		    self.isonground = colinfo.touching_ground
	    else
		    if self.lastvelocity.y==0 and vel.y==0 then
			    self.isonground = true
		    else
			    self.isonground = false
		    end
	    end
	    
	    self:physics()

	    if self.logic then
		    self:logic()
	    end
	    
	    self.lastvelocity = self.object:get_velocity()
	    self.time_total=self.time_total+self.dtime
    end,

    logic = trike.flightstep,

	on_punch = function(self, puncher, ttime, toolcaps, dir, damage)
		if not puncher or not puncher:is_player() then
			return
		end
        local is_admin = false
        is_admin = minetest.check_player_privs(puncher, {server=true})
		local name = puncher:get_player_name()
        if self.owner and self.owner ~= name and self.owner ~= "" then
            if is_admin == false then return end
        end
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

        if is_attached == false then
            if trike.loadFuel(self, puncher:get_player_name()) then
                return
            end

            --repair
            if item_name == "airutils:repair_tool" and self._engine_running == false  then
                if self.hp_max < 50 then
                    local inventory_item = "default:steel_ingot"
                    local inv = puncher:get_inventory()
                    if inv:contains_item("main", inventory_item) then
                        local stack = ItemStack(inventory_item .. " 1")
                        inv:remove_item("main", stack)
                        self.hp_max = self.hp_max + 10
                        if self.hp_max > 50 then self.hp_max = 50 end
                        airutils.setText(self,"ultralight trike")
                    else
                        minetest.chat_send_player(puncher:get_player_name(), "You need steel ingots in your inventory to perform this repair.")
                    end
                end
                return
            end

            -- deal with painting or destroying
		    if itmstck then
			    if airutils.set_paint(self, puncher, itmstck, "trike_painting.png") == false then
			        -- deal damage
				    if not self.driver and toolcaps and toolcaps.damage_groups and
                            toolcaps.damage_groups.fleshy and item_name ~= airutils.fuel then
					    --airutils.hurt(self,toolcaps.damage_groups.fleshy - 1)
					    --airutils.make_sound(self,'hit')
                        self.hp_max = self.hp_max - 10
                        minetest.sound_play("trike_collision", {
	                        object = self.object,
	                        max_hear_distance = 5,
	                        gain = 1.0,
                            fade = 0.0,
                            pitch = 1.0,
                        })
                        airutils.setText(self,"ultralight trike")
				    end
			    end
            end

            if self.hp_max <= 0 then
                trike.destroy(self)
            end

        end
        
	end,

	on_rightclick = function(self, clicker)
		if not clicker or not clicker:is_player() then
			return
		end

        local name = clicker:get_player_name()

        if self.owner == "" then
            self.owner = name
        end

        local passenger_name = nil
        if self._passenger then
            passenger_name = self._passenger
        end

        local touching_ground, liquid_below = trike.check_node_below(self.object)
        local is_on_ground = self.isinliquid or touching_ground or liquid_below
        local is_under_water = airutils.check_is_under_water(self.object)

        --minetest.chat_send_all('name '.. dump(name) .. ' - pilot: ' .. dump(self.driver_name) .. ' - pax: ' .. dump(passenger_name))
        --=========================
        --  detach pilot
        --=========================
        if name == self.driver_name then
            trike.pilot_formspec(name)
        --=========================
        --  detach passenger
        --=========================
        elseif name == passenger_name then
            if is_on_ground or clicker:get_player_control().sneak then
                trike.dettach_pax(self, clicker)
            else
                minetest.chat_send_player(name, "Hold sneak and right-click to disembark while flying")
            end

        --=========================
        --  attach pilot
        --=========================
        elseif not self.driver_name then
            if self.owner == name or minetest.check_player_privs(clicker, {protection_bypass=true}) then
                if clicker:get_player_control().aux1 == true then --lets see the inventory
                    airutils.show_vehicle_trunk_formspec(self, clicker, trike.trunk_slots)
                else
                    if trike.restricted == "true" and not minetest.check_player_privs(clicker, {flight_licence=true}) then
                        minetest.show_formspec(name, "trike:flightlicence",
                            "size[4,2]" ..
                            "label[0.0,0.0;Sorry ...]"..
                            "label[0.0,0.7;You need a flight licence to fly it.]" ..
                            "label[0.0,1.0;You must obtain it from server admin.]" ..
                            "button_exit[1.5,1.9;0.9,0.1;e;Exit]")
                        return
                    end

                    if is_under_water then return end
                    --remove pax to prevent bug
                    if self._passenger then 
                        local pax_obj = minetest.get_player_by_name(self._passenger)
                        trike.dettach_pax(self, pax_obj)
                    end

                    --attach player
                    -- no driver => clicker is new driver
                    trike.attach(self, clicker)
                end
            else
                minetest.chat_send_player(name, core.colorize('#ff0000', " >>> You aren't the owner of this ultralight."))
            end

        --=========================
        --  attach passenger
        --=========================
        elseif self.driver_name and not self._passenger then
            trike.attach_pax(self, clicker)
        
        else
            minetest.chat_send_player(name, core.colorize('#ff0000', " >>> Can't enter airplane."))
        end
	end,

})
