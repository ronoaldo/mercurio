local m = mtimer
local S = m.translator


-- Image width and height for setting the screenshot in position and do the
-- button calculations
local i_width = 10
local i_height = 6


-- Position names for the current position information  string
local p_names = {
    ['t'] = S('top'),
    ['m'] = S('middle'),
    ['b'] = S('bottom'),
    ['l'] = S('left'),
    ['c'] = S('center'),
    ['r'] = S('right')
}


-- Return parsed position button
--
-- This function shows a button on the given position that sets the position
-- of the GUI element accordingly. The `position` is one of the following.
--
--   tl, tc, tr = top left, center, right
--   ml, mc, mr = middle left, center, right
--   bl, bc, br = bottom left, center right
--
-- @param top The position of the button from the top
-- @param left The position of the button from the left
-- @param position GUI element position to set with this button
local b_define = function(top, left, position)
    return ('image_button[+l,+t;+w,+h;+i;pos_+p;d;;false]'):gsub('%+%w', {
        ['+l'] = (left - 1) * (i_width / 3),
        ['+t'] = (top - 1) * (i_height / 3),
        ['+w'] = i_width / 3,
        ['+h'] = i_height / 3,
        ['+i'] = 'mtimer_transparent.png',
        ['+p'] = position,
    })
end


mtimer.dialog.set_position = function (player_name)
    local player = core.get_player_by_name(player_name)
    local howto = S('Click the position you want to place the timer at.')
    local image = 'mtimer_positions_orientation.png'

    -- Get current position name
    local p_value = player:get_meta():get_string(m.meta.position.key)
    local p_name = p_names[p_value:sub(1,1)]..' '..p_names[p_value:sub(2,2)]
    local p_info = S('Current position: @1', p_name)


    mtimer.show_formspec('mtimer:set_position', {
        title = S('Position'),
        height = 7.2,
        width = 10,
        show_to = player_name,
        formspec = {
            'image[0,0;'..i_width..','..i_height..';'..image..']',
            b_define(1, 1, 'tl'), b_define(1, 2, 'tc'), b_define(1, 3, 'tr'),
            b_define(2, 1, 'ml'), b_define(2, 2, 'mc'), b_define(2, 3, 'mr'),
            b_define(3, 1, 'bl'), b_define(3, 2, 'bc'), b_define(3, 3, 'br'),
            'label[0,6.5;'..howto..'\n'..p_info..']'
        }
    })
end
