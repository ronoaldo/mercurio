t_uses = {}
local tool_wear_enabled = minetest.settings:get_bool("enable_tool_wear")
if tool_wear_enabled == nil then
	-- Default is enabled
	tool_wear_enabled = true
end

if tool_wear_enabled then
	t_uses.twenty = 20
else
	t_uses.twenty = 0
end


dofile(minetest.get_modpath("tools_obsidian").."/sword.lua")
dofile(minetest.get_modpath("tools_obsidian").."/tools.lua")

minetest.register_alias("sword_obsidian", "tools_obsidian:sword_obsidian")
minetest.register_alias("longsword_obsidian", "tools_obsidian:longsword_obsidian")
minetest.register_alias("dagger_obsidian", "tools_obsidian:dagger_obsidian")
minetest.register_alias("pick_obsidian", "tools_obsidian:pick_obsidian")