local MP = minetest.get_modpath(minetest.get_current_modname())

mtzip = {
    api_version = 1
}

dofile(MP.."/common.lua")
dofile(MP.."/crc32.lua")
dofile(MP.."/unzip.lua")
dofile(MP.."/zip.lua")

if minetest.get_modpath("mtt") then
    dofile(MP .. "/mtt.lua")
end