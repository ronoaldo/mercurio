etherium_stuff = {}

local modpath=minetest.get_modpath("etherium_stuff")

-- Intllib
local S
if minetest.global_exists("intllib") then
	if intllib.make_gettext_pair then
		-- New method using gettext.
		S = intllib.make_gettext_pair()
	else
		-- Old method using text files.
		S = intllib.Getter()
	end
else
	S = function(s) return s end
end
etherium_stuff.intllib = S

dofile(minetest.get_modpath("etherium_stuff").."/torch.lua")
dofile(minetest.get_modpath("etherium_stuff").."/crafting.lua")
dofile(minetest.get_modpath("etherium_stuff").."/water.lua")
dofile(minetest.get_modpath("etherium_stuff").."/nodes.lua")
dofile(minetest.get_modpath("etherium_stuff").."/stairs.lua")
dofile(minetest.get_modpath("etherium_stuff").."/lucky_block.lua")
