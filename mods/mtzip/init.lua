local MP = minetest.get_modpath(minetest.get_current_modname())

local includes = {
    "common.lua",
    "crc32.lua",
    "unzip.lua",
    "zip.lua"
}

for _, filename in ipairs(includes) do
    dofile(MP .. "/" .. filename)
    if minetest.register_mapgen_script then
        minetest.register_mapgen_script(MP .. "/" .. filename)
    end
end

if minetest.get_modpath("mtt") then
    dofile(MP .. "/mtt.lua")
    if minetest.register_mapgen_script then
        minetest.register_mapgen_script(MP .. "/mtt.async.lua")
    end
end