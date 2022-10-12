
-- Load support for intllib.
local path = minetest.get_modpath(minetest.get_current_modname()) .. "/"

local S = minetest.get_translator and minetest.get_translator("nativevillages") or
		dofile(path .. "intllib.lua")

mobs.intllib = S


-- Check for custom mob spawn file
local input = io.open(path .. "spawn.lua", "r")

if input then
	mobs.custom_spawn_nativevillages = true
	input:close()
	input = nil
end


-- Buildings


dofile(path .. "cannibalblocks.lua") --
dofile(path .. "savannablocks.lua") --
dofile(path .. "arcticblocks.lua") --
dofile(path .. "grasslandblocks.lua") --
dofile(path .. "lakeblocks.lua") --
dofile(path .. "desertblocks.lua") --
dofile(path .. "junglebuildings.lua") --
dofile(path .. "icebuildings.lua") --
dofile(path .. "grasslandbuildings.lua") --
dofile(path .. "lakebuildings.lua") --
dofile(path .. "desertbuildings.lua") --
dofile(path .. "savannabuildings.lua") --
dofile(path .. "grasslandcreatures.lua") --
dofile(path .. "junglecreatures.lua") --
dofile(path .. "arcticcreatures.lua") --
dofile(path .. "savannacreatures.lua") --
dofile(path .. "lakecreatures.lua") --
dofile(path .. "desertcreatures.lua") --
dofile(path .. "slavecreatures.lua") --
dofile(path .. "buyablestuff.lua") --
dofile(path .. "explodingtoad.lua") --
dofile(path .. "hunger.lua") --


-- Load custom spawning
if mobs.custom_spawn_nativevillages then
	dofile(path .. "spawn.lua")
end



print (S("[MOD] Buildings loaded"))
