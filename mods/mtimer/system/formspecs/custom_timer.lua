-- # vim: nowrap
--
-- Set Vim to no-wrapping mode because of some lines not fitting within the 80
-- characters width limit due to overall readability of the code.


-- Localise needed functions
local m = mtimer
local S = m.translator
local esc = minetest.formspec_escape


-- Custom Timer Formspec
--
-- This formspec shows the custom timer configuration and controls.
--
-- @see mtimer.show_formspec
-- @param player_name The name of the player to show the formspec to
mtimer.dialog.custom_timer = function (player_name)
    local player_meta = minetest.get_player_by_name(player_name):get_meta()
    local ctv = minetest.deserialize(player_meta:get_string(m.meta.custom_timer_settings.key))
    local timer_status = (ctv.running == true) and S('running') or S('stopped')

    local days = ctv.values.days or 0
    local hours = ctv.values.hours or 0
    local minutes = ctv.values.minutes or 0
    local seconds = ctv.values.seconds or 0

    local a_countdown = ctv.timer_mode == 'countdown' and 'true' or 'false'
    local a_timer = ctv.timer_mode == 'timer' and 'true' or 'false'
    local a_continuous = ctv.timer_mode == 'continuous' and 'true' or 'false'

    local format_running = ctv.format.running or ''
    local format_stopped = ctv.format.stopped or ''
    local format_finished = ctv.format.finished or ''

    mtimer.show_formspec('mtimer:custom_timer', {
        title = S('Custom Timer'),
        show_to = player_name,
        height = 6.25,
        width = 13,
        formspec = {
            'field_close_on_enter[v_format_running;false]',
            'field_close_on_enter[v_format_stopped;false]',
            'field_close_on_enter[v_format_finished;false]',
            'field_close_on_enter[v_days;false]',
            'field_close_on_enter[v_hours;false]',
            'field_close_on_enter[v_minutes;false]',
            'field_close_on_enter[v_seconds;false]',
            'container[0,0]',
            '  label[0,0.25;'..S('Running')..']   field[2.5,0;10.5,0.5;v_format_running;;'..esc(format_running)..']',
            '  label[0,0.85;'..S('Stopped')..']   field[2.5,0.6;10.5,0.5;v_format_stopped;;'..esc(format_stopped)..']',
            '  label[0,1.45;'..S('Finished')..']  field[2.5,1.2;10.5,0.5;v_format_finished;;'..esc(format_finished)..']',
            '  box[0,2;+contentWidth,0.04;#ffffff]',
            'container_end[]',
            'container[3.75,2.4]',
            '  label[0,0;'..S('Information')..'] label[2.5,0;'..S('Variable')..'] label[5,0;'..S('Used Value')..']',
            '  box[0,0.25;7,0.02;#ffffff]',
            '  label[0,0.5;'..S('Days')..']      label[2.5,0.5;{days}]            label[5,0.5;'..days..']',
            '  label[0,0.9;'..S('Hours')..']     label[2.5,0.9;{hours}]           label[5,0.9;'..hours..']',
            '  label[0,1.3;'..S('Minutes')..']   label[2.5,1.3;{minutes}]         label[5,1.3;'..minutes..']',
            '  label[0,1.7;'..S('Seconds')..']   label[2.5,1.7;{seconds}]         label[5,1.7;'..seconds..']',
            'container_end[]',
            'container[0,2.3]',
            '  container[0,0]',
            '    button[0,0;0.75,0.25;c_days_p;+]',
            '    field[0,0.25;0.755,0.5;v_days;;'..days..']',
            '    button[0,0.75;0.75,0.25;c_days_m;-]',
            '  container_end[]',
            '  container[0.9,0]',
            '    button[0,0;0.75,0.25;c_hours_p;+]',
            '    field[0,0.25;0.755,0.5;v_hours;;'..hours..']',
            '    button[0,0.75;0.75,0.25;c_hours_m;-]',
            '  container_end[]',
            '  container[1.8,0]',
            '    button[0,0;0.75,0.25;c_minutes_p;+]',
            '    field[0,0.25;0.755,0.5;v_minutes;;'..minutes..']',
            '    button[0,0.75;0.75,0.25;c_minutes_m;-]',
            '  container_end[]',
            '  container[2.7,0]',
            '    button[0,0;0.75,0.25;c_seconds_p;+]',
            '    field[0,0.25;0.755,0.5;v_seconds;;'..seconds..']',
            '    button[0,0.75;0.75,0.25;c_seconds_m;-]',
            '  container_end[]',
            'container_end[]',
            'container[0,3.75]',
            '  checkbox[0,0;mode_countdown;'..S('Countdown')..';'..a_countdown..']',
            '  checkbox[0,0.4;mode_timer;'..S('Timer Mode')..';'..a_timer..']',
            '  checkbox[0,0.8;mode_continuous;'..S('Continuous Run')..';'..a_continuous..']',
            'container_end[]',
            'container[0,5.55]',
            '  box[0,-0.25;+contentWidth,0.04;#ffffff]',
            '  label[0,0.375;'..esc(S('The timer is currently @1', timer_status))..']',
            '  container[+contentWidth,0]',
                 mtimer.get_icon_button('ct_start', {   width = 2.25, label = S('Start'),   colorize = { color = '#4e9a06' }, container = { left = -7.25 } }),
                 mtimer.get_icon_button('ct_stop', {    width = 2.25, label = S('Stop'),    colorize = { color = '#a40000', ratio = 128 }, container = { left = -4.75 } }),
                 mtimer.get_icon_button('ct_restart', { width = 2.25, label = S('Restart'), colorize = { color = '#729fcf' }, container = { left = -2.25 } }),
            '  container_end[]',
            'container_end[]',
        }
    })
end
