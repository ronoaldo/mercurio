


function render_circuit(circ,start_x,start_y)
        circ.title = circ.title or ""
--        local spec = "button["..start_x..","..start_y..";10,1;".. "title_" .. circ.id .. ";"..circ.title.."]"
	local spec = "image_button["..start_x+1 ..","..start_y..";1,1;circuit_full.png;;;;]" 

	spec = spec .. "label[" .. start_x+2 .. "," .. start_y+0.5 .. ";" .. circ.title .. "]"
	spec = spec .. "image_button[".. start_x ..","..start_y..";1,1;drop_btn.png;;;;]" 

        return spec,1
end


function f_fold(id,x,y,folded)
        local fold_sign 
        if folded == true then
                fold_sign = "+"
        else
                fold_sign = "-"
        end
        
        local spec = "button["..x..","..y..";1,1;".. "fold_" .. id  ..";".. fold_sign.."]" 
        
        return spec, 1, 0
end


function render_lib(lib,start_x,start_y)        
        local xshift = 1
        local yshift = 1
        local total_yshift = 0
        local total_xshift = 0
        local id = lib.id
        
        lib.title = lib.title or ""
        lib.folded = lib.folded or false
        
        
        local spec = ""
        
        -- fold button
        local ss,shx,shy = f_fold(id,start_x+total_xshift, start_y+total_yshift, lib.folded)
        total_xshift = total_xshift+shx
        total_yshift = total_yshift+shy        
        spec = spec .. ss
               
        
        spec = spec .. 
                "button[".. start_x + total_xshift ..",".. start_y  + total_yshift..
                        ";10,1;".. "title_"..lib.id .. ";"..lib.title.."]"
        total_xshift = start_x + 1
        total_yshift = total_yshift+1
        
        

        
        if lib.folded == false then
                for _,v in ipairs(lib.list) do
                        if v.type == "library" then
                                local sp, ys = render_lib(v, start_x+total_xshift, start_y+total_yshift)
                                spec = spec .. sp
                                total_yshift = total_yshift + ys
                        elseif v.type == "circuit" then
                                local sp, ys = render_circuit(v,start_x+total_xshift, start_y+total_yshift)
                                spec = spec .. sp
                                total_yshift = total_yshift + ys
                        end
                        
                end
        end
        
        return spec, total_yshift
        
end

function traverse_list(list,action)
        if list == nil then return end
        
        for _,v in ipairs(list) do
                if v.type == "circuit" then
                        action(v)
                elseif v.type == "library" then
                        action(v)
                        traverse_list(v.list,action)
                end
                
        end
        
        
end

function foreach_id(list,action)
        if list == nil then return end
        traverse_list(list, function(elem)
                        action(elem.id)
                end)
end

function get_elem_by_id(list,id)
        local found 
        traverse_list(list,function(e)
                        if e.id == id then
                                found = e
                        end
                        
                end)
        return found        
end





minetest.register_on_player_receive_fields(function(player, formname, fields)
     if formname ~= "mesecons_autotools:library_view" then return end   
        local user = player:get_player_name()                
--        local stack = player:get_wielded_item()
--        local data = stack:get_meta():to_table().fields
--        local lib = data.lib
        
        
--        print("lib="..dump(lib))
--	print("fields="..dump(fields))


--        if fields.quit then return end
        
        
        
--[[        
        lib = lib or { id = "<empty>", list = {}, title = "empty" , type = "library"  }
        traverse_list(lib.list,function(elem) 
                        print("#")
                        if fields["fold_".. elem.id] == true then
                                elem.folded = not elem.folded
                        end
                end)
        
        data.lib = lib
        stack:get_meta():from_table({ fields = data})        
        player:set_wielded_item(stack)
         
        local formspec = render_formspec(lib)
        minetest.show_formspec(user, "mesecons_autotools:library_view", formspec)               
    ]]--    
end)

function render_formspec(lib)
        local formspec =  "formspec_version[3]"..                
                "size[32,25]"
                
        formspec = formspec ..  render_lib(lib,1,1)
        return formspec
end


      lib = {
                id = "l1", title = "library bla bla ", type = "library",
                list = {
                        {id = "c1", type="circuit", title="somethign something"},
                        {id = "c2", type="circuit", title="somethign something2"},
                        {id = "l2", type="library", title="wooihoihoh/", folded = false,
                                        list = {
                                                {id = "c11", type="circuit", title="somethign something"},
                                                {id = "c21", type="circuit", title="somethign something2"},
                                        }
                                
                        },
                        {id = "c111", type="circuit", title="circuit sak/32/d0"},
                        {id = "c1x", type="circuit", title="somethign something"},
                        {id = "c2x", type="circuit", title="somethign something2"},
                        {id = "l2x", type="library", title="wooihoihoh/", folded = false,
                                        list = {
                                                {id = "c11x", type="circuit", title="somethign something"},
                                                {id = "c21x", type="circuit", title="somethign something2"},
                                        }
                                
                        },
                        {id = "c111x", type="circuit", title="circuit sak/32/d0"},
                        {id = "c111x", type="circuit", title="circuit sak/32/d0"},
                        {id = "c111x", type="circuit", title="circuit sak/32/d0"},
                        {id = "c111x", type="circuit", title="circuit sak/32/d0"},
                        {id = "c111x", type="circuit", title="circuit sak/32/d0"},
                        {id = "c111x", type="circuit", title="circuit sak/32/d0"},
                        {id = "c111x", type="circuit", title="circuit sak/32/d0"},
                        {id = "c111x", type="circuit", title="circuit sak/32/d0"},
                        {id = "c111x", type="circuit", title="circuit sak/32/d0"},
                        {id = "c111x", type="circuit", title="circuit sak/32/d0"},
                        {id = "c111x", type="circuit", title="circuit sak/32/d0"},
                        {id = "c111x", type="circuit", title="circuit sak/32/d0"},
                        {id = "c111x", type="circuit", title="circuit sak/32/d0"},
                        {id = "c111x", type="circuit", title="circuit sak/32/d0"},
                        {id = "c111x", type="circuit", title="circuit sak/32/d0"},
                        {id = "c111x", type="circuit", title="ostatni ak/32/d0"},


                }
        }
        
function generate_empty_library(file)
    local lib = {
	id = file, list = {} , title = "" , type = "library" , folded = false
    }
    return lib
end
        
function on_place_library(itemstack, player, pointed_thing)
        local user = player:get_player_name()
        local stack = player:get_wielded_item()
        local fields = stack:get_meta():to_table().fields
        
        
--        print("DU:"..dump(itemstack:get_meta():to_table()))
--        print("item stackc:" .. dump(itemstack))
        
--        if data.count == nil then data.count = 0 end
--        data.count = data.count + 1 
--[[	local lib = {}
	if fields.file == nil then
	    fields.file = generate_file_name_library(user)
	    lib = generate_empty_library(fields.file)
	    save_table_to_file(fields.file,lib)
	end 
    ]]--    
        stack:get_meta():from_table({ fields = fields})
--        player:set_wielded_item(stack)      
               
        --lib = lib
        local formspec = render_formspec(lib)
--        print("formtspec="..formspec)
         
        
        minetest.show_formspec(user, "mesecons_autotools:library_view", formspec)
        
end



minetest.register_tool("mesecons_autotools:library", {
                description = "Library of Circuits",
                inventory_image = "library.png",                                
                stack_max = 1,
                
                
    --            on_place = on_place_library,
		on_use = on_place_library,
--[[                
                on_use = on_use_new_circuit,
                
                on_secondary_use = none,                
    ]]--            
        })
        