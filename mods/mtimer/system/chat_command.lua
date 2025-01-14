local m = mtimer
local S = m.translator
local d = m.dialog


-- Colorize a command sequence
--
-- This function returns a colorized chat command sequence with the given
-- parameter and the needed spacing
--
-- @param command The chat command paramter
-- @return table  The colorized string
local command = function (command)
     return core.colorize('cyan', '/mtimer '..command..'   ')
end


-- Chat command
--
-- The `/mtimer` chat command opens the main menu and allows to directly open
-- the formspecs for the specific configuration. It can be run by all users.
--
-- The following parameters are supported.
--
--  Parameter   Mnemonic           Action
-- -------------------------------------------------------------------
--  vi          visibility         d.set_visibility(name)
--  po          position           d.set_position(name)
--  co          color              d.sec_color(name)
--  tz          timezone           d.timezone_offset(name)
--  in          ingame             d.ingame_time_format(name)
--  re          real               d.real_world_time_format(name)
--  ht          host time          d.host_time_format(name)
--  st          start time         d.session_start_time_format(name)
--  sd          session duration   d.session_duration_format(name)
--  hs          HUD element scale  d.hud_element_scale(name)
--  os          OffSet             d.hud_element_offset(name)
--  tf          timer format       d.timer_format(name)
--  ct          custom timer       d.custom_timer(name)
--  re          reset everything   d.reset_everything(name)
-- -------------------------------------------------------------------
--  help        Prints the help output showing the parameters
--
-- Providing unknown parameters has no effect.
core.register_chatcommand('mtimer', {
    description = S('Configure timer display'),
    params = '<vi/po/co/tz/in/re/ht/st/sd/hs/os/tf/ct/re/help>',
    func = function(name, parameters)
        local action = parameters:match('%a+')

        if not core.get_player_by_name(name) then return end
        if not action then d.main_menu(name) end

        if action == 'vi' then d.set_visibility(name) end
        if action == 'po' then d.set_position(name) end
        if action == 'co' then d.set_color(name) end
        if action == 'tz' then d.timezone_offset(name) end
        if action == 'in' then d.ingame_time_format(name) end
        if action == 're' then d.real_world_time_format(name) end
        if action == 'ht' then d.host_time_format(name) end
        if action == 'st' then d.session_start_time_format(name) end
        if action == 'sd' then d.session_duration_format(name) end
        if action == 'hs' then d.hud_element_scale(name) end
        if action == 'os' then d.hud_element_offset(name) end
        if action == 'tf' then d.timer_format(name) end
        if action == 'ct' then d.custom_timer(name) end
        if action == 're' then d.reset_everything(name) end

        if action == 'ctstart'   then mtimer.update_custom_timer(name, { action = 'start' })   end
        if action == 'ctstop'    then mtimer.update_custom_timer(name, { action = 'stop' })    end
        if action == 'ctrestart' then mtimer.update_custom_timer(name, { action = 'restart' }) end

        if action == 'help' then
            local message = {
                command('  ')..S('Open Main Menu'),
                command('vi')..S('Visibility'),
                command('po')..S('Position'),
                command('co')..S('Color'),
                command('tz')..S('Timezone Offset'),
                command('in')..S('Ingame Time Format'),
                command('re')..S('Real-World Time Format'),
                command('ht')..S('Host Time Format'),
                command('st')..S('Session Start Time Format'),
                command('sd')..S('Session Duration Format'),
                command('hs')..S('HUD Element Scale'),
                command('os')..S('HUD Element Offset'),
                command('tf')..S('Timer Format'),
                command('re')..S('Reset Everything'),
                '',
                command('ct       ')..S('Configure the custom timer'),
                command('ctstart  ')..S('Start the custom timer'),
                command('ctstop   ')..S('Stop stop custom timer'),
                command('ctrestart')..S('Restart the custom timer')
            }
            core.chat_send_player(name, table.concat(message, '\n'))
        end
    end
})
