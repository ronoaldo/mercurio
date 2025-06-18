--[[
    X Bows. Adds bow and arrows with API.
    Copyright (C) 2025 SaKeL

    This library is free software; you can redistribute it and/or
    modify it under the terms of the GNU Lesser General Public
    License as published by the Free Software Foundation; either
    version 2.1 of the License, or (at your option) any later version.

    This library is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
    Lesser General Public License for more details.

    You should have received a copy of the GNU Lesser General Public
    License along with this library; if not, write to juraj.vajda@gmail.com
--]]

core.register_on_mods_loaded(function()
    if core.get_modpath('bones') and core.global_exists('bones') then
        table.insert_all(bones.player_inventory_lists, { 'x_bows:arrow_inv', 'x_bows:quiver_inv' })

        core.register_on_dieplayer(function(player, reason)
            -- try to make sure this is called last in the `on_dieplayer` callback stack
            core.after(0, function(v_player)
                -- when quiver is being removed from inventory we need to reset the inv page
                if XBows.i3 then
                    i3.set_fs(player)
                elseif XBows.unified_inventory then
                    unified_inventory.set_inventory_formspec(v_player, 'x_bows:quiver_page')
                else
                    sfinv.set_player_inventory_formspec(v_player)
                end
            end, player)
        end)
    end
end)
