local function on_use_formula_book(itemstack, player, pointed_thing)
   local user = player:get_player_name()
  local formspec = 
                "formspec_version[3]"..                
                "size[32,25]"..                              
                "label[15,0.7;FSM generator]"..
                
                
                "field[0.5,2;15,1;title;Name;]"..
                "textarea[0.5,4;15,15;text;" .. "Code:" .. ";" .. "" .. "]" ..
                "textarea[16.5,2;15,17;d;" .. "Compilation Logs:" .. ";" .. "" .. "]" ..
                
               
                "button_exit[0.5,19;3,1;save;" .. "Save" .. "]" .. 
                "button_exit[14.5,20;3,1;compile;" .. "Compile" .. "]" ..
                "button_exit[28.5,20;3,1;generate;" .. "Generate" .. "]" .. 
                ""
  minetest.show_formspec(user, "mesecons_autotools:formula_show", formspec)
end

--minetest.register_craftitem("mesecons_autotools:circuit_empty", {
minetest.register_tool("mesecons_autotools:formula", {
                description = "Logic formula generator",
                inventory_image = "formula_book.png",                                
                stack_max = 1,
               
                on_use = on_use_formula_book,
               
               --[[
               on_place = none,
                on_secondary_use = none,                
                --]]
        })
