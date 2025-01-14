pa28={}

dofile(minetest.get_modpath("pa28") .. DIR_DELIM .. "manual.lua")

function pa28.register_parts_method(self)
    local pos = self.object:get_pos()

    local lights=minetest.add_entity(pos,'pa28:p_lights')
    lights:set_attach(self.object,'',{x=0,y=0,z=0},{x=0,y=0,z=0})
    self.lights = lights

    local light=minetest.add_entity(pos,'pa28:light')
    light:set_attach(self.object,'',{x=0,y=0,z=0},{x=0,y=0,z=0})
    self.light = light

    local wheels=minetest.add_entity(pos,'pa28:wheels')
    wheels:set_attach(self.object,'',{x=0,y=0,z=0},{x=0,y=0,z=0})
	-- set the animation once and later only change the speed
    wheels:set_animation({x = 1, y = 12}, 0, 0, true)
    self.wheels = wheels

    self.object:set_bone_position("flap_a.r", {x=20.8,y=-5.8,z=-6.7}, {x=0,y=0,z=5})
    self.object:set_bone_position("flap_a.l", {x=-20.8,y=-5.8,z=-6.7}, {x=0,y=0,z=-5})
    self.object:set_bone_position("aileron_a.r", {x=43.7,y=-3.8,z=-6.7}, {x=0,y=0,z=5})
    self.object:set_bone_position("aileron_a.l", {x=-43.7,y=-3.8,z=-6.7}, {x=0,y=0,z=-5})
    self.object:set_bone_position("rudder_a", {x=0,y=12.05,z=-46.7}, {x=-21.2,y=0,z=0})

    --minetest.chat_send_all(self.initial_properties.textures[19])
    --airutils.paint(self.wheels:get_luaentity(), self._color)
end

function pa28.destroy_parts_method(self)
    if self.wheels then self.wheels:remove() end
    if self.light then self.light:remove() end
    if self.lights then self.lights:remove() end

    local pos = self.object:get_pos()
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

function pa28.step_additional_function(self)
    --position lights
    if self._engine_running == true then
        self.lights:set_properties({textures={"pa28_l_light.png^pa28_l_light.png","pa28_l_light.png","pa28_r_light.png"},glow=15})
    else
        self.lights:set_properties({textures={"pa28_l_light.png","pa28_l_light.png","pa28_r_light.png"},glow=0})
    end

    if self._land_light == true then
        self.light:set_properties({textures={"pa28_landing_light.png"},glow=15})
    else
        self.light:set_properties({textures={"pa28_metal.png"},glow=0})
    end

    if (self.driver_name==nil) and (self.co_pilot==nil) then --pilot or copilot
        return
    end

    local pos = self._curr_pos

    local climb_angle = airutils.get_gauge_angle(self._climb_rate)
    self.object:set_bone_position("climber", {x=-1.98,y=2.40,z=10.2}, {x=0,y=0,z=climb_angle-90})

    local speed_angle = airutils.get_gauge_angle(self._indicated_speed, -45)
    self.object:set_bone_position("speed", {x=-7.01,y=1.26,z=10.2}, {x=0,y=0,z=speed_angle})

    local energy_indicator_angle = airutils.get_gauge_angle((self._max_fuel - self._energy)/1.5) - 90
    self.object:set_bone_position("fuel", {x=0, y=0, z=10.2}, {x=0, y=0, z=-energy_indicator_angle+180})

    self.object:set_bone_position("compass", {x=0, y=2.8, z=10.3}, {x=0, y=0, z=-(math.deg(self._yaw))})
    self.object:set_bone_position("compass_plan", {x=0, y=2.8, z=10.25}, {x=0, y=0, z=airutils.get_adf_angle(self, pos)})

    --altimeter
    local altitude = (pos.y / 0.32) / 100
    local hour, minutes = math.modf( altitude )
    hour = math.fmod (hour, 10)
    minutes = minutes * 100
    minutes = (minutes * 100) / 100
    local minute_angle = (minutes*-360)/100
    local hour_angle = (hour*-360)/10 + ((minute_angle*36)/360)
    self.object:set_bone_position("altimeter_pt_1", {x=-4.63, y=2.4, z=10.2}, {x=0, y=0, z=(hour_angle)})
    self.object:set_bone_position("altimeter_pt_2", {x=-4.63, y=2.4, z=10.2}, {x=0, y=0, z=(minute_angle)})

    --adjust power indicator
    local power_indicator_angle = airutils.get_gauge_angle(self._power_lever/6.5)
    self.object:set_bone_position("power", {x=2.8,y=2.40,z=10.2}, {x=0,y=0,z=power_indicator_angle - 90})

    --set stick position
    local stick_z = 9 + (self._elevator_angle / self._elevator_limit )
    self.object:set_bone_position("stick.l", {x=-4.25, y=0.5, z=stick_z}, {x=0,y=0,z=self._rudder_angle})
    self.object:set_bone_position("stick.r", {x=4.25, y=0.5, z=stick_z}, {x=0,y=0,z=self._rudder_angle})
end

