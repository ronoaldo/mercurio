local MP = minetest.get_modpath("promise")

Promise = {
	api_version = 1
}

dofile(MP.."/promise.lua")
dofile(MP.."/util.lua")
dofile(MP.."/http.lua")
dofile(MP.."/formspec.lua")
dofile(MP.."/async.lua")

if minetest.get_modpath("mtt") and mtt.enabled then
	local http = minetest.request_http_api()

	dofile(MP .. "/promise.spec.lua")
	dofile(MP .. "/formspec.spec.lua")
	dofile(MP .. "/util.spec.lua")
	dofile(MP .. "/async.spec.lua")
	if http then
		loadfile(MP .. "/http.spec.lua")(http)
	end
end