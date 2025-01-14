local m = mtimer
local S = m.translator
local esc = core.formspec_escape
local line = mtimer.get_table_line


-- Real Time Universal Formspec
--
-- This formspec can be used to show formatting options for all real-world time
-- values that can be formatted within mTimer. Since all the real-world times
-- are defined identically this formspec exists so it has to be defined only
-- once and can be re-used as needed.
--
-- @param player_name The name of the player to show the formspec to
-- @config time_type  A time type that is provided by the `get_times` function
-- @return void
-- @see mtimer.get_times
mtimer.dialog.real_time_universal = function (player_name, config)
    local time_data = mtimer.get_times(player_name)[config.time_type]
    local vars = time_data.variables

    mtimer.show_formspec(config.formspec_name, {
        title = config.title,
        show_to = player_name,
        height = 9,
        formspec = {
            'field_close_on_enter[format;false]',
            'field[0,0;+contentWidth,0.5;format;;'..esc(time_data.format)..']',
            'container[0,1.5]',
            line(0,  '',                 S('Variable'), S('Current Value')),
            line(1,  '-'),
            line(2,  S('Hours (24h)'),        '{24h}',       vars.hours_24),
            line(3,  S('Hours (12h)'),        '{12h}',       vars.hours_12),
            line(4,  S('Minutes'),            '{min}',       vars.minutes),
            line(5,  S('Seconds'),            '{sec}',       vars.seconds),
            line(6,  S('Meridiem Indicator'), '{mi}',        vars.indicator),
            line(7,  '-'),
            line(8,  S('Day Name'),           '{dname}',     vars.dayname),
            line(9,  S('Month Name'),         '{mname}',     vars.monthname),
            line(10,  '-'),
            line(11, S('Year'),               '{year}',      vars.year),
            line(12, S('Month'),              '{month}',     vars.month),
            line(13, S('Day'),                '{day}',       vars.day),
            line(14, '-'),
            line(15, S('ISO 8601 Date'),      '{isodate}',   vars.iso8601_date),
            line(16, S('ISO 8601 Time'),      '{isotime}',   vars.iso8601_time),
            line(17, S('Timestamp'),          '{timestamp}', vars.timestamp),
            line(18, '-'),
            line(19, S('Current Result'), esc(time_data.formatted), ''),
            'container_end[]'
        }
    })
end
