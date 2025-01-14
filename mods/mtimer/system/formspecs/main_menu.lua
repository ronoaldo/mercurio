-- # vim: nowrap
--
-- Set Vim to no-wrapping mode because of some lines not fitting within the 80
-- characters width limit due to overall readability of the code.


-- Localise needed functions
local m = mtimer
local S = m.translator
local esc = core.formspec_escape


-- Create buttons at the given position in the main menu formspec
--
-- This function takes a column and a row and translates that to values used
-- by the icon button function. All buttons are 5 units wide and the image
-- size is 0.5 units.
--
-- @param column The desired column, starting with 1
-- @param row The desired row, starting with 1
-- @param id The button’s ID
-- @param label The button’s label
-- @return string The parsed main menu button
local menu_button = function (column, row, id, label)
    local b_width = 5
    local i_size = 0.5

    -- Calculations
    local b_padding = i_size / 4
    local b_height = (b_padding * 2) + i_size
    local b_top_position = (row - 1) * b_height
    local b_top_spacing = b_top_position == 0 and 0 or b_padding * 1.5
    local c_position = (column - 1) * b_width
    local c_spacing = c_position == 0 and 0 or b_padding * 3
    local bc_top = b_top_position + (b_top_spacing * (row - 1))
    local bc_left = c_position + (c_spacing * (column - 1))

    return mtimer.get_icon_button(id, {
        label = esc(label),
        width = b_width,
        image_size = i_size,
        container = {
            top = bc_top,
            left = bc_left
        }
    })
end


-- Main Menu generation
--
-- @see mtimer.show_formspec
-- @param player_name The name of the player to show the formspec to
mtimer.dialog.main_menu = function (player_name)
    mtimer.show_formspec('mtimer:main_menu', {
        width = 15.75,
        height = 5.75,
        hide_buttons = true,
        hide_title = true,
        show_to = player_name,
        formspec = {
            -- Visuals
            menu_button(1, 1, 'set_visibility', S('Visibility')),
            menu_button(1, 2, 'set_position', S('Position')),
            menu_button(1, 3, 'set_color', S('Color')),
            menu_button(1, 4, 'hud_element_scale', S('HUD Element Scale')),
            menu_button(1, 5, 'hud_element_offset', S('HUD Element Offset')),
            -- Time Representation
            menu_button(2, 1, 'ingame_time_format', S('Ingame Time Format')),
            menu_button(2, 2, 'real_world_time_format', S('Real-World Time Format')),
            menu_button(2, 3, 'session_start_time_format', S('Session Start Time Format')),
            menu_button(2, 4, 'session_duration_format', S('Session Duration Format')),
            menu_button(2, 5, 'host_time_format', S('Host Time Format')),
            -- Timer configuration
            menu_button(3, 1, 'timer_format', S('Timer Format')),
            menu_button(3, 2, 'timezone_offset', S('Timezone Offset')),
            menu_button(3, 3, 'custom_timer', S('Custom Timer')),
            -- Custom buttons
            'container[0,4.75]',
            '  box[0,0;+contentWidth,0.04;#ffffff]',
            '  container[+contentWidth,0]',
                 mtimer.get_icon_button('reset_everything', { label = S('Reset Everything'), width = 4, container = { top = 0.25, left = -6.75 } }),
                 mtimer.get_icon_button('exit', { label = S('Exit'), exit_button = true, width = 2.5, container = { top = 0.25, left = -2.5 } }),
            '  container_end[]',
            'container_end[]'
        }
    })
end
