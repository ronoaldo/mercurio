dofile(minetest.get_modpath("pa28") .. DIR_DELIM .. "global_definitions.lua")

--
-- entity
--

pa28.vector_up = vector.new(0, 1, 0)

minetest.register_entity('pa28:p_lights',{
initial_properties = {
	physical = false,
	collide_with_objects=false,
	pointable=false,
    glow = 0,
	visual = "mesh",
	mesh = "pa28_lights.b3d",
    textures = {
                    "pa28_l_light.png", --luz posicao
                    "pa28_l_light.png", --luz posicao esq
                    "pa28_r_light.png", --luz posicao dir
        },
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

minetest.register_entity('pa28:light',{
initial_properties = {
	physical = false,
	collide_with_objects=false,
	pointable=false,
    glow = 0,
	visual = "mesh",
	mesh = "pa28_light.b3d",
    textures = {
                    "pa28_metal.png",
        },
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

minetest.register_entity('pa28:engine',{
initial_properties = {
	physical = false,
	collide_with_objects=false,
	pointable=false,
	visual = "mesh",
    backface_culling = false,
	mesh = "pa28_propeller.b3d",
    --visual_size = {x = 3, y = 3, z = 3},
	textures = {"pa28_propeller.png", "pa28_black.png", "pa28_white.png"},
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
minetest.register_entity('pa28:seat_base',{
initial_properties = {
	physical = false,
	collide_with_objects=false,
	pointable=false,
	visual = "mesh",
	mesh = "pa28_seat_base.b3d",
    textures = {"pa28_black.png",},
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

minetest.register_entity("pa28:pa28", {
	initial_properties = {
	    physical = true,
        collide_with_objects = true,
	    collisionbox = {-1.2, -1.5, -1.2, 1.2, 1, 1.2}, --{-1,0,-1, 1,0.3,1},
	    selectionbox = {-2, -1, -2, 2, 1.2, 2},
	    visual = "mesh",
	    mesh = "pa28.b3d",
        stepheight = 0.5,
        textures = {
                    "pa28_black.png", --bancos 1
                    "pa28_black.png", --bancos 2
                    "pa28_compass.png", --bussola
                    "pa28_white.png", --ponteiros
                    "pa28_compass_plan.png", --indicador bussola
                    "pa28_white.png", --superficies controle
                    "pa28_painting.png", --topo leme
                    "pa28_black.png", --manches
                    "pa28_white.png", --topo fuselagem
                    "pa28_painting.png", --fuselagem
                    "pa28_black.png", --motor
                    "pa28_glass.png", --motor
                    "pa28_interior.png", --fuselagem
                    "pa28_black.png", --painel topo
                    "pa28_black.png", --painel fundo
                    "pa28_panel.png", --painel
                    "pa28_compass_ind.png", --compass plane
                    "pa28_white.png", --topo carenagens
                    "pa28_painting.png", --carenagens
                    "pa28_metal.png", --suporte trem frontal
                    "pa28_white.png", --topo carenagen
                    "pa28_painting.png", --carenagem
                    "pa28_painting.png", --topo est vertical
                    "pa28_black.png", --pneu
                    "pa28_metal.png", --aro roda
                    "pa28_black.png", --pneu
                    "pa28_metal.png", --aro roda
                    "pa28_white.png", --asas
                    "pa28_painting.png", --pontas das asas
                    },
    },
    textures = {},
	driver_name = nil,
	sound_handle = nil,
    owner = "",
    static_save = true,
    infotext = "A nice airplane",
    hp_max = 50,
    shaded = true,
    show_on_minimap = true,
    springiness = 0.1,
    physics = pa28.physics,
    buoyancy = 1.02,
    _passenger = nil,
    _color = "#0063b0",
    _rudder_angle = 0,
    _acceleration = 0,
    _engine_running = false,
    _angle_of_attack = 2,
    _elevator_angle = 0,
    _power_lever = 0,
    _last_applied_power = 0,
    _energy = 0.001,
    _last_vel = {x=0,y=0,z=0},
    _longit_speed = 0,
    _show_hud = false,
    _command_is_given = false, --flag to mark the "owner" of the commands now
    _autopilot = false,
    _auto_pilot_altitude = 0,
    _flap = false,
    _last_accell = {x=0,y=0,z=0},
    _last_time_command = 1,
    _wing_configuration = pa28.wing_angle_of_attack,
    _land_light = false,
    _last_light_move = 0,
    _light_active_time = 0,
    _adf = false,
    _adf_destiny = {x=0,z=0},
    _inv = nil,
    _inv_id = "",

    _change_color = function(self, colstr)
        airutils.paint(self, colstr, "pa28_painting.png")
    end,

    get_staticdata = function(self) -- unloaded/unloads ... is now saved
        return minetest.serialize({
            --stored_sound_handle = self.sound_handle,
            stored_energy = self._energy,
            stored_owner = self.owner,
            stored_hp = self.hp_max,
            stored_color = self._color,
            stored_power_lever = self._power_lever,
            stored_driver_name = self.driver_name,
            stored_last_accell = self._last_accell,
            stored_engine_running = self._engine_running,
            stored_inv_id = self._inv_id,
            stored_flap = self._flap,
            stored_adf = self._adf,
            stored_adf_destiny = self._adf_destiny,
        })
    end,

	on_deactivate = function(self)
        airutils.save_inventory(self)
        if(self.sound_handle) then minetest.sound_stop(self.sound_handle) end
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
            self._last_accell = data.stored_last_accell
            self._engine_running = data.stored_engine_running
            self._inv_id = data.stored_inv_id
            self._flap = data.stored_flap
            self._adf = data.stored_adf
            self._adf_destiny = data.stored_adf_destiny

            --self.sound_handle = data.stored_sound_handle
            --minetest.debug("loaded: ", self._energy)
            if self._engine_running then
                self._last_applied_power = -1 --signal to start
            end
        end
        airutils.setText(self, pa28.plane_text)
        self.object:set_animation({x = 1, y = 12}, 0, 0, true)

        local pos = self.object:get_pos()

        local lights=minetest.add_entity(pos,'pa28:p_lights')
        lights:set_attach(self.object,'',{x=0,y=0,z=0},{x=0,y=0,z=0})
        self.lights = lights

        local light=minetest.add_entity(pos,'pa28:light')
        light:set_attach(self.object,'',{x=0,y=0,z=0},{x=0,y=0,z=0})
        self.light = light

	    local engine=minetest.add_entity(pos,'pa28:engine')
	    engine:set_attach(self.object,'',{x=0,y=0,z=0},{x=0,y=0,z=0})
		-- set the animation once and later only change the speed
        engine:set_animation({x = 1, y = 12}, 0, 0, true)
	    self.engine = engine

        local pilot_seat_base=minetest.add_entity(pos,'pa28:seat_base')
        pilot_seat_base:set_attach(self.object,'',{x=-4.25,y=-4,z=2},{x=0,y=0,z=0})
	    self.pilot_seat_base = pilot_seat_base

        local co_pilot_seat_base=minetest.add_entity(pos,'pa28:seat_base')
        co_pilot_seat_base:set_attach(self.object,'',{x=4.25,y=-4,z=2},{x=0,y=0,z=0})
	    self.co_pilot_seat_base = co_pilot_seat_base

        self._passengers_base = {[1]=nil, [2]=nil,}
        self._passengers = {[1]=nil, [2]=nil,}

        self._passengers_base[1]=minetest.add_entity(pos,'pa28:seat_base')
        self._passengers_base[1]:set_attach(self.object,'',{x=-4.25,y=-4.5,z=-6},{x=0,y=0,z=0})

        self._passengers_base[2]=minetest.add_entity(pos,'pa28:seat_base')
        self._passengers_base[2]:set_attach(self.object,'',{x=4.25,y=-4.5,z=-6},{x=0,y=0,z=0})

        airutils.paint(self, self._color, "pa28_painting.png")

        self.object:set_bone_position("flap_a.r", {x=20.8,y=-5.8,z=-6.7}, {x=0,y=0,z=5})
        self.object:set_bone_position("flap_a.l", {x=-20.8,y=-5.8,z=-6.7}, {x=0,y=0,z=-5})
        self.object:set_bone_position("aileron_a.r", {x=43.7,y=-3.8,z=-6.7}, {x=0,y=0,z=5})
        self.object:set_bone_position("aileron_a.l", {x=-43.7,y=-3.8,z=-6.7}, {x=0,y=0,z=-5})
        self.object:set_bone_position("rudder_a", {x=0,y=12.05,z=-46.7}, {x=-21.2,y=0,z=0})

		self.object:set_armor_groups({immortal=1})

		local inv = minetest.get_inventory({type = "detached", name = self._inv_id})
		-- if the game was closed the inventories have to be made anew, instead of just reattached
		if not inv then
            airutils.create_inventory(self, pa28.trunk_slots)
		else
		    self.inv = inv
        end
        if self._engine_running == true then pa28.engineSoundPlay(self) end
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
    logic = pa28.flightstep,

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
        if puncher:get_attach() == self.pilot_seat_base then is_attached = true end

        local itmstck=puncher:get_wielded_item()
        local item_name = ""
        if itmstck then item_name = itmstck:get_name() end

        if is_attached == false then
            if pa28.loadFuel(self, puncher:get_player_name()) then
                return
            end

            --repair
            if (item_name == "airutils:repair_tool")
                    and self._engine_running == false  then
                if self.hp_max < 50 then
                    local inventory_item = "default:steel_ingot"
                    local inv = puncher:get_inventory()
                    if inv:contains_item("main", inventory_item) then
                        local stack = ItemStack(inventory_item .. " 1")
                        inv:remove_item("main", stack)
                        self.hp_max = self.hp_max + 10
                        if self.hp_max > 50 then self.hp_max = 50 end
                        airutils.setText(self, pa28.plane_text)
                    else
                        minetest.chat_send_player(puncher:get_player_name(), "You need steel ingots in your inventory to perform this repair.")
                    end
                end
                return
            end

            -- deal with painting or destroying
		    if itmstck then

			    if airutils.set_paint(self, puncher, itmstck, "pa28_painting.png") == false then
				    if not self.driver and toolcaps and toolcaps.damage_groups
                            and toolcaps.damage_groups.fleshy and item_name ~= airutils.fuel then
					    --airutils.hurt(self,toolcaps.damage_groups.fleshy - 1)
					    --airutils.make_sound(self,'hit')
                        self.hp_max = self.hp_max - 10
                        minetest.sound_play("pa28_collision", {
	                        object = self.object,
	                        max_hear_distance = 5,
	                        gain = 1.0,
                            fade = 0.0,
                            pitch = 1.0,
                        })
                        airutils.setText(self, pa28.plane_text)
				    end
			    end
            end

            if self.hp_max <= 0 then
                pa28.destroy(self)
            end
        end
        
	end,

	on_rightclick = function(self, clicker)
        local message = ""
		if not clicker or not clicker:is_player() then
			return
		end

        local name = clicker:get_player_name()

        if self.owner == "" then
            self.owner = name
        end

        local copilot_name = nil
        if self._passenger then
            copilot_name = self._passenger
        end

        local touching_ground, liquid_below = airutils.check_node_below(self.object, 2.5)
        local is_on_ground = self.isinliquid or touching_ground or liquid_below
        local is_under_water = airutils.check_is_under_water(self.object)

        --minetest.chat_send_all('name '.. dump(name) .. ' - pilot: ' .. dump(self.driver_name) .. ' - pax: ' .. dump(copilot_name))
        --=========================
        --  form to pilot
        --=========================
        local is_attached = false
        local seat = clicker:get_attach()
        if seat then
            local plane = seat:get_attach()
            if plane == self.object then is_attached = true end
        end
        if name == self.driver_name then
            if is_attached then
                local itmstck=clicker:get_wielded_item()
                local item_name = ""
                if itmstck then item_name = itmstck:get_name() end
                if (item_name == "compassgps:cgpsmap_marked") then
                    local meta = minetest.deserialize(itmstck:get_metadata())
                    if meta then
                        self._adf_destiny = {x=meta["x"], z=meta["z"]}
                    end
                else
                    pa28.pilot_formspec(name)
                end
            else
                self.driver_name = nil
            end
        --=========================
        --  detach copilot
        --=========================
        elseif name == copilot_name then
            pa28.pax_formspec(name)

        --=========================
        --  attach pilot
        --=========================
        elseif not self.driver_name then
            if self.owner == name or minetest.check_player_privs(clicker, {protection_bypass=true}) then
                if clicker:get_player_control().aux1 == true then --lets see the inventory
                    airutils.show_vehicle_trunk_formspec(self, clicker, pa28.trunk_slots)
                else
                    if pa28.restricted == "true" and not minetest.check_player_privs(clicker, {flight_licence=true}) then
                        minetest.show_formspec(name, "pa28:flightlicence",
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
                        pa28.dettach_pax(self, pax_obj)
                    end
                    for i = 10,1,-1
                    do 
                        if self._passengers[i] then
                            if self._passengers[i] then
                                local passenger = minetest.get_player_by_name(self._passengers[i])
                                if passenger then pa28.dettach_pax(self, passenger) end
                            end
                        end
                    end

                    --attach player
                    -- no driver => clicker is new driver
                    pa28.attach(self, clicker)
                    self._command_is_given = false
                end
            else
                pa28.dettach_pax(self, clicker)
                minetest.chat_send_player(name, core.colorize('#ff0000', " >>> You aren't the owner of this "..pa28.plane_text.."."))
            end

        --=========================
        --  attach passenger
        --=========================
        elseif self.driver_name ~= nil or self._autoflymode == true then
            local player = minetest.get_player_by_name(self.driver_name)
            if player then

                is_attached = pa28.check_passenger_is_attached(self, name)

                if is_attached then
                    --remove pax
                    pa28.pax_formspec(name)
                    --pa28.dettach_pax(self, clicker)
                else
                    --attach normal passenger
                    pa28.attach_pax(self, clicker)
                end

            else
                minetest.chat_send_player(clicker:get_player_name(), message)
            end
        else
            minetest.chat_send_player(clicker:get_player_name(), message)
        end

	end,
})
