

trike={}

local TRIKE_GAUGE_FUEL_POSITION = {x=1.5,y=6.2,z=15.2}
local TRIKE_GAUGE_POWER_POSITION = {x=1.5,y=7.7,z=15.2}
local TRIKE_GAUGE_CLIMBER_POSITION = {x=-1.2,y=7.55,z=15.2}

trike.S = nil

if(minetest.get_translator ~= nil) then
    trike.S = minetest.get_translator(minetest.get_current_modname())

else
    trike.S = function ( s ) return s end

end

local S = trike.S

function trike.register_parts_method(self)
    local pos = self.object:get_pos()

    local wheels=minetest.add_entity(pos,'trike:wheels')
    wheels:set_attach(self.object,'',{x=0,y=0,z=0},{x=0,y=0,z=0})
    self.wheels = wheels

    local fuel_gauge=minetest.add_entity(pos,'trike:pointer')
    local fuel_percentage = (self._energy*100)/self._max_fuel
    local fuel_angle = -(fuel_percentage*180)/100
    fuel_gauge:set_attach(self.object,'',TRIKE_GAUGE_FUEL_POSITION,{x=0,y=0,z=fuel_angle+90})
    self.fuel_pointer = fuel_gauge

    local power_gauge=minetest.add_entity(pos,'trike:pointer')
    local power_indicator_angle = airutils.get_gauge_angle(self._power_lever/10)
    power_gauge:set_attach(self.object,'',TRIKE_GAUGE_POWER_POSITION,{x=0,y=0,z=power_indicator_angle})
    self.power_pointer = power_gauge

    local climb_gauge=minetest.add_entity(pos,'trike:pointer')
    local climb_angle = airutils.get_gauge_angle(0)
    climb_gauge:set_attach(self.object,'',TRIKE_GAUGE_CLIMBER_POSITION,{x=0,y=0,z=climb_angle})
    self.climb_pointer = climb_gauge
end

function trike.destroy_parts_method(self)
    if self.wheels then self.wheels:remove() end
    if self.fuel_pointer then self.fuel_pointer:remove() end
    if self.power_pointer then self.power_pointer:remove() end
    if self.climb_pointer then self.climb_pointer:remove() end

    local pos = self.object:get_pos()

    pos.y=pos.y+2
    minetest.add_item({x=pos.x+math.random()-0.5,y=pos.y,z=pos.z+math.random()-0.5},'trike:wing')

    for i=1,6 do
	    minetest.add_item({x=pos.x+math.random()-0.5,y=pos.y,z=pos.z+math.random()-0.5},'default:mese_crystal')
        minetest.add_item({x=pos.x+math.random()-0.5,y=pos.y,z=pos.z+math.random()-0.5},'default:diamond')
    end

    for i=1,3 do
	    minetest.add_item({x=pos.x+math.random()-0.5,y=pos.y,z=pos.z+math.random()-0.5},'default:steel_ingot')
    end

end

function trike.step_additional_function(self)
    self.object:set_bone_position("wing", {x=0,y=29,z=0}, {x=-self._elevator_angle/2.5,y=0,z=(self._rudder_angle/2.5)})
    if (self.driver_name==nil) and (self.co_pilot==nil) then --pilot or copilot
        return
    end
    local pos = self.object:get_pos()

    local fuel_percentage = (self._energy*100)/self._max_fuel
    local fuel_angle = -(fuel_percentage*180)/100
    self.fuel_pointer:set_attach(self.object,'',TRIKE_GAUGE_FUEL_POSITION,{x=0,y=0,z=fuel_angle+90})

    local power_indicator_angle = airutils.get_gauge_angle(self._power_lever/10)
    self.power_pointer:set_attach(self.object,'',TRIKE_GAUGE_POWER_POSITION,{x=0,y=0,z=power_indicator_angle})

    local climb_angle = airutils.get_gauge_angle(self._climb_rate)
    self.climb_pointer:set_attach(self.object,'',TRIKE_GAUGE_CLIMBER_POSITION,{x=0,y=0,z=climb_angle})
end

