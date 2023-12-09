local modname = minetest.get_current_modname()
local path = minetest.get_modpath(modname)
local mpath = path .. "/modules"
local http = minetest.request_http_api()
local durl = minetest.settings:get(modname .. ".report.discord_url")

shadowmute = {}

if not http then minetest.log("error", "[" .. modname .. "]: not added to secure.http_mods") end
if not durl then minetest.log("error", "[" .. modname .. "]: discord url not set") end

function shadowmute.send_discord_message(data)
    local json = minetest.write_json(data)

    if http and durl then
        http.fetch({
            url = durl,
            method = "POST",
            extra_headers = {"Content-Type: application/json"},
            data = json
        }, function(output)

        end)
    end
end

for _, file in pairs(minetest.get_dir_list(mpath, false)) do
    if minetest.settings:get_bool(modname .. "." .. file:sub(1, -5), true) then
        dofile(mpath .. "/" .. file)
    end
end