
local last_formname, last_formspec, last_playername
local old_show_formspec = minetest.show_formspec
function minetest.show_formspec(playername, formname, formspec)
    last_formname = formname
    last_formspec = formspec
    last_playername = playername
    return old_show_formspec(playername, formname, formspec)
end


mtt.register("Promise.formspec", function(callback)
    assert(type(minetest.registered_on_player_receive_fields) == "table")

    local player = {
        get_player_name = function() return "singleplayer" end
    }

    Promise.formspec("singleplayer", "stuff[]")
    :next(function(fields)
        assert(fields.x == 1)
        callback()
    end)

    assert(last_formname)
    assert(last_formspec == "stuff[]")
    assert(last_playername == "singleplayer")

    for _, fn in ipairs(minetest.registered_on_player_receive_fields) do
        fn(player, last_formname, { x=1, quit="true" })
    end
end)
