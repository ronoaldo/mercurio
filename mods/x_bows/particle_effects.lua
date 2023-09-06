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

XBows:register_particle_effect('arrow', {
    amount = 1,
    time = 0.1,
    minexptime = 0.5,
    maxexptime = 0.5,
    minsize = 2,
    maxsize = 2,
    texture = 'x_bows_arrow_particle.png',
    animation = {
        type = 'vertical_frames',
        aspect_w = 8,
        aspect_h = 8,
        length = 1,
    },
    glow = 1,
    minvel = { x = 0, y = -0.1, z = 0 },
    maxvel = { x = 0, y = -0.1, z = 0 },
    minacc = { x = 0, y = -0.1, z = 0 },
    maxacc = { x = 0, y = -0.1, z = 0 }
})

XBows:register_particle_effect('arrow_crit', {
    amount = 1,
    time = 0.1,
    minexptime = 0.5,
    maxexptime = 0.5,
    minsize = 2,
    maxsize = 2,
    texture = 'x_bows_arrow_particle.png^[colorize:#B22222:127',
    animation = {
        type = 'vertical_frames',
        aspect_w = 8,
        aspect_h = 8,
        length = 1,
    },
    glow = 1,
    minvel = { x = 0, y = -0.1, z = 0 },
    maxvel = { x = 0, y = -0.1, z = 0 },
    minacc = { x = 0, y = -0.1, z = 0 },
    maxacc = { x = 0, y = -0.1, z = 0 }
})

XBows:register_particle_effect('arrow_fast', {
    amount = 1,
    time = 0.1,
    minexptime = 0.5,
    maxexptime = 0.5,
    minsize = 2,
    maxsize = 2,
    texture = 'x_bows_arrow_particle.png^[colorize:#0000FF:64',
    animation = {
        type = 'vertical_frames',
        aspect_w = 8,
        aspect_h = 8,
        length = 1,
    },
    glow = 1,
    minvel = { x = 0, y = -0.1, z = 0 },
    maxvel = { x = 0, y = -0.1, z = 0 },
    minacc = { x = 0, y = -0.1, z = 0 },
    maxacc = { x = 0, y = -0.1, z = 0 }
})

XBows:register_particle_effect('bubble', {
    amount = 1,
    time = 1,
    minvel = { x = 1, y = 1, z = 0 },
    maxvel = { x = 1, y = 1, z = 0 },
    minacc = { x = 1, y = 1, z = 1 },
    maxacc = { x = 1, y = 1, z = 1 },
    minexptime = 0.2,
    maxexptime = 0.5,
    minsize = 0.5,
    maxsize = 1,
    texture = 'x_bows_bubble.png'
})
