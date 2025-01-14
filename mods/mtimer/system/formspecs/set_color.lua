local m = mtimer
local S = m.translator
local esc = core.formspec_escape


-- Tango palette
--
-- @see http://tango.freedesktop.org/Tango_Icon_Theme_Guidelines
local palette_entries = {
    'fce94f', 'edd400', 'c4a000', 'fcaf3e', 'f57900', 'ce5c00', 'e9b96e',
    'c17d11', '8f5902', '8ae234', '73d216', '4e9a06', '729fcf', '3465a4',
    '204a87', 'ad7fa8', '75507b', '5c3566', 'ef2929', 'cc0000', 'a40000',
    'eeeeec', 'd3d7cf', 'babdb6', '888a85', '555753', '2e3436', '000000',
    'ff0000', '00ff00', '0000ff', 'ffff00', '00ffff', 'ff00ff', 'c0c0c0',
    '808080', '800000', '808000', '008000', '800080', '008080', '000080',
}


local hexformat = table.concat({
    '#',
    core.colorize('#ce5c00', 'rr'),
    core.colorize('#4e9a06', 'gg'),
    core.colorize('#729fcf', 'bb')
})


mtimer.dialog.set_color = function (player_name)
    local player = core.get_player_by_name(player_name)
    local color = player:get_meta():get_string(m.meta.color.key)
    local palette = {}
    local col = 0
    local row = 1

    for _,color in pairs(palette_entries) do
        local cb_height = 0.6
        local cb_width = 1.39
        local cb_style = 'style[+name;bgcolor=#+color;textcolor=#+color]'
        local cb_button = 'button[+left,+top;+width,+height;+name;+label]'
        local cb_complete = cb_style..' '..cb_button

        col = col + 1
        if col > 7 then
            col = 1
            row = row + 1
        end

        table.insert(palette, ((cb_complete):gsub('%+%w+', {
            ['+top'] = (row - 1) * (cb_height + 0.05),
            ['+left'] = (col - 1) * (cb_width + 0.05),
            ['+width'] = cb_width,
            ['+height'] = cb_height,
            ['+name'] = 'set_color',
            ['+color'] = color,
            ['+label'] = color
        })))
    end

    mtimer.show_formspec('mtimer:set_color', {
        title = S('Color'),
        show_to = player_name,
        width = 10,
        height = 6.2,
        formspec = {
            'field_close_on_enter[color;false]',
            'field[0,0;3,0.5;color;;'..color..']',
            'box[3.25,0;0.5,0.5;'..color..'ff]',
            'tooltip[3.25,0;0.5,0.5;'..S('Current color: @1', color)..']',
            'label[0,1;'..S('Use `@1` format only!', hexformat)..']',
            'container[0,1.85]',
            '  box[0,-0.4;+contentWidth,0.04;#ffffff]',
            '  label[0,0;'..esc(S('Set a predefined color'))..']',
            '  container[0,0.4]'..table.concat(palette, ' ')..'container_end[]',
            'container_end[]'
        }
    })
end
