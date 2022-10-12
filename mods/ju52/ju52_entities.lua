dofile(minetest.get_modpath("ju52") .. DIR_DELIM .. "ju52_global_definitions.lua")

--
-- entity
--

ju52.vector_up = vector.new(0, 1, 0)

minetest.register_entity('ju52:engine',{
initial_properties = {
	physical = false,
	collide_with_objects=false,
	pointable=false,
	visual = "mesh",
    backface_culling = false,
	mesh = "ju52_propellers.b3d",
    --visual_size = {x = 3, y = 3, z = 3},
	textures = {"ju52_helice.png", "ju52_black.png",
                "ju52_helice.png", "ju52_black.png",
                "ju52_helice.png", "ju52_black.png",
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

--
-- seat pivot
--
minetest.register_entity('ju52:seat_base',{
initial_properties = {
	physical = false,
	collide_with_objects=false,
	pointable=false,
	visual = "mesh",
	mesh = "ju52_seat_base.b3d",
    textures = {"ju52_black.png",},
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

function ju52.textures_copy()
    local tablecopy = {}
    for k, v in pairs(ju52.textures) do
      tablecopy[k] = v
    end
    return tablecopy
end

minetest.register_entity("ju52:ju52", {
	initial_properties = {
	    physical = true,
        collide_with_objects = false, --true,
	    collisionbox = {-1.2, -2.31, -1.2, 1.2, 1, 1.2},
	    selectionbox = {-5, -2.31, -5, 5, 1, 5},
	    visual = "mesh",
        backface_culling = true,
	    mesh = "ju52_mine.b3d",
        stepheight = 0.6,
        textures = ju52.textures_copy(),
    },
    textures = {},
	driver_name = nil,
	sound_handle = nil,
    owner = "",
    static_save = true,
    infotext = "Ju 52 3M",
    hp_max = 50,
    shaded = true,
    show_on_minimap = true,
    springiness = 0.5,
    physics = ju52.physics,
    buoyancy = 1.1,
    _last_time_command = 1,
    _command_is_given = false,
    _rudder_angle = 0,
    _acceleration = 0,
    _engine_running = false,
    _angle_of_attack = 2,
    _elevator_angle = 0,
    _power_lever = 0,
    _energy = 0.001,
    _last_vel = {x=0,y=0,z=0},
    _longit_speed = 0,
    _show_hud = false,
    _last_accell = {x=0,y=0,z=0},
    _flap = false,
    _wing_configuration = ju52.wing_angle_of_attack,
    _passengers_base = {},
    _passengers = {},
    _color = nil,
    _skin = 'ju52_skin_lufthansa.png',
    _inv = nil,
    _inv_id = "",
    _door_closed = true,
    _door_command = 1, --1 close, 0 open
    _adf = false,
    _adf_destiny = {x=0,z=0},

    _change_color = function(self, colstr)
        airutils.paint(self, colstr, ju52.skin_texture)
    end,

    get_staticdata = function(self) -- unloaded/unloads ... is now saved
        return minetest.serialize({
            stored_energy = self._energy,
            stored_owner = self.owner,
            stored_hp = self.hp_max,
            stored_power_lever = self._power_lever,
            stored_driver_name = self.driver_name,
            stored_flap = self._flap,
            stored_color = self._color,
            stored_skin = self._skin,
            stored_inv_id = self._inv_id,
            stored_adf = self._adf,
            stored_adf_destiny = self._adf_destiny,
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
            self._power_lever = data.stored_power_lever
            self.driver_name = data.stored_driver_name
            self._flap = data.stored_flap
            self._color = data.stored_color
            self._skin = data.stored_skin
            self._inv_id = data.stored_inv_id
            self._adf = data.stored_adf
            self._adf_destiny = data.stored_adf_destiny
            --minetest.debug("loaded: ", self._energy)
        end
        airutils.setText(self, "Ju 52")
        self.object:set_animation({x = 1, y = 12}, 0, 0, true)

        local pos = self.object:get_pos()

	    local engine=minetest.add_entity(pos,'ju52:engine')
	    engine:set_attach(self.object,'',{x=0,y=0,z=0},{x=0,y=0,z=0})
		-- set the animation once and later only change the speed
        engine:set_animation({x = 1, y = 12}, 0, 0, true)
	    self.engine = engine

        local pilot_seat_base=minetest.add_entity(pos,'ju52:seat_base')
        pilot_seat_base:set_attach(self.object,'',{x=-6.5,y=8.7,z=20},{x=0,y=0,z=0})
	    self.pilot_seat_base = pilot_seat_base

        local co_pilot_seat_base=minetest.add_entity(pos,'ju52:seat_base')
        co_pilot_seat_base:set_attach(self.object,'',{x=6.5,y=8.7,z=20},{x=0,y=0,z=0})
	    self.co_pilot_seat_base = co_pilot_seat_base

        self._passengers_base = {[1]=nil, [2]=nil, [3]=nil, [4]=nil, [5]=nil, [6]=nil, [7]=nil, [8]=nil, [9]=nil, [10]=nil,}
        self._passengers = {[1]=nil, [2]=nil, [3]=nil, [4]=nil, [5]=nil, [6]=nil, [7]=nil, [8]=nil, [9]=nil, [10]=nil,}

        self._passengers_base[1]=minetest.add_entity(pos,'ju52:seat_base')
        self._passengers_base[1]:set_attach(self.object,'',{x=-6.5,y=6.7,z=9},{x=0,y=0,z=0})

        self._passengers_base[2]=minetest.add_entity(pos,'ju52:seat_base')
        self._passengers_base[2]:set_attach(self.object,'',{x=6.5,y=6.7,z=9},{x=0,y=0,z=0})

        self._passengers_base[3]=minetest.add_entity(pos,'ju52:seat_base')
        self._passengers_base[3]:set_attach(self.object,'',{x=-6.5,y=6.7,z=-0.9},{x=0,y=0,z=0})

        self._passengers_base[4]=minetest.add_entity(pos,'ju52:seat_base')
        self._passengers_base[4]:set_attach(self.object,'',{x=6.5,y=6.7,z=-0.9},{x=0,y=0,z=0})

        self._passengers_base[5]=minetest.add_entity(pos,'ju52:seat_base')
        self._passengers_base[5]:set_attach(self.object,'',{x=-6.5,y=6.7,z=-10.7},{x=0,y=0,z=0})

        self._passengers_base[6]=minetest.add_entity(pos,'ju52:seat_base')
        self._passengers_base[6]:set_attach(self.object,'',{x=6.5,y=6.7,z=-10.7},{x=0,y=0,z=0})

        self._passengers_base[7]=minetest.add_entity(pos,'ju52:seat_base')
        self._passengers_base[7]:set_attach(self.object,'',{x=-6.5,y=6.7,z=-20.5},{x=0,y=0,z=0})

        self._passengers_base[8]=minetest.add_entity(pos,'ju52:seat_base')
        self._passengers_base[8]:set_attach(self.object,'',{x=6.5,y=6.7,z=-20.5},{x=0,y=0,z=0})

        self._passengers_base[9]=minetest.add_entity(pos,'ju52:seat_base')
        self._passengers_base[9]:set_attach(self.object,'',{x=-6.5,y=6.7,z=-30.5},{x=0,y=0,z=0})

        self._passengers_base[10]=minetest.add_entity(pos,'ju52:seat_base')
        self._passengers_base[10]:set_attach(self.object,'',{x=6.5,y=6.7,z=-30.5},{x=0,y=0,z=0})

        if self._color ~= nil then
            ju52.paint(self.object, self._color, ju52.skin_texture)
        else
            ju52.set_skin(self.object, self._skin, ju52.skin_texture)
        end

		self.object:set_armor_groups({immortal=1})

		local inv = minetest.get_inventory({type = "detached", name = self._inv_id})
		-- if the game was closed the inventories have to be made anew, instead of just reattached
		if not inv then
            airutils.create_inventory(self, ju52.trunk_slots)
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
    logic = ju52.flightstep,

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
        local seat = puncher:get_attach()
        if seat then
            local plane = seat:get_attach()
            if plane == self.object then is_attached = true end
        end

        local itmstck=puncher:get_wielded_item()
        local item_name = ""
        if itmstck then item_name = itmstck:get_name() end

        if is_attached == false then
            if ju52.loadFuel(self, puncher:get_player_name()) then
                return
            end

            --repair
            if (item_name == "airutils:repair_tool" or item_name == "default:mese_crystal")
                    and self._engine_running == false  then
                if self.hp_max < 50 then
                    local inventory_item = "default:steel_ingot"
                    local inv = puncher:get_inventory()
                    if inv:contains_item("main", inventory_item) then
                        local stack = ItemStack(inventory_item .. " 1")
                        inv:remove_item("main", stack)
                        self.hp_max = self.hp_max + 10
                        if self.hp_max > 50 then self.hp_max = 50 end
                        airutils.setText(self, "Ju 52")
                    else
                        minetest.chat_send_player(puncher:get_player_name(), "You need steel ingots in your inventory to perform this repair.")
                    end
                end
                return
            else
                -- deal with painting or destroying 
                if airutils.set_paint(self, puncher, itmstck, ju52.skin_texture) == false then
		            if not self.driver and toolcaps and toolcaps.damage_groups
                            and toolcaps.damage_groups.fleshy and item_name ~= airutils.fuel then
			            --airutils.hurt(self,toolcaps.damage_groups.fleshy - 1)
			            --airutils.make_sound(self,'hit')
                        self.hp_max = self.hp_max - 10
                        minetest.sound_play("ju52_collision", {
                            object = self.object,
                            max_hear_distance = 5,
                            gain = 1.0,
                            fade = 0.0,
                            pitch = 1.0,
                        })
                        airutils.setText(self, "Ju 52")
		            end
                else
                    --why?!!!! I'm hacking the painting function. I know it cannot paint at first usage here, so, I'll set the
                    --right texture and repeat
                    self.initial_properties.textures = ju52.textures_copy()
                    airutils.set_paint(self, puncher, itmstck, ju52.skin_texture)
                end
            end

            if self.hp_max <= 0 then
                ju52.destroy(self)
            end
        else
		    local _,indx = item_name:find('dye:')
            if indx and self._engine_running == false  then
                local name = puncher:get_player_name()
                ju52.paint_formspec(name)
                itmstck:set_count(itmstck:get_count()-1)
			    puncher:set_wielded_item(itmstck)
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
                    ju52.pilot_formspec(name)
                end

            else
                self.driver_name = nil
            end
        --=========================
        --  detach copilot
        --=========================
        elseif name == copilot_name then
            ju52.pax_formspec(name)

        --=========================
        --  attach pilot
        --=========================
        elseif not self.driver_name then
            if self.owner == name or minetest.check_player_privs(clicker, {protection_bypass=true}) then
                if clicker:get_player_control().aux1 == true then --lets see the inventory
                    airutils.show_vehicle_trunk_formspec(self, clicker, ju52.trunk_slots)
                else
                    if ju52.restricted == "true" and not minetest.check_player_privs(clicker, {flight_licence=true}) then
                        minetest.show_formspec(name, "ju52:flightlicence",
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
                        ju52.dettach_pax(self, pax_obj)
                    end
                    for i = 10,1,-1
                    do 
                        if self._passengers[i] then
                            if self._passengers[i] then
                                local passenger = minetest.get_player_by_name(self._passengers[i])
                                if passenger then ju52.dettach_pax(self, passenger) end
                            end
                        end
                    end

                    --attach player
                    -- no driver => clicker is new driver
                    ju52.attach(self, clicker)
                    self._command_is_given = false
                end
            else
                ju52.dettach_pax(self, clicker)
                minetest.chat_send_player(name, core.colorize('#ff0000', " >>> You aren't the owner of this Ju 52."))
            end

        --=========================
        --  attach passenger
        --=========================
        elseif self.driver_name ~= nil or self._autoflymode == true then
            local player = minetest.get_player_by_name(self.driver_name)
            if player then

                is_attached = ju52.check_passenger_is_attached(self, name)

                if is_attached then
                    --remove pax
                    ju52.pax_formspec(name)
                    --ju52.dettach_pax(self, clicker)
                else
                    --attach normal passenger
                    if self._door_closed == false then
                        ju52.attach_pax(self, clicker)
                    end
                end

            else
                minetest.chat_send_player(clicker:get_player_name(), message)
            end
        else
            minetest.chat_send_player(clicker:get_player_name(), message)
        end

	end,
})
