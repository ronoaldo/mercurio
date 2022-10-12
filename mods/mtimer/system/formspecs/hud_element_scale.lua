-- Localise needed functions
local m = mtimer
local S = m.translator
local esc = minetest.formspec_escape


-- Draw a scale ruler
--
-- This function creates a two-colored ruler that can be used as scale for
-- scrollbars, etc. It is optionally possible to write first and last value
-- below the scale ruler.
--
-- @param steps   Steps the ruler should have
-- @param length  Overall length of the ruler in formspec units
-- @param height  Height of the ruler in formspec units
-- @param pos     A simple position table ({x=0,y=0}) for the container
-- @param c_odd   Odd segment color
-- @param c_even  Even segment color
-- @param mark    Either nil or a number in formspec units for the markings
--
-- @return string The formspec code for the scale ruler
local draw_scale_ruler = function (steps,length,height,pos,c_odd,c_even,mark)
    local elements = ''
    local marks = ''
    local step_width = length / steps

    -- Build scale
    for step=1,steps,1 do
        elements = elements..' '..(('box[+x,+y;+w,+h;+c]'):gsub('%+%w', {
            ['+x'] = step_width * (step - 1),
            ['+y'] = 0,
            ['+w'] = step_width,
            ['+h'] = height,
            ['+c'] = (step % 2 == 0) and c_even or c_odd,
        }))
    end

    -- Build marks (start, end)
    if type(mark) == 'number' then
        local template = 'image_button[+x,+y;+w,+h;+t;;+l;;false]'

        local m_start = template:gsub('%+%w',{
            ['+x'] = 0,
            ['+y'] = 0,
            ['+w'] = step_width,
            ['+h'] = 0.5,
            ['+t'] = 'mtimer_transparent.png',
            ['+l'] = length / steps
        })
        local m_end = template:gsub('%+%w', {
            ['+x'] = (step_width * steps) - step_width,
            ['+y'] = 0,
            ['+w'] = step_width,
            ['+h'] = 0.5,
            ['+t'] = 'mtimer_transparent.png',
            ['+l'] = steps
        })

        marks = 'container[0,'..mark..'] '..m_start..m_end..' container_end[]'
    end

    return table.concat({
        'container['..pos.x..','..pos.y..']',
        elements,
        marks,
        'container_end[]'
    }, ' ')
end


mtimer.dialog.hud_element_scale = function (player_name)
    local player = minetest.get_player_by_name(player_name)
    local scale = player:get_meta():get_string(m.meta.hud_element_scale.key)

    local sb_options = table.concat({
        'min=1',
        'max=10',
        'smallstep=1',
        'largestep=10',
        'thumbsize=1',
        'arrows=hide'
    }, ';')

    local infotext = S('The HUD element can be scaled between 1x (original size) and 10x (largest size due to performance reasons). Use the slider above to adjust the scaling to your needs.')

    infotext = infotext..'\n\n'..S('Due to technical reasons the slider position does not reset when clicking the button to set to default values. The HUD element itself resets, and when re-entering this dialog the slider position is properly set.')

    mtimer.show_formspec('mtimer:hud_element_scale', {
        title = S('HUD Element Scale'),
        show_to = player_name,
        formspec = {
            draw_scale_ruler(10,10,0.25,{x=0,y=0},'#729fcf','#73f216',0.45),
            'scrollbaroptions['..sb_options..']',
            'scrollbar[0,0.25;10,0.25;horizontal;new_value;'..scale..']',
            'box[0,1.13;+contentWidth,0.01;#ffffff]',
            'textarea[0,1.5;10,3;;;'..esc(infotext)..']',
        }
    })
end
