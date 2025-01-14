
-- global, mod path and load mod sections

otherworlds = {}

local modpath = minetest.get_modpath("other_worlds") .. "/"

dofile(modpath .. "settings.lua")
dofile(modpath .. "nodes.lua")
dofile(modpath .. "crafting.lua")
dofile(modpath .. "skybox.lua")

-- required helpers for mapgen options below

dofile(modpath .. "asteroid_layer_helpers.lua")

if otherworlds.settings.space_asteroids.enable then
	dofile(modpath .. "space_asteroids.lua")
end

if otherworlds.settings.redsky_asteroids.enable then
	dofile(modpath .. "redsky_asteroids.lua")
end


print("[MOD] Other Worlds loaded")
