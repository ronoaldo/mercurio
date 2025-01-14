local S = mtimer.translator
local worldpath = core.get_worldpath()..DIR_DELIM
local worldconfig = Settings(worldpath..DIR_DELIM..'_mtimer.conf')


-- Set an option in mtimer.meta configuration table.
--
-- The function takes an unprefixed key name and tries to get this key’s
-- configuration option and sets the table entry with that option and the
-- meta key name for that key. Because the meta settings system only allows
-- to write strings all values are converted to strings.
--
--   set('my_cool_key', 1337)
--
-- This setting creates the following table entry:
--
--   mtimer.meta.my_cool_key = {
--       key = 'mtimer:my_cool_key',
--       default = '1337'
--   }
--
-- The default value is searched in the following order When the setting is
-- not found in any of the locations an empty string is used
--
--   1. Standard configuration file that is used for the server
--   2. `_mtimer.conf` in the loaded world’s directory
--   3. Provided default value when calling the function
--
-- If the value `return_only` is set then the function does only return the
-- determined value instead of writing the meta table entry.
--
-- If `replace` is a key-value table then occurrences of the key in a special
-- variable in the configuration value are replaced.
--
--   replace = {
--     foobar = 'My Foobar Value'
--   }
--
-- This example searches for all variables `{_foobar}` and replaces them with
-- `'My Foobar Value'`. Note the underscore. The underscore prevents confusion
-- with timer-related variables.
--
-- @param key_name The unprefixed name of the key to get
-- @param default_value What to return when the configuration option is missing
-- @param return_only Only return the configuration value and do nothing
-- @param replace A replacement table as described
-- @return string Either the configuration option’s value or an empty string
local set = function (key_name, default_value, return_only, replace)
    local meta_key = 'mtimer:'..key_name
    local config_option = 'mtimer_'..key_name
    local value = default_value

    -- Get the setting from one of the possible locations
    local global_setting = core.settings:get(config_option)
    local world_setting = worldconfig:get(config_option)

    -- Define value
    value = world_setting or global_setting or default_value or ''
    if type(replace) == 'table' then value=value:gsub('{_([^}]*)}',replace) end

    -- Return or store value
    if return_only == true then return tostring(value) end
    mtimer.meta[key_name] = { key = meta_key, default = tostring(value) }
end


-- Set HUD element offset table using the custom values
set('hud_element_offset', core.serialize({
    x = set('hud_element_offset_x', 0, true),
    y = set('hud_element_offset_y', 0, true)
}))


-- Display settings
set('color', '#ffffff')
set('hud_element_scale', 1)
set('position', 'bl')
set('timezone_offset', 0)
set('visible', true)


-- Formatting settings
set('host_time_format', '{24h}:{min} ({isodate})')
set('ingame_time_format', '{24h}:{min}')
set('real_time_format', '{24h}:{min} ({isodate})')
set('session_duration_format', '{hours}:{minutes}')
set('session_start_time_format', '{isodate}T{isotime}')


-- Custom timer settings
--
-- `timer_mode` can be one of the following:
--
--  'countdown': Counting backwards from the calculated starting point to the
--               `start_timestamp` value. The starting point is calculated
--               using the input values and `start_timestamp`.
--
-- 'timer': Counting up from the `start_timestamp` value to the calculated
--          target. The target is calculated by the `start_timestamp` and the
--          given `input_values`.
--
-- 'continuous': The timer shows the difference between the current timestamp
--               and the stored `start_timestamp`. Here the `target_message`
--               is ignored and will never be shown.
set('custom_timer_settings', core.serialize({
    values = {
        days = tonumber(set('custom_timer_value_days', 0, true)),
        hours = tonumber(set('custom_timer_value_hours', 0, true)),
        minutes = tonumber(set('custom_timer_value_minutes', 0, true)),
        seconds = tonumber(set('custom_timer_value_seconds', 0, true))
    },
    start_timestamp = 0,
    format = {
        running = set('custom_timer_running_format', 'd: {days}, h: {hours}, m: {minutes}, s: {seconds}', true),
        stopped = set('custom_timer_stopped_format', S('The timer is stopped'), true),
        finished = set('custom_timer_finished_format', S('The timer has finished'), true)
    },
    timer_mode = set('custom_timer_mode', 'countdown', true),
    running = false
}))


-- Timer display format (the HUD element’s content)
set('timer_format', table.concat({
    S('Current Date: @1', '{rd}'),
    S('Ingame Time: @1', '{it}'),
    S('Session Start: @1', '{st}'),
    S('Session Duration: @1', '{sd}')
}, '{_n}'), false, { n = '\n' })


-- Hard reset indicator
set('hard_reset_everything', 'false')
