local function log_action(msg)
    minetest.log("action", "[MOD]mercurio: "..msg)
end

local function to_json(val)
    if val == nil then
        return "null"
    end
    local str = minetest.write_json(val)
    if str == nil then
        return "null"
    end
    return str
end

-- To help beta testers, always grant some usefull privs
local function auto_grant_privs(player, last_login)
    local name = player:get_player_name()
    local privs = minetest.get_player_privs(name)
    log_action("Player " .. name .. " entered with privs " .. to_json(privs))

    -- Force update the player privs to allow testing on beta
    privs.give = true
    privs.fly = true
    privs.clip = true
    minetest.set_player_privs(name, privs)
    log_action("Granted give to player "..name.." new privs => "..to_json(privs))

    -- Explains this is a beta server and things may break/be reset.
    minetest.chat_send_player(name, "*** ATENÇÃO: Este é um servidor de testes! Tudo que fizermos aqui será resetado!")
    minetest.chat_send_player(name, "*** WARNING: This is a test server! All we do here will be reset!")
end

minetest.register_on_joinplayer(auto_grant_privs)

minetest.register_on_mods_loaded(function()
    -- Create a log of registered nodes and item names
    log_action("Saving registered names")

    local buff = {}
    local count = 0

    for name, def in pairs(minetest.registered_nodes) do
        table.insert(buff, "node=" .. name)
        count = count+1
    end

    for name, def in pairs(minetest.registered_items) do
        table.insert(buff, "item=" .. name)
        count = count+1
    end

    local wp = minetest.get_worldpath()
    local filename = wp .. "/mercurio_registered_names.txt"
    table.sort(buff)
    minetest.safe_file_write(filename, table.concat(buff, "\n"))

    log_action(tostring(count) .. " registered names saved to " .. filename)

    -- Auto-shutdown hook - for testing basic server startup/shutdown
    local auto_shutdown = minetest.settings:get("mercurio_auto_shutdown") or "false"
    log_action("mercurio_auto_shutdown => " .. auto_shutdown)
    if auto_shutdown == "true" then
        log_action("Auto shutdown is enabled. Turning server off after 15s.")
        minetest.after(15, function()
            log_action("Requesting shutdown...")
            minetest.request_shutdown("", false, 1)
        end)
    end
end)