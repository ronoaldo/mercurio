--[[
Allows players to request from another player to be teleported to them, and do much more.
Copyright (C) 2014-2022 ChaosWormz and contributors

This library is free software; you can redistribute it and/or
modify it under the terms of the GNU Lesser General Public
License as published by the Free Software Foundation; either
version 2.1 of the License, or (at your option) any later version.

This library is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
Lesser General Public License for more details.

You should have received a copy of the GNU Lesser General Public
License along with this library; if not, write to the Free Software
Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301
USA

----------------------------------------------------------------------------

Originally made by Traxie21 and released with the WTFPL license.
Forum link: https://forum.minetest.net/viewtopic.php?id=4457

Updates by Zeno, Panquesito7 and ChaosWormz.
License: LGPLv2.1+ for code, CC BY-SA 4.0 for sounds.
--]]

-- Load support for intllib.
local MP = minetest.get_modpath(minetest.get_current_modname())
local S = dofile(MP.."/intllib.lua")

tp = {
	intllib = S,
	tpr_list = {},
	tphr_list = {},
	tpc_list = {},
	tpn_list = {}
}

-- Clear requests when the player leaves
minetest.register_on_leaveplayer(function(name)
	if tp.tpr_list[name] then
		tp.tpr_list[name] = nil
		return
	end

	if tp.tphr_list[name] then
		tp.tphr_list[name] = nil
		return
	end

	-- Area requests
	if tp.tpc_list[name] then
		tp.tpc_list[name] = nil
		return
	end

	if tp.tpn_list[name] then
		tp.tpn_list[name] = nil
		return
	end
end)

dofile(MP.."/privileges.lua")
dofile(MP.."/config.lua")
dofile(MP.."/functions.lua")
dofile(MP.."/commands.lua")

-- Log
if minetest.settings:get_bool("log_mods") then
	minetest.log("action", S("[Teleport Request] TPS Teleport v@1 Loaded!", tp.version))
end
