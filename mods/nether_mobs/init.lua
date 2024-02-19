local modname = minetest.get_current_modname()
local modpath = minetest.get_modpath(modname)

nethermobs                   = {}
nethermobs.NETHERMAN_ENABLED = true
nethermobs.DRAGON_ENABLED    = true

--spawn heights - use numbers corresponding to -31000 < y < 31000 or use nether.DEPTH_CEILING and nether.FLOOR_CEILING to adapt to the position of the Nether layer
--spawn heights for the netherman
nethermobs.MAX_HEIGHT_NETHERMAN = nether.DEPTH_CEILING
nethermobs.MIN_HEIGHT_NETHERMAN = nether.FLOOR_CEILING
--spawn heights for the dragon
nethermobs.MAX_HEIGHT_DRAGON = nether.DEPTH_CEILING
nethermobs.MIN_HEIGHT_DRAGON = nether.FLOOR_CEILING

--nethermobs.NETHERMAN_SPAWN_ONLY_IN_NETHER = true
--nethermobs.DRAGON_SPAWN_ONLY_IN_NETHER = true

-- Override default settings with values from the .conf file, if any are present.
nethermobs.NETHERMAN_ENABLED       = minetest.settings:get_bool("nethermobs.netherman_enabled", nethermobs.NETHERMAN_ENABLED)
nethermobs.DRAGON_ENABLED          = minetest.settings:get_bool("nethermobs.dragon_enabled", nethermobs.DRAGON_ENABLED)

minetest.log("action", "[MOD] Nethermobs loaded")
minetest.log("info", "[MOD] Nethermobs: nethermobs.NETHERMAN_ENABLED: "..tostring(nethermobs.NETHERMAN_ENABLED))
minetest.log("info", "[MOD] Nethermobs: nethermobs.DRAGON_ENABLED: "..tostring(nethermobs.DRAGON_ENABLED))

if nethermobs.NETHERMAN_ENABLED then
        -- Nether Man # 129 code lines
        dofile(modpath.."/netherman.lua")
end

if nethermobs.DRAGON_ENABLED then
        -- Nether Dragon # 657 code lines
        dofile(modpath.."/dragon.lua")
end

-- please read README.md
