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
        
        local txt = ""
        if minetest[param] then
            txt = to_json(minetest[param], true)
        else
            txt = "Not found: " .. param
        end
        
        f = f .. minetest.formspec_escape(txt) .. "]"
        minetest.show_formspec(name, "server_metadata", f)
    end
})