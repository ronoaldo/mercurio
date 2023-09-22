local MP = minetest.get_modpath(minetest.get_current_modname())
local bootstrap = loadfile(MP.."/bootstrap.lua")()
mtzip = bootstrap(MP)

if minetest.get_modpath("mtt") then
    dofile(MP .. "/mtt.lua")
end