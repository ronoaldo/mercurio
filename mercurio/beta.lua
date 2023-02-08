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