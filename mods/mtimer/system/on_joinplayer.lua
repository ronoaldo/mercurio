local m = mtimer


-- When a player joins
--
-- 1. Check if a hard reset was requested and perform it if it was
-- 2. Set default values if not set
-- 3. Set session start timestamp
-- 4. Set “empty” HUD element and write ID to meta data for later use
core.register_on_joinplayer(function(player)
    local meta = player:get_meta()
    local name = player:get_player_name()
    local re = meta:get_int('mtimer:hard_reset_everything')

    -- Forecefully remove all meta data set in the player object that starts
    -- with `mtimer:` prefix (perform the requested reset everything).
    if re > 0 then
        local message = m.translator('All configuration was reset. Server time of the requested: @1', os.date('%c', re))
        for fname,fvalue in pairs(meta:to_table().fields) do
            if fname:sub(1,7) == 'mtimer:' then
                meta:set_string(fname, '')
            end
        end
        core.chat_send_player(name, '[mTimer] '..message)
    end

    -- Set all unset metadata to their defined default values
    for _,def in pairs(m.meta) do
        local current = meta:get_string(def.key)
        if current == '' then meta:set_string(def.key, def.default) end
    end

    -- Always set session start timestamp for using it within the custom timer
    meta:set_string('mtimer:session_start', os.time())

    -- Initially set empty HUD element to store the ID for updates
    meta:set_string('mtimer:hud_id', player:hud_add({
        type = 'text',
        text = '',
        number = '0x000000',
        position = {x=0,y=0},
        alignment = {x=0,y=0},
        size = {x=0,y=0},
        offset = {x=0,y=0}
    }))
end)
