
-- playername -> promise
local joinplayer_promises = {}

minetest.register_on_joinplayer(function(player)
    local playername = player:get_player_name()
    local p = joinplayer_promises[playername]
    if p then
        p:resolve(player)
        joinplayer_promises[playername] = nil
    end
end)

function Promise.joinplayer(playername, timeout)
    local p = joinplayer_promises[playername]
    if not p then
        p = Promise.new()
        joinplayer_promises[playername] = p
    end
    return Promise.race(p, Promise.timeout(timeout or 5))
end

-- playername -> promise
local leaveplayer_promises = {}

minetest.register_on_leaveplayer(function(player)
    local playername = player:get_player_name()
    local p = leaveplayer_promises[playername]
    if p then
        p:resolve(player)
        leaveplayer_promises[playername] = nil
    end
end)

function Promise.leaveplayer(playername, timeout)
    local p = leaveplayer_promises[playername]
    if not p then
        p = Promise.new()
        leaveplayer_promises[playername] = p
    end
    return Promise.race(p, Promise.timeout(timeout or 5))
end
