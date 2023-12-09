local function on_chat_message(name, message)
    message = minetest.strip_colors(message)
    local _, count = message:gsub("<@.+>", "")
    local _, count2 = message:gsub("@.+", "")
    if (count and count >= 1) or message:find("discord.gg") or (count2 and count2 >= 1) then
        minetest.chat_send_player(
            name,
            minetest.colorize("red", "sorry, pinging discord users or roles is disallowed")
        )
        return true
    else
        return false
    end
end

table.insert(minetest.registered_on_chat_messages, 1, on_chat_message)