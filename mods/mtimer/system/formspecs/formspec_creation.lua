-- Localise needed functions
local m = mtimer
local S = m.translator
local esc = core.formspec_escape
local line = mtimer.get_table_line


-- Formspecs are loaded and shown by individual functions. The function name
-- correlates with the formspec to show. All of the names are self-explanatory
-- and within the functions no logic is used.
--
-- Some formspec functions are separated into individual files because they are
-- very complex and/or need helper functions.
--
-- @see mtimer.show_formspec
-- @see mtimer.get_times
-- @see ./system/on_receive_fields.lua
-- @see ./system/chat_command.lua
-- @see ./system/formspecs/*


mtimer.dialog.set_visibility = function (player_name)
    local player = core.get_player_by_name(player_name)
    local visible = player:get_meta():get_string(m.meta.visible.key)
    local status = visible == 'true' and S('visible') or S('invisible')

    mtimer.show_formspec('mtimer:set_visibility', {
        title = S('Visibility'),
        show_to = player_name,
        formspec = {
             mtimer.get_icon_button('set_visible', {
                 width = 4,
                 label = S('Make visible')
             }),
             mtimer.get_icon_button('set_invisible', {
                 width = 4,
                 label = S('Make invisible'),
                 container = { left = 4.25 }
             }),
             'label[0,1.25;'..S('The timer is currently @1', status)..']'
        }
    })
end


mtimer.dialog.ingame_time_format = function (player_name)
    local time_data = mtimer.get_times(player_name).ingame_time

    mtimer.show_formspec('mtimer:ingame_time_format', {
        title = S('Ingame Time Format'),
        show_to = player_name,
        formspec = {
            'field_close_on_enter[format;false]',
            'field[0,0;+contentWidth,0.5;format;;'..esc(time_data.format)..']',
            'container[0,1.5]',
            line(0, '', S('Variable'),      S('Current Value')),
            line(1, '-'),
            line(2, S('Hours (24h)'),       '{24h}', time_data.hours_24),
            line(3, S('Hours (12h)'),       '{12h}', time_data.hours_12),
            line(4, S('Minutes'),           '{min}', time_data.minutes),
            line(5, S('Meridiem Indicator'),'{mi}', time_data.indicator),
            line(6, S('Ingame Timestamp'), '{its}', time_data.ingame_timestamp),
            line(7, '-'),
            line(8, S('Current Result'), esc(time_data.formatted), ''),
            'container_end[]'
        }
    })
end


mtimer.dialog.real_world_time_format = function (player_name)
    mtimer.dialog.real_time_universal(player_name, {
        time_type = 'real_time',
        formspec_name = 'mtimer:real_world_time_format',
        title = S('Real-World Time Format')
    })
end


mtimer.dialog.host_time_format = function (player_name)
    mtimer.dialog.real_time_universal(player_name, {
        time_type = 'host_time',
        formspec_name = 'mtimer:host_time_format',
        title = S('Host Time Format')
    })
end


mtimer.dialog.session_start_time_format = function (player_name)
    mtimer.dialog.real_time_universal(player_name, {
        time_type = 'session_start_time',
        formspec_name = 'mtimer:session_start_time_format',
        title = S('Session Start Time Format')
    })
end


mtimer.dialog.session_duration_format = function (player_name)
    local time_data = mtimer.get_times(player_name).session_duration

    mtimer.show_formspec('mtimer:session_duration_format', {
        title = S('Session Duration Format'),
        show_to = player_name,
        formspec = {
            'field_close_on_enter[format;false]',
            'field[0,0;+contentWidth,0.5;format;;'..esc(time_data.format)..']',
            'container[0,1.5]',
            line(0, '', S('Variable'), S('Current Value')),
            line(1, '-'),
            line(2, S('Days'),    '{days}',    time_data.days),
            line(3, S('Hours'),   '{hours}',   time_data.hours),
            line(4, S('Minutes'), '{minutes}', time_data.minutes),
            line(5, S('Seconds'), '{seconds}', time_data.seconds),
            line(6, '-'),
            line(7, S('Current Result'), esc(time_data.formatted), ''),
            'container_end[]'
        }
    })
end


mtimer.dialog.timer_format = function (player_name)
    local td = mtimer.get_timer_data(player_name)

    mtimer.show_formspec('mtimer:timer_format', {
        title = S('Timer Format'),
        show_to = player_name,
        height = 6,
        width = 11,
        formspec = {
            'textarea[0,0;6,2.5;format;;'..esc(td.format)..']',
            'container[0,3.4]',
            line(0, '', S('Variable'), S('Current Value')),
            line(1, '-'),
            line(2, S('Real-World Date'),   '{rd}', esc(td.real_world_date)),
            line(3, S('In-Game Time'),      '{it}', esc(td.ingame_time)),
            line(4, S('Session Start Time'),'{st}', esc(td.session_start_time)),
            line(5, S('Session Duration'),  '{sd}', esc(td.session_duration)),
            line(6, S('Host Time'),         '{ht}', esc(td.host_time)),
            line(7, S('Custom Timer'),      '{ct}', esc(td.custom_timer)),
            'container_end[]',
            'container[6.25,0]',
            mtimer.get_icon_button('apply', { label = S('Apply') }),
            'container_end[]'
        }
    })
end


mtimer.dialog.reset_everything = function (player_name)
    local td = mtimer.get_timer_data(player_name)
    local infotext = table.concat({
        S('For resetting the configuration you have two options.'),
        S('Usually using a soft reset is enough. The soft reset sets all values based on mTimer functionality to the default values while staying connected.'),
        S('If the soft reset does not work you can hard reset the configuration. This stores a request and then kicks you from the server. On rejoining mTimer forcefully removes all stored configuration and sets the current default values.')
    }, '\n\n')

    mtimer.show_formspec('mtimer:reset_everything', {
        title = S('Reset Everything'),
        show_to = player_name,
        width = 10,
        height = 6.3,
        hide_buttons = true,
        formspec = {
            'textarea[0,0;+contentWidth,3.5;;;'..esc(infotext)..']',
            'container[0,3.8]',
            line(0, '-'),
            mtimer.get_icon_button('reset_soft', {
                width = 10,
                label = S('Soft-reset all values to their defaults')
            }),
            mtimer.get_icon_button('reset_hard', {
                label = S('Request hard-reset (disconnects you from the server!)'),
                width = 10,
                container = { top = 1 }
            }),
             mtimer.get_icon_button('reset_cancel', {
                label = S('Cancel reset and return to main menu'),
                width = 10,
                container = { top = 2 }
            }),
            'container_end[]',
        }
    })
end
