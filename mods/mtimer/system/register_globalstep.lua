local m = mtimer
local update_timer = m.update_timer
local connected_players = minetest.get_connected_players
local timer = 0


-- The globalstep iterates over all players every second and updates the timers
-- by invoking the `mtimer.update_timer` function that has been localized to
-- `update_timer` for faster access.
minetest.register_globalstep(function(dtime)
    timer = timer + dtime;
    if timer < 1 then return end

    for _,player in pairs(connected_players()) do
        update_timer(player:get_player_name())
    end

    timer = 0
end)
