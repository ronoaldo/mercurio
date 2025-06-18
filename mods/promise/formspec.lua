-- playername -> { id => { promise, callback} }
local formspec_promises = {}

minetest.register_on_leaveplayer(function(player)
    local playername = player:get_player_name()
    formspec_promises[playername] = nil
end)

minetest.register_on_player_receive_fields(function(player, id, fields)
    local playername = player:get_player_name()
    local cb_map = formspec_promises[playername]
    if not cb_map then
        return false
    end

    local data = cb_map[id]
    if not data then
        return false
    end

    if fields.quit == "true" then
        -- "quit" event, resolve promise
        data.promise:resolve(fields)
    else
        -- other events (scrollbar, dropdown, etc) formspec is still open
        if type(data.callback) == "function" then
            data.callback(fields)
        end
        return true
    end


    -- cleanup
    cb_map[id] = nil
    return true
end)

function Promise.formspec(playername, formspec, callback)
    local p = Promise.new()
    local id = "promise_" .. math.floor(math.random() * 100000)

    local cb_map = formspec_promises[playername]
    if not cb_map then
        -- create callback map
        cb_map = {}
        formspec_promises[playername] = cb_map
    end
    cb_map[id] = {
        promise = p,
        callback = callback
    }
    minetest.show_formspec(playername, id, formspec)
    return p
end
