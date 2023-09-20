

demoiselle={}

function demoiselle.register_parts_method(self)
    local pos = self.object:get_pos()

    local wheels=minetest.add_entity(pos,'demoiselle:wheels')
    wheels:set_attach(self.object,'',{x=0,y=0,z=0},{x=0,y=0,z=0})
    self.wheels = wheels
end

function demoiselle.destroy_parts_method(self)
    if self.wheels then self.wheels:remove() end

    local pos = self.object:get_pos()

    pos.y=pos.y+2
    minetest.add_item({x=pos.x+math.random()-0.5,y=pos.y,z=pos.z+math.random()-0.5},'demoiselle:wings')

    for i=1,6 do
	    minetest.add_item({x=pos.x+math.random()-0.5,y=pos.y,z=pos.z+math.random()-0.5},'default:steel_ingot')
    end

    for i=1,4 do
	    minetest.add_item({x=pos.x+math.random()-0.5,y=pos.y,z=pos.z+math.random()-0.5},'default:wood')
    end

    for i=1,6 do
	    minetest.add_item({x=pos.x+math.random()-0.5,y=pos.y,z=pos.z+math.random()-0.5},'default:mese_crystal')
    end

end

function demoiselle.step_additional_function(self)
    self.object:set_bone_position("empenagem", {x=0, y=33.5, z=-0.5}, {x=-self._elevator_angle/2.5, y=0, z=self._rudder_angle/2.5})
    if (self.driver_name==nil) and (self.co_pilot==nil) then --pilot or copilot
        return
    end
end

demoiselle.plane_properties = {
	initial_properties = {
	    physical = true,
        collide_with_objects = true,
	    collisionbox = {-1.2, 0, -1.2, 1.2, 2, 1.2}, --{-1,0,-1, 1,0.3,1},
	    selectionbox = {-2, 0, -2, 2, 2, 2},
	    visual = "mesh",
        backface_culling = false,
	    mesh = "demoiselle_body.b3d",
        stepheight = 0.5,
        textures = {"demoiselle_bamboo.png",
                    "demoiselle_black.png", --cabos
                    "demoiselle_black.png", -- cabos empenagem
                    "demoiselle_canvas_structure.png", -- estrutura empenagem
                    "demoiselle_canvas.png", -- entelagem empenagem
                    "demoiselle_black.png", -- banco
                    "demoiselle_bamboo.png", -- estrutura fuselagem
                    "demoiselle_metal2.png", -- estrutura fuselagem
                    "demoiselle_helice.png", --helice
                    "demoiselle_black.png",  --cubo helice
                    "demoiselle_metal.png", -- motor
                    "demoiselle_canvas_structure.png", --nervuras
                    "demoiselle_canvas.png", -- entelagem asas
                    "demoiselle_copper.png", -- tanque
                    "demoiselle_black.png", -- cabeçote motor
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
    _vehicle_name = "Demoiselle",
    _use_camera_relocation = false,
    _seats = {{x=0,y=5,z=2},},
    _seats_rot = {0},  --necessary when using reversed seats
    _have_copilot = false, --wil use the second position of the _seats list
    _max_plane_hp = 50,
    _enable_fire_explosion = false,
    _longit_drag_factor = 0.13*0.13,
    _later_drag_factor = 2.0,
    _wing_angle_of_attack = 2.5,
    _wing_span = 12, --meters
    _min_speed = 3,
    _max_speed = 8,
    _max_fuel = 5,
    _fuel_consumption_divisor = 1600000,
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
    _pitch_intensity = 0.4,
    _yaw_intensity = 20,
    _yaw_turn_rate = 14,
    _elevator_pos = {x=0, y=0, z=0},
    _rudder_pos = {x=0,y=0,z=0},
    _aileron_r_pos = {x=0,y=0,z=0},
    _aileron_l_pos = {x=0,y=0,z=0},
    _color = "#FFFFFF",
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
    _engine_sound = "demoiselle_engine",
    _painting_texture = {"airutils_painting.png",}, --the texture to paint
    _painting_texture_2 = {"airutils_painting_2.png",}, --the texture to paint
    _mask_painting_associations = {},
    _register_parts_method = demoiselle.register_parts_method, --the method to register plane parts
    _destroy_parts_method = demoiselle.destroy_parts_method,
    _plane_y_offset_for_bullet = 1,
    _custom_step_additional_function = demoiselle.step_additional_function,

    get_staticdata = airutils.get_staticdata,
    on_deactivate = airutils.on_deactivate,
    on_activate = airutils.on_activate,
    logic = airutils.logic,
    on_step = airutils.on_step,
    on_punch = airutils.on_punch,
    on_rightclick = airutils.on_rightclick,
}

dofile(minetest.get_modpath("demoiselle") .. DIR_DELIM .. "crafts.lua")
dofile(minetest.get_modpath("demoiselle") .. DIR_DELIM .. "entities.lua")

--
-- items
--

settings = Settings(minetest.get_worldpath() .. "/demoiselle_settings.conf")
local function fetch_setting(name)
    local sname = name
    return settings and settings:get(sname) or minetest.settings:get(sname)
end

local old_entities = {"demoiselle:seat_base","demoiselle:engine"}
for _,entity_name in ipairs(old_entities) do
    minetest.register_entity(":"..entity_name, {
        on_activate = function(self, staticdata)
            self.object:remove()
        end,
    })
end


