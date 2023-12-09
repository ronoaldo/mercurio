-- Syntax suggar
local to_json = mercurio.to_json

minetest.register_chatcommand("server_metadata", {
    privs = { server = true },
    description = "Shows server metadata tables to server admins.",
    func = function(name, param)
        local f = "formspec_version[5]"..
            "size[20,14]"..
            "button_exit[16.6,12.8;3,0.9;exit;OK]"..
            "textarea[0.5,0.5;19.1,12.1;server_metadata;;"
        local meta = minetest[param]

        local txt = "minetest."..param.." values (type= ".. type(meta) .."):\n\n"

        local buff = {}
        if meta then
            if type(meta) == "table" then
                for k, v in pairs(meta) do
                    table.insert(buff, k ..": ".. to_json(v))
                end
            else
                table.insert(buff, to_json(meta))
            end
        else
            txt = "Not found: " .. param
        end
        txt = txt .. table.concat(buff, "\n")

        f = f .. minetest.formspec_escape(txt) .. "]"
        minetest.show_formspec(name, "server_metadata", f)
    end
})

minetest.override_chatcommand("msg", {
    func = function(sender, message)
        minetest.chat_send_player(sender, "Command not found")
    end
})