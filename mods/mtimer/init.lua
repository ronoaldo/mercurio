local modpath = core.get_modpath('mtimer')..DIR_DELIM
local syspath = modpath..'system'..DIR_DELIM
local fspath = syspath..'formspecs'..DIR_DELIM


-- Set initial global `mtimer` table
--
-- The sub tables are filesd programmatically.
--
-- @see ./system/formspecs/*
-- @see ./system/load_configuration.lua
mtimer = {
    translator = core.get_translator('mtimer'),
    dialog = {},
    meta = {}
}


-- Load configuration
dofile(syspath..'load_configuration.lua')


-- Load formspec-related files
dofile(syspath..'formspec_helpers.lua')
dofile(syspath..'on_receive_fields.lua')
for _,f in pairs(core.get_dir_list(fspath, false)) do dofile(fspath..f) end


-- Load timer actions
dofile(syspath..'get_times.lua')
dofile(syspath..'get_timer_data.lua')
dofile(syspath..'update_timer.lua')


-- Load player-related functionality
dofile(syspath..'chat_command.lua')
dofile(syspath..'on_joinplayer.lua')
dofile(syspath..'register_globalstep.lua')
