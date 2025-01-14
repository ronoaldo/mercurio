local m = mtimer
local S = m.translator


-- Get parsed timer data
--
-- Returns the parsed timer data (i.e. all variables are replaced with their
-- respective values) for the given player referenced by the name.
--
-- The returned table holds the formatted version as well as the individual
-- times (session start, current date, etc.) as configured via the respective
-- dialogs. This will be used for the Timer itself as well as in the
-- configuration formspec.
--
-- @param player_name The name of the player to get the timer data for
-- @return table The timer data of the player
mtimer.get_timer_data = function (player_name)
    local player_meta = core.get_player_by_name(player_name):get_meta()
    local time_data = mtimer.get_times(player_name)
    local ingame_time = time_data.ingame_time.formatted
    local session_start_time = time_data.session_start_time.formatted
    local session_duration = time_data.session_duration.formatted

    local values = {
        format = player_meta:get_string(m.meta.timer_format.key),
        real_world_date = time_data.real_time.formatted,
        ingame_time = time_data.ingame_time.formatted,
        session_start_time = time_data.session_start_time.formatted,
        session_duration = time_data.session_duration.formatted,
        host_time = time_data.host_time.formatted,
        custom_timer = time_data.custom_timer.formatted
    }

    values['formatted'] = values.format:gsub('{[0-9a-z]+}', {
        ['{rd}'] = values.real_world_date,
        ['{it}'] = values.ingame_time,
        ['{st}'] = values.session_start_time,
        ['{sd}'] = values.session_duration,
        ['{ht}'] = values.host_time,
        ['{ct}'] = values.custom_timer
    })

    return values
end
