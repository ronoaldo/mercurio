local m = mtimer
local deserialize = core.deserialize
local cs = core.chat_send_player
local S = m.translator


-- Calculate HUD positions and offsets
--
-- Based on the given named position a table of positional tables is returned
-- by this helper function. When an invalid named position is provided all
-- tables only contain 0 values. Valid positions shown in the diagram below.
--
--   +--------------------------------+
--   | tl            tc            tr |
--   |                                |
--   |                                |
--   | ml            mc            mr |
--   |                                |
--   |                                |
--   | bl            bc            br |
--   +--------------------------------+
--
-- For orientation: `mc` is the center of the screen (where the crosshair is).
--                  `bc` is the location of the hotbar and health bars, etc.
--                  Both are valid positions but should not be used.
--
-- Provided offsets will be added or substracted according to the position. In
-- result the pffset behaves like a border
--
-- @param pos A positional string as described
-- @param poffset An offset table like { x=1, y=1 }
-- @return table a Table containing the positional tables based on the string
local get_hud_positions = function (pos, offset)
    local p = { x = 0, y = 0 }
    local a = { x = 0, y = 0 }
    local o = { x = 0, y = 0 }

    if pos == 'tl' then
        p = { x = 0, y = 0 }
        a = { x = 1, y = 1 }
        o = { x = 5 + offset.x, y = 3 + offset.y }
    end
    if pos == 'tc' then
        p = { x = 0.5, y = 0 }
        a = { x = 0, y = 1 }
        o = { x = 0 - offset.x, y = 3 + offset.y }
    end
    if pos == 'tr' then
        p = { x = 1, y = 0 }
        a = { x=-1, y = 1 }
        o = { x = -6 - offset.x, y = 3 + offset.y }
    end
    if pos == 'ml' then
        p = { x = 0,  y = 0.5 }
        a = { x = 1, y = 0 }
        o = { x = 5 + offset.x, y = 0 + offset.y }
    end
    if pos == 'mc' then
        p = { x = 0.5,y = 0.5 }
        a = { x = 0, y = 0 }
        o = { x = 0 + offset.x, y = 0 + offset.y }
    end
    if pos == 'mr' then
        p = { x = 1, y = 0.5 }
        a = { x = -1,y = 0 }
        o = { x = -6 - offset.x, y = 0 + offset.y }
    end
    if pos == 'bl' then
        p = { x = 0, y = 1 }
        a = { x = 1, y = -1 }
        o = { x = 5 + offset.x, y = 0 - offset.y }
    end
    if pos == 'bc' then
        p = { x = 0.5, y = 1 }
        a = { x = 0, y = -1 }
        o = { x = 0 + offset.x, y = 0 - offset.y }
    end
    if pos == 'br' then
        p = { x = 1, y = 1 }
        a = { x = -1, y = -1 }
        o = { x = -6 - offset.x, y = 0 - offset.y }
    end

    return { position = p, alignment = a, offset = o }
end


-- Update the timer
--
-- This function updates the timer for the given player referenced by the
-- player’s name. The function is called when a formspec update (fields) is
-- sent to the server and is automatically called by the registered globalstep.
--
-- The function sets the needed values based on the player meta data and uses
-- the `mtimer.get_timer_data` function for the actual data to be shown.
--
-- @param player_name Name of the player to update the timer for
-- @return void
mtimer.update_timer = function (player_name)
    local player = core.get_player_by_name(player_name)
    local meta = player:get_meta()
    local m = m.meta
    local hud_id = meta:get_string('mtimer:hud_id')

    local text = mtimer.get_timer_data(player_name).formatted
    local number = meta:get_string(m.color.key):gsub('#', '0x')
    local scale = meta:get_string(m.hud_element_scale.key)

    local position = meta:get_string(m.position.key)
    local offset = deserialize(meta:get_string(m.hud_element_offset.key))
    local orientation = get_hud_positions(position, offset)

    if meta:get_string(m.visible.key) == 'false' then text = '' end

    player:hud_change(hud_id, 'text', text)
    player:hud_change(hud_id, 'number', number)
    player:hud_change(hud_id, 'position', orientation.position)
    player:hud_change(hud_id, 'alignment', orientation.alignment)
    player:hud_change(hud_id, 'size', {x=scale, y=scale})
    player:hud_change(hud_id, 'offset', orientation.offset)
end


-- Update the custom timer
--
-- This function handles updates for the custom timer for the player referenced
-- by the provided `name` parameter. This needs to be a player name string.
--
-- The update is performed based on the provided table.
--
--   update_parameters = {
--     action = 'the_action'
--   }
--
-- Currently the only actions are `start`, `stop`, and `restart`.
--
-- @param player_name The name of the player to update the custom timer for
-- @param update_parameters The update parameters table as described
mtimer.update_custom_timer = function (player_name, update_parameters)
    local up = update_parameters or {}
    local player = core.get_player_by_name(player_name)
    local player_meta = player:get_meta()
    local current_timestamp = os.time(os.date('!*t'))
    local ctv_key = m.meta.custom_timer_settings.key
    local ctv = core.deserialize(player_meta:get_string(ctv_key))

    -- Start timer if not running
    if up.action == 'start' then
        if ctv.running ~= true then
            ctv.running = true
            ctv.start_timestamp = current_timestamp
            cs(player_name, S('The custom timer was started'))
        else
            cs(player_name, S('The custom timer is already running'))
        end
    end

    -- Stop timer if running
    if up.action == 'stop' then
        if ctv.running ~= false then
            ctv.running = false
            ctv.start_timestamp = 0
            cs(player_name, S('The custom timer was stopped'))
        else
            cs(player_name, S('The custom timer is not running'))
        end
    end

    -- Restart timer
    if up.action == 'restart' then
        if ctv.running == true then
            ctv.start_timestamp = current_timestamp
            cs(player_name, S('The custom timer was restarted'))
        else
            cs(player_name, S('The custom timer is not running'))
        end
    end

    -- Write timer update to player meta data
    player_meta:set_string(ctv_key, core.serialize(ctv))
end

