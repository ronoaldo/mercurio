-- # vim: nowrap
--
-- Set Vim to no-wrapping mode because of some lines not fitting within the 80
-- characters width limit due to overall readability of the code.


-- Localise needed functions
local m = mtimer
local S = m.translator
local esc = core.formspec_escape


-- Render the world map
--
-- This function renders the world map with the marker of the current time
-- zone offset and the buttons for selecting the new time zone.
--
-- @param offset  The current offset as number
-- @return string The formspec code for the rendered world map
local render_world_map = function (offset)
    local zones_multiplicator = 10/25
    local marker_pos = (5 + (offset * zones_multiplicator)) - 0.2
    local buttons = ''

    for zone = -12,12,1 do
        local position = (5 + (zone * zones_multiplicator)) - 0.2
        local template = 'image_button[+position,0;0.4,5;+texture;+id;;;false]'
        local infotext = S('Set timezone offset to @1', zone)
        local tooltip = 'tooltip[new_offset_'..zone..';'..infotext..']'

        local button = template:gsub('%+%w+',{
            ['+position'] = position,
            ['+texture'] = 'mtimer_transparent.png',
            ['+id'] = 'new_offset_'..zone
        })

        buttons = buttons..' '..button..tooltip
    end

    return table.concat({
        'image[0,0;10,5;mtimer_world_map.png^[opacity:96]',
        'box[0,0;10,5;#00000060]', -- background
        'box['..marker_pos..',0;0.4,5;#729fcf]',
        buttons
    }, ' ')
end


mtimer.dialog.timezone_offset = function (player_name)
    local time_data = mtimer.get_times(player_name).real_time
    local offset = time_data.times.offset

    local dst_info = esc(S('Please note that daylight saving time (DST) is ignored entirely due to minimizing implementation complexity. You need to manually adjust the time zone in order to adapt to any DST changes. This messes up the visual representation a bit (but it’s not very accurate anyways …).'))

    mtimer.show_formspec('mtimer:timezone_offset', {
        title = S('Timezone Offset'),
        show_to = player_name,
        width = 10,
        height = 9.5,
        formspec = {
            'container[0,0]',
            'field_close_on_enter[offset;false]',
            'label[3.25,0.25;'..S('set a value between -12 and +12 hours')..']',
            'field[0,0;3,0.5;offset;;'..offset..']',
            'box[0,0.75;+contentWidth,0.02;#ffffff]',
            'container_end[]',
            'container[0,1]',
            render_world_map(offset),
            'box[0,5.25;+contentWidth,0.02;#ffffff]',
            'container_end[]',
            'container[0,6.625]',
            'label[0,0;'..S('Current server time: @1', time_data.times.server_time)..']',
            'label[0,0.4;'.. S('Calculated local time: @1', time_data.times.local_time)..']',
            'box[0,0.75;+contentWidth,0.02;#ffffff]',
            'textarea[0,1;10,3;;;'..dst_info..']',
            'container_end[]',
        }
    })
end