trike.plane_properties = {
	initial_properties = {
	    physical = true,
        collide_with_objects = true,
	    collisionbox = {-1.2, 0.0, -1.2, 1.2, 3, 1.2}, --{-1,0,-1, 1,0.3,1},
	    selectionbox = {-2, 0, -2, 2, 1, 2},
	    visual = "mesh",
        backface_culling = false,
	    mesh = "trike_body.b3d",
        stepheight = 0.5,
        textures = {
                        "trike_black.png", --bancos
                        "airutils_metal.png",
                        "airutils_metal.png",
                        "airutils_metal.png",
                        "airutils_metal.png",
                        "airutils_metal.png",
                        "trike_painting.png", --pintura
                        "trike_grey.png", --motor
                        "airutils_metal.png", --trem nariz
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
                        "trike_rotor.png", --helice
                        "trike_black.png", --cubo helice
                        "airutils_red.png",
                        "airutils_green.png",
                        "airutils_blue.png",
                        "airutils_metal.png",
                    },
    },
    textures = {},
    _anim_frames = 11,
	driver_name = nil,
	sound_handle = nil,
    owner = "",
    static_save = true,
    infotext = "",
    hp_max = 50,
    shaded = true,
    show_on_minimap = true,
    springiness = 0.1,
    buoyancy = 1.02,
    physics = airutils.physics,
    _vehicle_name = "trike",
    _use_camera_relocation = false,
    _seats = {{x=0,y=7,z=8},{x=0,y=9,z=1.6},},
    _seats_rot = {0,0},  --necessary when using reversed seats
    _have_copilot = false, --wil use the second position of the _seats list
    _max_plane_hp = 50,
    _enable_fire_explosion = false,
    _longit_drag_factor = 0.13*0.13,
    _later_drag_factor = 2.0,
    _wing_angle_of_attack = 1.5,
    _wing_span = 12, --meters
    _min_speed = 3,
    _max_speed = 7.5,
    _max_fuel = 10,
    _fuel_consumption_divisor = 1200000,
    _speed_not_exceed = 14,
    _damage_by_wind_speed = 4,
    _hard_damage = true,
    _min_attack_angle = 0.2,
    _max_attack_angle = 90,
    _elevator_auto_estabilize = 100,
    _tail_lift_min_speed = 3,
    _tail_lift_max_speed = 5,
    _max_engine_acc = 7.5,
    _tail_angle = 0, --degrees
    _lift = 18,
    _trunk_slots = 2, --the trunk slots
    _rudder_limit = 30.0,
    _elevator_limit = 40.0,
    _elevator_response_attenuation = 10,
    _pitch_intensity = 0.6,
    _yaw_intensity = 40,
    _yaw_turn_rate = 12,
    _elevator_pos = {x=0, y=0, z=0},
    _rudder_pos = {x=0,y=0,z=0},
    _aileron_r_pos = {x=0,y=0,z=0},
    _aileron_l_pos = {x=0,y=0,z=0},
    _color = "#0063b0",
    _color_2 = "#0063b0",
    _rudder_angle = 0,
    _acceleration = 0,
    _engine_running = false,
    _angle_of_attack = 0,
    _elevator_angle = 0,
    _power_lever = 0,
    _last_applied_power = 0,
    _energy = 1.0,
    _last_vel = {x=0,y=0,z=0},
    _longit_speed = 0,
    _show_hud = true,
    _instruction_mode = false, --flag to intruction mode
    _command_is_given = false, --flag to mark the "owner" of the commands now
    _autopilot = false,
    _auto_pilot_altitude = 0,
    _last_accell = {x=0,y=0,z=0},
    _last_time_command = 1,
    _inv = nil,
    _inv_id = "",
    _collision_sound = "airutils_collision", --the col sound
    _engine_sound = "trike_engine",
    _painting_texture = {"trike_painting.png",}, --the texture to paint
    _painting_texture_2 = {"airutils_painting_2.png",}, --the texture to paint
    _mask_painting_associations = {},
    _register_parts_method = trike.register_parts_method, --the method to register plane parts
    _destroy_parts_method = trike.destroy_parts_method,
    _plane_y_offset_for_bullet = 1,
    _custom_step_additional_function = trike.step_additional_function,
    _inverted_pitch_reaction = true,

    get_staticdata = airutils.get_staticdata,
    on_deactivate = airutils.on_deactivate,
    on_activate = airutils.on_activate,
    logic = airutils.logic,
    on_step = airutils.on_step,
    on_punch = airutils.on_punch,
    on_rightclick = airutils.on_rightclick,
}

dofile(minetest.get_modpath("trike") .. DIR_DELIM .. "crafts.lua")
dofile(minetest.get_modpath("trike") .. DIR_DELIM .. "entities.lua")

--
-- items
--

settings = Settings(minetest.get_worldpath() .. "/trike_settings.conf")
local function fetch_setting(name)
    local sname = name
    return settings and settings:get(sname) or minetest.settings:get(sname)
end

local old_entities = {"trike:seat_base","trike:engine","trike:front_wheel"}
for _,entity_name in ipairs(old_entities) do
    minetest.register_entity(":"..entity_name, {
        on_activate = function(self, staticdata)
            self.object:remove()
        end,
    })
end


