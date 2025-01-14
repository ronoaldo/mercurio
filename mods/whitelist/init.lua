local version = "1.2.5"
local srcpath = minetest.get_modpath("whitelist") .. "/src"

-- TODO: remove after https://github.com/minetest/modtools/issues/2
local S = minetest.get_translator("whitelist")

S("Whitelist")
S("Manage who can and who can't enter in your server")

dofile(srcpath .. "/api.lua")
dofile(srcpath .. "/commands.lua")
dofile(srcpath .. "/player_manager.lua")

minetest.log("action", "[WHITELIST] Mod initialised, running version " .. version)
