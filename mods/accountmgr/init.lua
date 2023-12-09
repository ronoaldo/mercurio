local S = minetest.get_translator("accountmgr")

local bulk_create_dialog = dofile(minetest.get_modpath("accountmgr") .. "/bulk_create.lua")

minetest.register_chatcommand("accounts", {
	privs = { server = true },
	func = function(name, params)
		if not minetest.get_player_by_name(name) then
			return false, "You need to be online"
		end

		bulk_create_dialog.show(name)
		return true
	end,
})


minetest.register_on_prejoinplayer(function(name, ip)
	local allow_user_register = minetest.settings:get_bool("accountmgr.allow_user_register", true)
	if allow_user_register then
		return
	end

	local handler = minetest.get_auth_handler()
	if not handler.get_auth(name) then
		return S("User not found, registration is closed on this server")
	end
end)
