-- alpha_workaround/init.lua
-- Fix rendering issues on client 5.9 caused by boolean values of use_texture_alpha
--[[
  Copyright (C) 2024  1F616EMO

  This program is free software: you can redistribute it and/or modify
  it under the terms of the GNU Affero General Public License as published by
  the Free Software Foundation, either version 3 of the License, or
  (at your option) any later version.

  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU Affero General Public License for more details.

  You should have received a copy of the GNU Affero General Public License
  along with this program.  If not, see <https://www.gnu.org/licenses/>.
]]

if not minetest.features.use_texture_alpha_string_modes then
    error("[alpha_workaround] This version of Minetest Engine does not support string mode alpha.")
end

-- According to https://github.com/minetest/minetest/pull/10819
local value_map   = {}

value_map.normal  = { "clip", "opaque" }
value_map.other   = { "blend", "clip" }
value_map.nodebox = { "blend", "opaque" }
value_map.mesh    = value_map.nodebox

local defaults    = {
    normal        = "opaque",
    other         = "clip",
    nodebox       = "clip", -- Adopting old client value
    mesh          = "clip",
    liquid        = "opaque",
    flowingliquid = "opaque"
}

minetest.register_on_mods_loaded(function()
    for name, def in pairs(minetest.registered_nodes) do
        local alpha_type = type(def.use_texture_alpha)
        if alpha_type ~= "string" then
            local drawtype = def.drawtype or "normal"
            local alpha

            if alpha_type == "boolean" then
                alpha = (value_map[drawtype] or value_map.other)[def.use_texture_alpha and 1 or 2]
                minetest.log("warning", "[alpha_workaround] Node " .. name .. " is using boolean use_texture_alpha, " ..
                    "assuming use_texture_alpha = " .. alpha)
            elseif (drawtype == "liquid" or drawtype == "flowingliquid") and def.alpha then
                alpha = def.alpha == 255 and "opaque" or "blend"
                minetest.log("warning", "[alpha_workaround] Node " .. name .. " is using the alpha field, " ..
                    "assuming use_texture_alpha = " .. alpha)
            else
                -- DAMN, we cannot detect texture transparency
                -- So we apply defaults no matter what
                alpha = defaults[drawtype] or defaults.other
            end

            minetest.override_item(name, {
                use_texture_alpha = alpha
            })
        end
    end
end)
