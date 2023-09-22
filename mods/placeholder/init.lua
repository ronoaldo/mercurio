local MP = minetest.get_modpath("placeholder")

placeholder = {}

dofile(MP.."/placeholder.lua")

if minetest.get_modpath("mtt") and mtt.enabled then
	dofile(MP .. "/mtt.lua")
end