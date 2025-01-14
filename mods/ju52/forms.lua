
function ju52.paint_formspec(name)
    local basic_form = table.concat({
        "formspec_version[3]",
        "size[4.0, 4.2]",
    },"")

    basic_form = basic_form.."image_button[0.5,0.5;3,1;ju52_p_lufthansa.png;lufthansa;Lufthansa;false;true;]"
    basic_form = basic_form.."image_button[0.5,1.6;3,1;ju52_p_lufthansa.png;lufthansa2;Lufthansa 2;false;true;]"
    basic_form = basic_form.."image_button[0.5,2.7;3,1;ju52_p_luftwaffe.png;luftwaffe;Luftwaffe;false;true;]"
    --basic_form = basic_form.."image_button[1,4.3;3,1;ju52_white.png^[multiply:#2b2b2b;black;Black;false;true;]"

    minetest.show_formspec(name, "ju52:paint", basic_form)
end

minetest.register_on_player_receive_fields(function(player, formname, fields)
	if formname == "ju52:paint" then
        local name = player:get_player_name()
        local plane_obj = airutils.getPlaneFromPlayer(player)
        if plane_obj == nil then
            minetest.close_formspec(name, "ju52:paint")
            return
        end
        local ent = plane_obj:get_luaentity()
        if ent then

            if fields.lufthansa then ent._skin = "ju52_skin_lufthansa.png" end
            if fields.lufthansa2 then ent._skin = "ju52_skin_lufthansa2.png" end
            if fields.luftwaffe then ent._skin = "ju52_skin_luftwaffe.png" end

            airutils.param_paint(ent, "#FFFFFF", "#FFFFFF")
        end
        minetest.close_formspec(name, "ju52:paint")
	end
end)
