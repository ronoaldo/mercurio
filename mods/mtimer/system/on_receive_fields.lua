local m = mtimer
local S = mtimer.translator
local d = mtimer.dialog


-- When formspec data is sent to the server check for the formname and run the
-- specific action for the given form. See Individual descriptions. The code
-- for this is very simple because most of the logic is handled in the
-- timer functions and not in the formspec code.
core.register_on_player_receive_fields(function(player, formname, fields)
    if not player:is_player() then return end
    local meta = player:get_meta()
    local name = player:get_player_name()


    -- Select what formspec to show basing on main menu button
    if formname == 'mtimer:main_menu' then
        if fields.set_visibility then d.set_visibility(name) end
        if fields.set_position then d.set_position(name) end
        if fields.set_color then d.set_color(name) end
        if fields.timezone_offset then d.timezone_offset(name) end
        if fields.ingame_time_format then d.ingame_time_format(name) end
        if fields.real_world_time_format then d.real_world_time_format(name) end
        if fields.host_time_format then d.host_time_format(name) end
        if fields.session_start_time_format then
            d.session_start_time_format(name)
        end
        if fields.session_duration_format then
            d.session_duration_format(name)
        end
        if fields.hud_element_scale then d.hud_element_scale(name) end
        if fields.hud_element_offset then d.hud_element_offset(name) end
        if fields.timer_format then d.timer_format(name) end
        if fields.custom_timer then d.custom_timer(name) end
        if fields.reset_everything then d.reset_everything(name) end
    end


    -- Set timer visibility
    if formname == 'mtimer:set_visibility' then
        local attr = m.meta.visible
        if fields.set_visible then meta:set_string(attr.key, 'true') end
        if fields.set_invisible then meta:set_string(attr.key, 'false') end
        if fields.default then meta:set_string(attr.key, attr.default) end
        if not fields.quit then d.set_visibility(name) end
    end


    -- Set timer position
    if formname == 'mtimer:set_position' then
        local attr = m.meta.position
        for p,_ in pairs(fields) do
            if p == 'default' then
                meta:set_string(attr.key, attr.default)
            elseif p:gsub('_.*', '') == 'pos' then
                local new_pos = p:gsub('pos_', '')
                if new_pos ~= 'xx' then meta:set_string(attr.key, new_pos) end
            end
        end
        if not fields.quit then d.set_position(name) end
    end


    -- Set timer text color
    if formname == 'mtimer:set_color' then
        local attr = m.meta.color
        local color = ''

        -- Set fields.color to predefined color if a button was clicked
        if fields.set_color ~= nil then
            fields.color = '#'..fields.set_color
        end

        -- Validate the given color and set it
        if fields.color then
            local valid = fields.color:match('^#'..('[0-9a-fA-F]'):rep(6)..'$')
            local color = valid and fields.color or attr.default
            meta:set_string(attr.key, color)
        end

        if fields.default then meta:set_string(attr.key, attr.default) end
        if not fields.quit then d.set_color(name) end
    end


    -- Configure timezone offset
    if formname == 'mtimer:timezone_offset' then
        local attr = m.meta.timezone_offset
        local value = tonumber(fields.offset) or attr.default

        -- Check if a timezone offset button was clicked
        for p,_ in pairs(fields) do
            if string.sub(p,1,11) == 'new_offset_' then
                value = tonumber((p:gsub('new_offset_', '')))
            end
        end

        -- Validate and set new timezone offset
        if fields.offset then
            if value > 12 then value = 12 end
            if value < -12 then value = -12 end
            meta:set_string(attr.key, value)
        end

        if fields.default then meta:set_string(attr.key, attr.default) end
        if not fields.quit then d.timezone_offset(name) end
    end


    -- Set ingame time format
    if formname == 'mtimer:ingame_time_format' then
        local attr = m.meta.ingame_time_format
        local value = fields.format or attr.default
        meta:set_string(attr.key, value)
        if fields.default then meta:set_string(attr.key, attr.default) end
        if not fields.quit then d.ingame_time_format(name)end
    end


    -- Set real-time format
    if formname == 'mtimer:real_world_time_format' then
        local attr = m.meta.real_time_format
        local value = fields.format or attr.default
        meta:set_string(attr.key, value)
        if fields.default then meta:set_string(attr.key, attr.default) end
        if not fields.quit then d.real_world_time_format(name) end
    end


    -- Set host time format
    if formname == 'mtimer:host_time_format' then
        local attr = m.meta.host_time_format
        local value = fields.format or attr.default
        meta:set_string(attr.key, value)
        if fields.default then meta:set_string(attr.key, attr.default) end
        if not fields.quit then d.host_time_format(name) end
    end


    -- Set session start time format
    if formname == 'mtimer:session_start_time_format' then
        local attr = m.meta.session_start_time_format
        local value = fields.format or attr.default
        meta:set_string(attr.key, value)
        if fields.default then meta:set_string(attr.key, attr.default) end
        if not fields.quit then d.session_start_time_format(name)  end
    end


    -- Set session duration format
    if formname == 'mtimer:session_duration_format' then
        local attr = m.meta.session_duration_format
        local value = fields.format or attr.default
        meta:set_string(attr.key, value)
        if fields.default then meta:set_string(attr.key, attr.default) end
        if not fields.quit then d.session_duration_format(name) end
    end


    -- Set scale of the timer HUD element
    if formname == 'mtimer:hud_element_scale' then
        local attr = m.meta.hud_element_scale
        local value = tonumber(attr.default)
        local nv_data = core.explode_scrollbar_event(fields.new_value)

        -- Set new value if value was changed
        if nv_data.type == 'CHG' then
            value = nv_data.value
            if value < 1 then value = 1 end
            if value > 10 then value = 10 end
            meta:set_string(attr.key, value)
        end

        -- DEVELOPERS: Ideally this formspec would fully reset (like when
        --             closed and re-opened) to reflect the scale position when
        --             clicking the “Default” button. But for whatever reason
        --             this does not work. The scollbar position is simply
        --             not set accordingly no matter what I tried.
        --
        --             A pesky pseudosolution is to accept what it is and just
        --             inform the player about this fact.
        --
        --             Trust me, I tried for roughly 1-2 hours before giving
        --             up, without having either the formspec not reset when
        --             clicking the default button or not being able to drag
        --             the scollbar because the formspec gets re-sent.
        --
        --             I even tried to manually closing the formspec and
        --             re-opening it via `core.after` to prevent race
        --             conditions. This worked with a delay of 0.1 seconds
        --             every now and then and with smaller delays the whole
        --             screen looked like it “flashed” because, well, the
        --             formspec was closed and then re-opened after the delay.
        --
        --             But I absolutely hate the solution so I just accepted
        --             how it works. If everyone ever reading this and knows
        --             a proper solution to re-sent the formspec and have it
        --             using the actual value instead of keeping the previous
        --             value I’d be glad hearing from you :)
        --
        --             Have awonderful day!
        --
        --             Kind regards,
        --             Dirk
        if fields.default then
            -- This works as expected
            meta:set_string(attr.key, attr.default)
            -- it should reset the scrollbar position here when clicking the
            -- default button but it doesn’t …
            d.hud_element_scale(name)
        end
    end


    -- Set offset (used as border/padding) of the timer HUD element
    if formname == 'mtimer:hud_element_offset' then
        local attr = m.meta.hud_element_offset
        local default = core.deserialize(attr.default)
        local x_offset = tonumber(fields.x_offset) or default.x
        local y_offset = tonumber(fields.y_offset) or default.y

        if fields.x_add_1 then x_offset = x_offset + 1 end
        if fields.y_add_1 then y_offset = y_offset + 1 end
        if fields.x_substract_1 then x_offset = x_offset - 1 end
        if fields.y_substract_1 then y_offset = y_offset - 1 end

        meta:set_string(attr.key, core.serialize({
            x = x_offset,
            y = y_offset
        }))

        if fields.default then meta:set_string(attr.key, attr.default) end
        if not fields.quit then d.hud_element_offset(name) end
    end


    -- Set timer text
    if formname == 'mtimer:timer_format' then
        local attr = m.meta.timer_format
        local value = fields.format or attr.default
        meta:set_string(attr.key, value)
        if fields.default then meta:set_string(attr.key, attr.default) end
        if not fields.quit then d.timer_format(name) end
    end


    -- Custom timer setting and configuration
    if formname == 'mtimer:custom_timer' then
        local attr = m.meta.custom_timer_settings
        local ctv = core.deserialize(meta:get_string(attr.key))
        local entered = fields.key_enter_field or ''

        -- Set mode
        if fields.mode_countdown ~= nil then ctv.timer_mode='countdown' end
        if fields.mode_timer ~= nil then ctv.timer_mode='timer' end
        if fields.mode_continuous ~= nil then ctv.timer_mode='continuous' end

        -- Validate direct input
        local days = tonumber(fields.v_days) or 0
        local hours = tonumber(fields.v_hours) or 0
        local minutes = tonumber(fields.v_minutes) or 0
        local seconds = tonumber(fields.v_seconds) or 0

         -- Set values from plus/minus input
        if fields.c_days_p then days = days + 1 end
        if fields.c_hours_p then hours = hours + 1 end
        if fields.c_minutes_p then minutes = minutes + 1 end
        if fields.c_seconds_p then seconds = seconds + 1 end
        if fields.c_days_m then days = days - 1 end
        if fields.c_hours_m then hours = hours - 1 end
        if fields.c_minutes_m then minutes = minutes - 1 end
        if fields.c_seconds_m then seconds = seconds - 1 end

        -- Validate values
        if seconds >= 60 then  seconds = 0   minutes = minutes + 1  end
        if minutes >= 60 then  minutes = 0   hours = hours + 1      end
        if hours >= 24   then  hours = 0     days = days + 1        end
        if seconds < 0   then  seconds = 59  minutes = minutes - 1  end
        if minutes < 0   then  minutes = 59  hours = hours - 1      end
        if hours < 0     then  hours = 23    days = days - 1        end
        if days < 0      then  days = 0                             end

        -- set relevant values
        ctv.format = {
            running = fields.v_format_running,
            stopped = fields.v_format_stopped,
            finished = fields.v_format_finished
        }
        ctv.values = {
            days = days,
            hours = hours,
            minutes = minutes,
            seconds = seconds
        }

        -- Set default values if requested and instantly return to prevent the
        -- rest of the configuration to be executed. At this point only
        -- resetting all values is desired.
        if fields.default then
            meta:set_string(attr.key, attr.default)
            d.custom_timer(name)
            m.update_timer(name)
            return
        end

        -- Set values if not quitting
        if not fields.quit then
            meta:set_string(attr.key, core.serialize(ctv))
        end

        -- Control timer if one of the control buttons was pressed. This is run
        -- after the values safing in order to use the new values instead of
        -- the values that were stored before.
        local ct_update = false
        if fields.ct_start then ct_update = { action = 'start' } end
        if fields.ct_stop then ct_update = { action = 'stop' } end
        if fields.ct_restart then ct_update = { action = 'restart' } end
        if ct_update~=false then mtimer.update_custom_timer(name,ct_update) end

        -- Show the timer formspec if not quitting
        if not fields.quit then d.custom_timer(name) end
    end


    -- Reset everything
    if formname == 'mtimer:reset_everything' then
        local disconnection_message = S('You requested a hard reset of the mTimer configuration. This request was stored. As described, you were disconnected from the server in order to have the hard reset performed. Please rejoin the server. On rejoin all previously stored configuration regarding mTimer will be deleted.')

        -- Perform a soft reset
        if fields.reset_soft then
            for _,def in pairs(m.meta) do
                meta:set_string(def.key, def.default)
            end
        end

        -- Request hard reset and disconnect the player with a message
        if fields.reset_hard then
            meta:set_int(m.meta.hard_reset_everything.key, os.time())
            core.disconnect_player(name, disconnection_message, true)
        end

        -- Show main menu formspec when cancelled or close on fields.quit
        if fields.reset_cancel then d.main_menu(name) return end
        if not fields.quit then d.reset_everything(name) end
    end


    -- Back to menu from all formspecs and conditionally update timer
    if fields.main_menu then d.main_menu(name) end
    if formname ~= 'mtimer:main_menu' then m.update_timer(name) end
end)
