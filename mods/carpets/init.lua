local modpath = minetest.get_modpath(minetest.get_current_modname())
local S = minetest.get_translator("carpets")
dofile(modpath .. "/api.lua")

if minetest.get_modpath("wool") then
	local nodes = {
		{name="wool:black", description=S("Black Carpet")},
		{name="wool:blue", description=S("Blue Carpet")},
		{name="wool:brown", description=S("Brown Carpet")},
		{name="wool:cyan", description=S("Cyan Carpet")},
		{name="wool:dark_green", description=S("Dark Green Carpet")},
		{name="wool:dark_grey", description=S("Dark Grey Carpet")},
		{name="wool:green", description=S("Green Carpet")},
		{name="wool:grey", description=S("Grey Carpet")},
		{name="wool:magenta", description=S("Magenta Carpet")},
		{name="wool:orange", description=S("Orange Carpet")},
		{name="wool:pink", description=S("Pink Carpet")},
		{name="wool:red", description=S("Red Carpet")},
		{name="wool:violet", description=S("Violet Carpet")},
		{name="wool:white", description=S("White Carpet")},
		{name="wool:yellow", description=S("Yellow Carpet")},
	}
	for _, node in ipairs(nodes) do
		carpets.register(node.name, {description=node.description})
	end
end
