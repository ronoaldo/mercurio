local modname = minetest.get_current_modname()
local modpath = minetest.get_modpath(modname)
local S = minetest.get_translator(modname)

emote = {
	modname = modname,
	modpath = modpath,

	S = S,

	log = function(level, messagefmt, ...)
		return minetest.log(level, ("[%s] %s"):format(modname, messagefmt:format(...)))
	end,

	dofile = function(...)
		return dofile(table.concat({modpath, ...}, DIR_DELIM) .. ".lua")
	end,
}

emote.dofile("settings")
emote.dofile("util")
emote.dofile("api")
emote.dofile("entity")

local model = player_api.registered_models["character.b3d"]

emote.register_emote("stand", {
	anim_name = "stand",
	speed = 30,
	description = S("stands up")
})

emote.register_emote("sit", {
	anim_name = "sit",
	speed = 30,
	description = S("sits")
})

emote.register_emote("lay", {
	anim_name = "lay",
	speed = 30,
	description = S("lies down")
})

emote.register_emote("sleep", { -- alias for lay
	anim_name = "lay",
	speed = 30,
	description = S("falls asleep")
})

model.animations.wave = {x = 192, y = 196, override_local = true}
emote.register_emote("wave", {
	anim_name = "wave",
	speed = 15,
	stop_after = 4,
	description = S("waves")
})

model.animations.point = {x = 196, y = 196, override_local = true}
emote.register_emote("point", {
	anim_name = "point",
	speed = 30,
	description = S("points")
})

model.animations.freeze = {x = 205, y = 205, override_local = true}
emote.register_emote("freeze", {
	anim_name = "freeze",
	speed = 30,
	description = S("freezes")
})

--[[
-- testing tool - punch any node to test attachment code
]]--
minetest.register_tool("emote:sleep", {
	description = "use me on a bed bottom",
	groups = {not_in_creative_inventory = 1},
	on_use = function(itemstack, user, pointed_thing)
		-- the delay here is weird, but the client receives a mouse-up event
		-- after the punch and switches back to "stand" animation, undoing
		-- the animation change we're doing.
		minetest.after(0.5, emote.attach_to_node, user, pointed_thing.under)
	end
})
