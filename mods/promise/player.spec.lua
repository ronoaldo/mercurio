if minetest.get_modpath("fakelib") then
    mtt.register("Promise.leaveplayer/joinplayer", function()
        return Promise.async(function(await)
            local joinedplayer = nil
            local leftplayer = nil

            Promise.joinplayer("singleplayer"):next(function(player)
                joinedplayer = player
            end)
            Promise.leaveplayer("singleplayer"):next(function()
                leftplayer = true
            end)

            assert(not joinedplayer)
            assert(not leftplayer)

            local player = mtt.join_player("singleplayer")
            await(Promise.after(0)) -- next step

            assert(joinedplayer == player)
            assert(not leftplayer)

            mtt.leave_player("singleplayer")
            await(Promise.after(0)) -- next step

            assert(joinedplayer == player)
            assert(leftplayer == true)
        end)
    end)
end