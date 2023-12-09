local version = "1.2.3"

dofile(minetest.get_modpath("whitelist") .. "/api.lua")
dofile(minetest.get_modpath("whitelist") .. "/chatcmdbuilder.lua")
dofile(minetest.get_modpath("whitelist") .. "/commands.lua")
dofile(minetest.get_modpath("whitelist") .. "/player_manager.lua")

minetest.log("action", "[WHITELIST] Mod initialised, running version " .. version)
