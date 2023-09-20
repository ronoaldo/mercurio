--[[
    X Bows. Adds bow and arrows with API.
    Copyright (C) 2023 SaKeL <juraj.vajda@gmail.com>

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

XBows:register_entity('arrow_entity', {
    initial_properties = {
        visual = 'mesh',
        mesh = 'x_bows_arrow.b3d',
        textures = { 'x_bows_arrow_mesh.png' },
    },
    _custom = {
        animations = {
            idle = { { x = 41, y = 42 }, 0, 0, false },
            on_hit_node = { { x = 1, y = 40 }, 40, 0, false }
        }
    }
})
