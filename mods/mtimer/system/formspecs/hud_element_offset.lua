-- Localise needed functions
local m = mtimer
local S = m.translator
local esc = core.formspec_escape


-- Draw a scale/ruler indicator
--
-- This function draws an either horizontal or vertical scale/ruler indicator
-- of the given length and thickness in formspec units.
--
--   |--------|
--
-- It is also possible to set a color.
--
-- @param orientation Either `horizontal` or `vertical`
-- @param length      Desired Length as number in formspec units
-- @param thickness   Desired thicness as number in formspec units
-- @param color       Color as hexadecimal string without opacity (`#rrggbb`)
--
-- @return string     The generated formspec code without container
local draw_scale = function(orientation, length, thickness, color)
    local startX, startY, startWidth, startHeight
    local ruleX, ruleY, ruleWidth, ruleHeight
    local endX, endY, endWidth, endHeight

    if orientation == 'horizontal' then
        startX = 0
        startY = 0
        startWidth = thickness
        startHeight = thickness * 3
        ruleX = 0 + (thickness / 4)
        ruleY = thickness
        ruleWidth = length - (2 * (thickness / 4))
        ruleHeight = thickness
        endX = length - thickness
        endY = 0
        endWidth = thickness
        endHeight = thickness * 3
    end

    if orientation == 'vertical' then
        startX = 0
        startY = 0
        startWidth = thickness * 3
        startHeight = thickness
        ruleX = thickness
        ruleY = 0 + (thickness / 4)
        ruleWidth = thickness
        ruleHeight = length - (2 * (thickness / 4))
        endX = 0
        endY = length - thickness
        endWidth = thickness * 3
        endHeight = thickness
    end

    return (table.concat({
        'box[+startX,+startY;+startWidth,+startHeight;+color]',
        'box[+ruleX,+ruleY;+ruleWidth,+ruleHeight;+color]',
        'box[+endX,+endY;+endWidth,+endHeight;+color]',
    }, ' ')):gsub('%+%w+', {
        ['+startX'] = startX,
        ['+startY'] = startY,
        ['+startWidth'] = startWidth,
        ['+startHeight'] = startHeight,
        ['+ruleX'] = ruleX,
        ['+ruleY'] = ruleY,
        ['+ruleWidth'] = ruleWidth,
        ['+ruleHeight'] = ruleHeight,
        ['+endX'] = endX,
        ['+endY'] = endY,
        ['+endWidth'] = endWidth,
        ['+endHeight'] = endHeight,
        ['+color'] = color..'FF'
    })

end


mtimer.dialog.hud_element_offset = function (player_name)
    local player = core.get_player_by_name(player_name)
    local timer_data = esc(mtimer.get_timer_data(player_name).format)
    local h_color = '#a40000'
    local v_color = '#4e9a06'

    -- Get current offset values or 0 for use in formspec
    local key = m.meta.hud_element_offset.key
    local offset = core.deserialize(player:get_meta():get_string(key))
    offset.x = offset.x and offset.x or 0
    offset.y = offset.y and offset.y or 0


    local infotext = S('Control the HUD element offset using the input on the right side and use the screenshot and markings as orientation for what is changed. The result is shown in the HUD in real time, so check for the actual timner position using the timer HUD element itself.')

    mtimer.show_formspec('mtimer:hud_element_offset', {
        title = S('HUD Element Offset'),
        show_to = player_name,
        width = 11,
        height = 7.5,
        formspec = {
            'field_close_on_enter[x_offset;false]',
            'field_close_on_enter[y_offset;false]',
            'container[0,0]',
            '  container[0,0]',
                 draw_scale('vertical', 4.8, 0.1, v_color),
            '  container_end[]',
            '  image[0.5,0;8,4.8;mtimer_positions_orientation.png]',
            '  textarea[0,5.7;8.5,1.85;;;'..esc(infotext)..']',
            '  box[8.75,0;0.01,7.5;#ffffff]',
            '  container[0.5,5.05]',
                 draw_scale('horizontal', 8, 0.1, h_color),
            '  container_end[]',
            'container_end[]',
            'container[9.5,0.4]',
            '  label[-0.5,-0.25;'..esc(S('Vertical'))..']',
            '  box[-0.5,0.1;0.3,0.3;'..v_color..'FF]',
            '  field[0,0;0.75,0.5;y_offset;;'..offset.y..']',
            -- TRANSLATORS: Symbol for addition
            '  button[0.8,0;0.5,0.26;y_add_1;'..S('+')..']',
            -- TRANSLATORS: Symbol for subtraction
            '  button[0.8,0.26;0.5,0.26;y_substract_1;'..S('-')..']',
            'container_end[]',
            'container[9.5,1.75]',
            '  label[-0.5,-0.25;'..esc(S('Horizontal'))..']',
            '  box[-0.5,0.1;0.3,0.3;'..h_color..'FF]',
            '  field[0,0;0.75,0.5;x_offset;;'..offset.x..']',
            '  button[0.8,0;0.25,0.51;x_substract_1;'..S('-')..']',
            '  button[1.05,0;0.25,0.51;x_add_1;'..S('+')..']',
            'container_end[]'
       }
    })
end
