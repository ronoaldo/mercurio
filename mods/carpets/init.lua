local modpath = minetest.get_modpath(minetest.get_current_modname())
local S = minetest.get_translator("carpets")
dofile(modpath .. "/api.lua")

if minetest.get_modpath("wool") then
	local nodes = {
		{name="wool:black", description=S("Black carpet")},
		{name="wool:blue", description=S("Blue carpet")},
		{name="wool:brown", description=S("Brown carpet")},
		{name="wool:cyan", description=S("Cyan carpet")},
		{name="wool:dark_green", description=S("Dark green carpet")},
		{name="wool:dark_grey", description=S("Dark grey carpet")},
		{name="wool:green", description=S("Green carpet")},
		{name="wool:grey", description=S("Grey carpet")},
		{name="wool:magenta", description=S("Magenta carpet")},
		{name="wool:orange", description=S("Orange carpet")},
		{name="wool:pink", description=S("Pink carpet")},
		{name="wool:red", description=S("Red carpet")},
		{name="wool:violet", description=S("Violet carpet")},
		{name="wool:white", description=S("White carpet")},
		{name="wool:yellow", description=S("Yellow carpet")},
	}
	for _, node in ipairs(nodes) do
		carpets.register(node.name, {description=node.description})
	end
end
