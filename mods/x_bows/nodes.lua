--[[
    X Bows. Adds bow and arrows with API.
    Copyright (C) 2025 SaKeL

    This library is free software; you can redistribute it and/or
    modify it under the terms of the GNU Lesser General Public
    License as published by the Free Software Foundation; either
    version 2.1 of the License, or (at your option) any later version.

    This library is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
    Lesser General Public License for more details.

    You should have received a copy of the GNU Lesser General Public
    License along with this library; if not, write to juraj.vajda@gmail.com
--]]

local S = core.get_translator(core.get_current_modname())

core.register_node('x_bows:target', {
    description = S('Target'),
    short_description = S('Target'),
    tiles = { 'x_bows_target.png' },
    is_ground_content = false,
    groups = { snappy = 3, flammable = 4, fall_damage_add_percent = -30 },
    sounds = core.global_exists('default') and default.node_sound_leaves_defaults() or {},
    mesecons = { receptor = { state = 'off' } },
    ---@param pos Vector
    ---@param elapsed number
    ---@return boolean
    on_timer = function(pos, elapsed)
        if XBows.mesecons then
            mesecon.receptor_off(pos)
        end

        return false
    end,
    on_punch = function(pos, node, puncher, pointed_thing)
        local pt = pointed_thing or {}

        if pt.intersection_normal and pt.intersection_point and (puncher and puncher:is_player()) then
            local p = vector.add(pos, vector.divide(pt.intersection_normal, 1.5))
            local is_blue = false
            local is_red = false
            local is_yellow = false

            if pt.intersection_normal.x == 1 then
                local min_blue = vector.new(p.x - (1/16 * 8), p.y - (1/16 * 7), p.z - (1/16 * 7))
                local max_blue = vector.new(p.x, p.y + (1/16 * 7), p.z + (1/16 * 7))
                local min_red = vector.new(p.x - (1/16 * 8), p.y - (1/16 * 4), p.z - (1/16 * 4))
                local max_red = vector.new(p.x, p.y + (1/16 * 4), p.z + (1/16 * 4))
                local min_yellow = vector.new(p.x - (1/16 * 8), p.y - (1/16 * 1), p.z - (1/16 * 1))
                local max_yellow = vector.new(p.x, p.y + (1/16 * 1), p.z + (1/16 * 1))

                is_blue = vector.in_area(pt.intersection_point, min_blue, max_blue)
                is_red = vector.in_area(pt.intersection_point, min_red, max_red)
                is_yellow = vector.in_area(pt.intersection_point, min_yellow, max_yellow)

            elseif pt.intersection_normal.x == -1 then
                local min_blue = vector.new(p.x, p.y - (1/16 * 7), p.z - (1/16 * 7))
                local max_blue = vector.new(p.x + (1/16 * 8), p.y + (1/16 * 7), p.z + (1/16 * 7))
                local min_red = vector.new(p.x, p.y - (1/16 * 4), p.z - (1/16 * 4))
                local max_red = vector.new(p.x + (1/16 * 8), p.y + (1/16 * 4), p.z + (1/16 * 4))
                local min_yellow = vector.new(p.x, p.y - (1/16 * 1), p.z - (1/16 * 1))
                local max_yellow = vector.new(p.x + (1/16 * 8), p.y + (1/16 * 1), p.z + (1/16 * 1))

                is_blue = vector.in_area(pt.intersection_point, min_blue, max_blue)
                is_red = vector.in_area(pt.intersection_point, min_red, max_red)
                is_yellow = vector.in_area(pt.intersection_point, min_yellow, max_yellow)
            elseif pt.intersection_normal.y == 1 then
                local min_blue = vector.new(p.x - (1/16 * 7), p.y - (1/16 * 8), p.z - (1/16 * 7))
                local max_blue = vector.new(p.x + (1/16 * 7), p.y, p.z + (1/16 * 7))
                local min_red = vector.new(p.x - (1/16 * 4), p.y - (1/16 * 8), p.z - (1/16 * 4))
                local max_red = vector.new(p.x + (1/16 * 4), p.y, p.z + (1/16 * 4))
                local min_yellow = vector.new(p.x - (1/16 * 1), p.y - (1/16 * 8), p.z - (1/16 * 1))
                local max_yellow = vector.new(p.x + (1/16 * 1), p.y, p.z + (1/16 * 1))

                is_blue = vector.in_area(pt.intersection_point, min_blue, max_blue)
                is_red = vector.in_area(pt.intersection_point, min_red, max_red)
                is_yellow = vector.in_area(pt.intersection_point, min_yellow, max_yellow)
            elseif pt.intersection_normal.y == -1 then
                local min_blue = vector.new(p.x - (1/16 * 7), p.y, p.z - (1/16 * 7))
                local max_blue = vector.new(p.x + (1/16 * 7), p.y + (1/16 * 8), p.z + (1/16 * 7))
                local min_red = vector.new(p.x - (1/16 * 4), p.y, p.z - (1/16 * 4))
                local max_red = vector.new(p.x + (1/16 * 4), p.y + (1/16 * 8), p.z + (1/16 * 4))
                local min_yellow = vector.new(p.x - (1/16 * 1), p.y, p.z - (1/16 * 1))
                local max_yellow = vector.new(p.x + (1/16 * 1), p.y + (1/16 * 8), p.z + (1/16 * 1))

                is_blue = vector.in_area(pt.intersection_point, min_blue, max_blue)
                is_red = vector.in_area(pt.intersection_point, min_red, max_red)
                is_yellow = vector.in_area(pt.intersection_point, min_yellow, max_yellow)
            elseif pt.intersection_normal.z == 1 then
                local min_blue = vector.new(p.x - (1/16 * 7), p.y - (1/16 * 7), p.z - (1/16 * 8))
                local max_blue = vector.new(p.x + (1/16 * 7), p.y + (1/16 * 7), p.z)
                local min_red = vector.new(p.x - (1/16 * 4), p.y - (1/16 * 4), p.z - (1/16 * 8))
                local max_red = vector.new(p.x + (1/16 * 4), p.y + (1/16 * 4), p.z)
                local min_yellow = vector.new(p.x - (1/16 * 1), p.y - (1/16 * 1), p.z - (1/16 * 8))
                local max_yellow = vector.new(p.x + (1/16 * 1), p.y + (1/16 * 1), p.z)

                is_blue = vector.in_area(pt.intersection_point, min_blue, max_blue)
                is_red = vector.in_area(pt.intersection_point, min_red, max_red)
                is_yellow = vector.in_area(pt.intersection_point, min_yellow, max_yellow)
            elseif pt.intersection_normal.z == -1 then
                local min_blue = vector.new(p.x - (1/16 * 7), p.y - (1/16 * 7), p.z)
                local max_blue = vector.new(p.x + (1/16 * 7), p.y + (1/16 * 7), p.z + (1/16 * 8))
                local min_red = vector.new(p.x - (1/16 * 4), p.y - (1/16 * 4), p.z)
                local max_red = vector.new(p.x + (1/16 * 4), p.y + (1/16 * 4), p.z + (1/16 * 8))
                local min_yellow = vector.new(p.x - (1/16 * 1), p.y - (1/16 * 1), p.z)
                local max_yellow = vector.new(p.x + (1/16 * 1), p.y + (1/16 * 1), p.z + (1/16 * 8))

                is_blue = vector.in_area(pt.intersection_point, min_blue, max_blue)
                is_red = vector.in_area(pt.intersection_point, min_red, max_red)
                is_yellow = vector.in_area(pt.intersection_point, min_yellow, max_yellow)
            end

            local color
            local w
            local h

            if is_yellow then
                color = '#E7DE21'
                w = 2
                h = 2
            elseif is_red then
                color = '#F1434A'
                w = 8
                h = 8
            elseif is_blue then
                color = '#42C0EE'
                w = 14
                h = 14
            end

            if color then
                -- top vertical
                local image = '[combine:16x16:' .. (16 - w) / 2 .. ',' .. (16 - h) / 2
                    .. '=[combine\\:'.. w .. 'x1\\^[noalpha\\^[colorize\\:' .. color .. '\\:255'
                -- bottom vertical
                image = image ..'^[combine:16x16:' .. (16 - w) / 2 .. ',' .. h + ((16 - h) / 2) - 1
                    .. '=[combine\\:'.. w .. 'x1\\^[noalpha\\^[colorize\\:' .. color .. '\\:255'
                -- left horizontal
                image = image ..'^[combine:16x16:' .. (16 - w) / 2 .. ',' .. (16 - h) / 2
                    .. '=[combine\\:1x' .. h .. '\\^[noalpha\\^[colorize\\:' .. color .. '\\:255'
                -- right horizontal
                image = image ..'^[combine:16x16:'.. w + ((16 - w) / 2) - 1 .. ',' .. (16 - h) / 2
                    .. '=[combine\\:1x' .. h .. '\\^[noalpha\\^[colorize\\:' .. color .. '\\:255'

                core.add_particle({
                    pos = p,
                    velocity = pt.intersection_normal,
                    acceleration = vector.multiply(vector.multiply(pt.intersection_normal, -1), 2),
                    expirationtime = 1,
                    size = 10,
                    texture = {
                        name = image,
                        alpha_tween = {
                            1, 0.25,
                            style = 'fwd',
                            reps = 1
                        }
                    },
                    glow = 14
                })

                local player_pos = puncher:get_pos()
                local player_props = puncher:get_properties()
                local eye_height = player_props.eye_height or 1.625
                local look_dir = puncher:get_look_dir()
                local distance = vector.distance(pt.intersection_point, player_pos)

                if distance >= 15 then
                    core.add_particle({
                        pos = vector.add(
                            -- add eye offset
                            vector.new(player_pos.x, player_pos.y + eye_height, player_pos.z),
                            -- add look dir offset
                            vector.multiply(look_dir, 3)
                        ),
                        velocity = vector.new(),
                        acceleration = vector.new(),
                        expirationtime = 1.5,
                        size = is_yellow and 10 or 5,
                        texture = {
                            name = image,
                            alpha_tween = {
                                0, 1,
                                style = 'fwd',
                                reps = 1
                            },
                            scale_tween = {
                                0, 1,
                                style = 'fwd',
                                reps = 1
                            }
                        },
                        attract = {
                            kind = 'point',
                            strength = 7,
                            origin_attached = puncher,
                            direction_attached = puncher
                        },
                        attached = puncher,
                        glow = 14
                    })
                end
            end
        end
    end
})

core.register_craft({
    type = 'fuel',
    recipe = 'x_bows:target',
    burntime = 3
})

core.register_craft({
    output = 'x_bows:target',
    recipe = {
        { '', 'default:mese_crystal', '' },
        { 'default:mese_crystal', 'farming:straw', 'default:mese_crystal' },
        { '', 'default:mese_crystal', '' },
    }
})
