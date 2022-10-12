dofile(minetest.get_modpath("trike") .. DIR_DELIM .. "trike_global_definitions.lua")

--------------
-- Manual --
--------------

function trike.getPlaneFromPlayer(player)
    local seat = player:get_attach()
    if seat then
        local plane = seat:get_attach()
        return plane
    end
    return nil
end

function trike.pilot_formspec(name)
    local basic_form = table.concat({
        "formspec_version[3]",
        "size[6,4.5]",
	}, "")

	basic_form = basic_form.."button[1,1.0;4,1;go_out;Go Offboard]"
	basic_form = basic_form.."button[1,2.5;4,1;hud;Show/Hide Gauges]"

    minetest.show_formspec(name, "trike:pilot_main", basic_form)
end

minetest.register_on_player_receive_fields(function(player, formname, fields)
	if formname == "trike:pilot_main" then
        local name = player:get_player_name()
        local plane_obj = trike.getPlaneFromPlayer(player)
        if plane_obj == nil then
            minetest.close_formspec(name, "trike:pilot_main")
            return
        end
        local ent = plane_obj:get_luaentity()
        if fields.hud then
            if ent._show_hud == true then
                ent._show_hud = false
            else
                ent._show_hud = true
            end
        end
		if fields.go_out then
            -- eject passenger if the plane is on ground
            local touching_ground, liquid_below = trike.check_node_below(plane_obj)
            if ent.isinliquid or touching_ground or liquid_below then --isn't flying?
                if ent._passenger then
                    local passenger = minetest.get_player_by_name(ent._passenger)
                    if passenger then trike.dettach_pax(ent, passenger) end
                end
            end
            trike.dettachPlayer(ent, player)
		end
        minetest.close_formspec(name, "trike:pilot_main")
    end
end)
