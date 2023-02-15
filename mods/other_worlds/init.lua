local modpath = minetest.get_modpath("other_worlds") .. DIR_DELIM

otherworlds = {}

dofile(modpath .. "settings.lua")
dofile(modpath .. "mars_plants.lua")
dofile(modpath .. "crystals.lua")
dofile(modpath .. "space_nodes.lua")
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