pa28.plane_properties = {
	initial_properties = {
	    physical = true,
        collide_with_objects = true,
	    collisionbox = {-1.2, -1.5, -1.2, 1.2, 1, 1.2},
	    selectionbox = {-2, -1, -2, 2, 1.2, 2},
	    visual = "mesh",
        backface_culling = true,
	    mesh = "pa28.b3d",
        stepheight = 0.5,
        textures = {
                    "airutils_black.png", --bancos 1
                    "airutils_black.png", --bancos 2
                    "airutils_painting_2.png", --topo fuselagem
                    "pa28_painting.png", --fuselagem
                    "pa28_black.png", --motor
                    "airutils_name_canvas.png",
                    "pa28_glass.png", --vidros
                    "pa28_interior.png", -- interior
                    "airutils_painting_2.png", -- sup controle
                    "pa28_painting.png", -- topo leme
                    "airutils_black.png", -- sticks
                    "pa28_compass.png", --bussola
                    "pa28_white.png", -- ponteiros
                    "pa28_compass_plan.png", --indicador bussola
                    "pa28_propeller.png", --propeller
                    "airutils_black.png", --cubo helice interno
                    "airutils_black.png", -- topo painel
                    "airutils_black.png", -- fundo painel
                    "pa28_panel.png", --painel
                    "pa28_compass_ind.png", --compass plane
                    "airutils_painting_2.png", -- topo trem
                    "pa28_painting.png", -- parte baixo trem
                    "airutils_metal.png", -- eixo bequilha
                    "airutils_painting_2.png", -- topo bequilha
                    "pa28_painting.png", -- parte baixo bequilha
                    "pa28_painting.png", -- topo estab vert
                    "airutils_painting_2.png", -- asas
                    "pa28_painting.png", -- pontas asas
                    --"airutils_red.png",
                    --"airutils_green.png",
                    --"airutils_blue.png",
                    --"airutils_metal.png",
                    },
    },
    textures = {},
    _anim_frames = 12,
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
    _vehicle_name = "PA-28",
    _seats = {{x=-4.25,y=-4,z=2},{x=4.25,y=-4,z=2},{x=-4.25,y=-4.5,z=-6},{x=4.25,y=-4.5,z=-6},},
    _seats_rot = {0, 0, 0, 0},  --necessary when using reversed seats
    _have_copilot = true, --wil use the second position of the _seats list
    _have_landing_lights = true,
    _have_auto_pilot = true,
    _have_adf = true,
    _have_manual = pa28.manual_formspec,
    _max_plane_hp = 50,
    _enable_fire_explosion = true,
    _longit_drag_factor = 0.13*0.13,
    _later_drag_factor = 2.0,
    _wing_angle_of_attack = 2.5,
    _wing_angle_extra_flaps = 2.5,
    _wing_span = 10, --meters
    _min_speed = 4,
    _max_speed = 9,
    _max_fuel = 15,
    _speed_not_exceed = 16,
    _damage_by_wind_speed = 2,
    _hard_damage = true,
    _min_attack_angle = 0.2,
    _max_attack_angle = 90,
    _elevator_auto_estabilize = 100,
    _tail_lift_min_speed = 0,
    _tail_lift_max_speed = 0,
    _max_engine_acc = 9.0,
    _tail_angle = 0,
    _lift = 11,
    _trunk_slots = 16, --the trunk slots
    _rudder_limit = 40.0,
    _elevator_limit = 15.0,
    _flap_limit = 30.0, --just a decorarion, in degrees
    _elevator_response_attenuation = 4,
    _pitch_intensity = 0.4,
    _yaw_intensity = 20,
    _yaw_turn_rate = 14, --degrees
    _elevator_pos = {x=0, y=2.5, z=-45},
    _rudder_pos = {x=0,y=0,z=0},
    _aileron_r_pos = {x=0,y=0,z=0},
    _aileron_l_pos = {x=0,y=0,z=0},
    _color = "#5AA3FF",
    _color_2 = "#FFFFFF",
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
    _show_hud = false,
    _instruction_mode = false, --flag to intruction mode
    _command_is_given = false, --flag to mark the "owner" of the commands now
    _autopilot = false,
    _auto_pilot_altitude = 0,
    _last_accell = {x=0,y=0,z=0},
    _last_time_command = 1,
    _inv = nil,
    _inv_id = "",
    _collision_sound = "pa28_collision", --the col sound
    _engine_sound = "pa28_engine",
    _painting_texture = {"pa28_painting.png",}, --the texture to paint
    _painting_texture_2 = {"airutils_painting_2.png",}, --the texture to paint
    _mask_painting_associations = {},
    _register_parts_method = pa28.register_parts_method, --the method to register plane parts
    _destroy_parts_method = pa28.destroy_parts_method,
    _plane_y_offset_for_bullet = 1,
    _name_color = 0,
    _name_hor_aligment = 3.0,
    --_custom_punch_when_attached = ww1_planes_lib._custom_punch_when_attached, --the method to execute click action inside the plane
    _custom_pilot_formspec = airutils.pilot_formspec,
    --_custom_pilot_formspec = pa28.pilot_formspec,
    _custom_step_additional_function = pa28.step_additional_function,

    get_staticdata = airutils.get_staticdata,
    on_deactivate = airutils.on_deactivate,
    on_activate = airutils.on_activate,
    logic = airutils.logic,
    on_step = airutils.on_step,
    on_punch = airutils.on_punch,
    on_rightclick = airutils.on_rightclick,
}

dofile(minetest.get_modpath("pa28") .. DIR_DELIM .. "crafts.lua")
dofile(minetest.get_modpath("pa28") .. DIR_DELIM .. "entities.lua")

--
-- items
--

local old_entities = {"pa28:seat_base","pa28:engine"}
for _,entity_name in ipairs(old_entities) do
    minetest.register_entity(":"..entity_name, {
        on_activate = function(self, staticdata)
            self.object:remove()
        end,
    })
end

