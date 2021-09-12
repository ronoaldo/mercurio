minetest.register_on_punchplayer(function(player, hitter, time_from_last_punch, tool_capabilities, dir, damage)
    if not hitter:is_player() or not player:is_player() then
        return
    end

    local pvp_center = minetest.setting_get_pos("pvp_area_center")
    local pvp_size   = minetest.settings:get("pvp_area_size")

    local pos = player:get_pos()
    local bound_x = pos.x <= (pvp_center.x-pvp_size) or pos.x >= (pvp_center.x+pvp_size)
    local bound_y = pos.y <= (pvp_center.y-pvp_size) or pos.y >= (pvp_center.y+pvp_size)
    local bound_z = pos.z <= (pvp_center.z-pvp_size) or pos.z >= (pvp_center.z+pvp_size)

    if bound_x or bound_y or bound_z then
        minetest.chat_send_player(hitter:get_player_name(), "Fora da area PVP!")
        return true
    end
    return
end)

minetest.log("info", "[mercurio-mod] Loaded")