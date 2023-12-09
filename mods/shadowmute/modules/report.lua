minetest.register_chatcommand("report", {
    description = "report ",
    func = function(name, param)
        if param == "" then return false, "you are missing something to report" end

        for _, player in pairs(minetest.get_connected_players()) do
            if minetest.check_player_privs(player, "kick") then
                minetest.chat_send_player(
                    player:get_player_name(),
                    minetest.colorize("yellow", name .. " reports: " .. param)
                )
            end
        end

        local data = {
            content = nil,
            embeds = {{
                title = name .. " reports:",
                description = param,
                color = 5763719
            }}
        }

        shadowmute.send_discord_message(data)

        return true, "your message has been reported"
    end,
})