local muted = {}
minetest.register_chatcommand("shadowmute", {
    privs = {server = true},
    func = function(name, param)
        if not minetest.get_player_by_name(param) then
            return false, "player is not online/ does not exist"
        end
        muted[param] = true
        return true, param .. " was shadow muted"
    end,
})

minetest.register_chatcommand("mute", {
    privs = {server = true},
    func = function(name, param)
        local target, time = param:match("(%S+)%s+(.+)")
        if not target and not time then
            return false, "target or time not given"
        elseif not minetest.get_player_by_name(target) then
            return false, "player is not online/ does not exist"
        end
        if not tonumber(time) then
            return false, "time is not a number"
        end
        muted[target] = true
        minetest.after(time*60, function()
            muted[target] = nil
        end)
        return true, param .. " was muted for " .. time .. " minutes"
    end,
})

minetest.register_chatcommand("unshadowmute", {
    privs = {server = true},
    func = function(name, param)
        if not minetest.get_player_by_name(param) then
            return true, "player is not online/ does not exist"
        end
        muted[param] = nil
        return true, param .. " was unmuted"
    end,
})

minetest.register_chatcommand("unmute", {
    privs = {server = true},
    func = function(name, param)
        return minetest.registered_chatcommands["unshadowmute"].func(name, param)
    end,
})

local function on_chat_message(name, message)
    if muted[name] then
        --if minetest.global_exists("cloaking") then cloaking.chat.send(name .. "[shadowmuted]: " .. message) end
        minetest.chat_send_player(name, name .. ": " .. message)
        return true
    else
        return false
    end
end

table.insert(minetest.registered_on_chat_messages, 1, on_chat_message)

if minetest.registered_chatcommands["msg"] then
    local old_func = minetest.registered_chatcommands["msg"].func
    minetest.override_chatcommand("msg", {
        func = function(name, param)
            if muted[name] then
                local dest, msg = param:match("^(%S+)%s(.+)$")
                if not dest then
                    return false, "Invalid usage, see /help msg."
                end
                if not minetest.get_player_by_name(dest) then
                    return false, "The player " .. dest .. " is not online."
                end
                if name == dest then
                    minetest.chat_send_player(name, "DM from " .. name .. ": " .. msg)
                end
                return true, "Message sent."
            else
                return old_func(name, param)
            end
        end
    })
end

if minetest.registered_chatcommands["m"] and minetest.registered_chatcommands["msg"] then
    local func = minetest.registered_chatcommands["msg"].func
    minetest.override_chatcommand("m", {
        func = function(name, param)
            return func(name, param)
        end
    })
end