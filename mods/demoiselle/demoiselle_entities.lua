dofile(minetest.get_modpath("demoiselle") .. DIR_DELIM .. "demoiselle_global_definitions.lua")

--
-- entity
--

demoiselle.vector_up = vector.new(0, 1, 0)

minetest.register_entity('demoiselle:engine',{
initial_properties = {
	physical = false,
	collide_with_objects=false,
	pointable=false,
	visual = "mesh",
    backface_culling = false,
	mesh = "demoiselle_propeller.b3d",
    --visual_size = {x = 3, y = 3, z = 3},
	textures = {"demoiselle_black.png","demoiselle_helice.png"},
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
minetest.register_entity('demoiselle:seat_base',{
initial_properties = {
	physical = false,
	collide_with_objects=false,
	pointable=false,
	visual = "mesh",
	mesh = "demoiselle_seat_base.b3d",
    textures = {"demoiselle_black.png",},
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

minetest.register_entity("demoiselle:demoiselle", {
	initial_properties = {
	    physical = true,
        collide_with_objects = true,
	    collisionbox = {-1.2, 0, -1.2, 1.2, 2, 1.2}, --{-1,0,-1, 1,0.3,1},
	    selectionbox = {-2, 0, -2, 2, 2, 2},
	    visual = "mesh",
        backface_culling = false,
	    mesh = "demoiselle.b3d",
        stepheight = 0.5,
        textures = {"demoiselle_bamboo.png",
                    "demoiselle_black.png", --cabos
                    "demoiselle_black.png", -- cabos empenagem
                    "demoiselle_canvas_structure.png", -- estrutura empenagem
                    "demoiselle_canvas.png", -- entelagem empenagem
                    "demoiselle_black.png", -- banco
                    "demoiselle_bamboo.png", -- estrutura fuselagem
                    "demoiselle_metal2.png", -- estrutura fuselagem
                    "demoiselle_metal.png", -- motor
                    "demoiselle_canvas_structure.png", --nervuras
                    "demoiselle_canvas.png", -- entelagem asas
                    "demoiselle_black.png", -- pneu
                    "demoiselle_metal.png", -- aro rodas
                    "demoiselle_wheel.png", -- raio rodas
                    "demoiselle_copper.png", -- tanque
                    "demoiselle_black.png", -- cabeçote motor
            },
    },
    textures = {},
	driver_name = nil,
	sound_handle = nil,
    owner = "",
    static_save = true,
    infotext = "Demoiselle",
    hp_max = 50,
    shaded = true,
    show_on_minimap = true,
    buoyancy = 0.25,
    springiness = 0.3,
    physics = demoiselle.physics,
    _last_time_command = 1,
    _rudder_angle = 0,
    _acceleration = 0,
    _engine_running = false,
    _angle_of_attack = 2,
    _elevator_angle = 0,
    _power_lever = 0,
    _energy = 0.001,
    _last_vel = {x=0,y=0,z=0},
    _longit_speed = 0,
    _show_hud = true,
    _last_accell = {x=0,y=0,z=0},

    get_staticdata = function(self) -- unloaded/unloads ... is now saved
        return minetest.serialize({
            stored_energy = self._energy,
            stored_owner = self.owner,
            stored_hp = self.hp_max,
            stored_power_lever = self._power_lever,
            stored_driver_name = self.driver_name,
        })
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
            --minetest.debug("loaded: ", self._energy)
        end
        airutils.setText(self, "Demoiselle")
        self.object:set_animation({x = 1, y = 12}, 0, 0, true)

        local pos = self.object:get_pos()

	    local engine=minetest.add_entity(pos,'demoiselle:engine')
	    engine:set_attach(self.object,'',{x=0,y=24.5,z=0},{x=0,y=0,z=0})
		-- set the animation once and later only change the speed
        engine:set_animation({x = 1, y = 12}, 0, 0, true)
	    self.engine = engine

        local pilot_seat_base=minetest.add_entity(pos,'demoiselle:seat_base')
        pilot_seat_base:set_attach(self.object,'',{x=0,y=5,z=2},{x=0,y=0,z=0})
	    self.pilot_seat_base = pilot_seat_base

		self.object:set_armor_groups({immortal=1})
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
    logic = demoiselle.flightstep,

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
            if demoiselle.loadFuel(self, puncher:get_player_name()) then
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
                        airutils.setText(self,"Demoiselle")
                    else
                        minetest.chat_send_player(puncher:get_player_name(), "You need steel ingots in your inventory to perform this repair.")
                    end
                end
                return
            else
                -- deal with painting or destroying
		        if not self.driver and toolcaps and toolcaps.damage_groups
                        and toolcaps.damage_groups.fleshy and item_name ~= airutils.fuel then
			        --airutils.hurt(self,toolcaps.damage_groups.fleshy - 1)
			        --airutils.make_sound(self,'hit')
                    self.hp_max = self.hp_max - 10
                    minetest.sound_play("collision", {
                        object = self.object,
                        max_hear_distance = 5,
                        gain = 1.0,
                        fade = 0.0,
                        pitch = 1.0,
                    })
                    airutils.setText(self, "Demoiselle")
		        end
            end

            if self.hp_max <= 0 then
                demoiselle.destroy(self)
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

        --check if is the owner
        if self.owner == name or minetest.check_player_privs(clicker, {protection_bypass=true}) then
            -- pilot section
            if name == self.driver_name then
                demoiselle.pilot_formspec(name)
            elseif not self.driver_name then
                --=========================
                --  attach player
                --=========================
                --attach player
                local is_under_water = airutils.check_is_under_water(self.object)
                if is_under_water then return end

                self._elevator_angle = 0
                self._rudder_angle = 0
                demoiselle.attach(self, clicker)
            end

            -- end pilot section
        else
            local message = core.colorize('#ff0000', " >>> You aren't the owner of this demoiselle.")
            minetest.chat_send_player(clicker:get_player_name(), message)
        end
	end,
})
