

function is_mese(node)
        if node.name == "default:mese" or 
                node.name == "mesecons_extrawires:mese_powered" then
                        return true
                else
                        return false
                end
                
end

function mese_off(node)
        local n = {}
        if is_mese(node) then
                n.name = "default:mese"
                n.param2 = node.param2
                return n
        else
                return node
        end
end

        
                

function wire_off(node)
        local n = {}
        local name = node.name       
        n.param2 = node.param2
        
        if is_wire_node(node) then
                if string.match(name, "^mesecons_extrawires:crossover_") ~= nil then
                        n.name = "mesecons_extrawires:crossover_off"
                        return n
                else
                        local base,state = string.match(name, "^(.*)_([^_]+)$")
                        base = base or ""
                        state = state or ""
                        
                        local name_off = base .. "_" .. "off"                        
                        n.name = name_off
                        return n 
                end
                
        else
                return node
        end        
end



local function refresh_selection(pos1,pos2)
        iterate_selection(pos1,pos2, function(pos) 
                -- mesecon.on_placenode(pos,minetest.get_node(pos))
                            
                                local node = minetest.get_node(pos)
                                local new_node  = wire_off(node)
                          
                        
                
                        local cur_node = minetest.get_node(pos)
                        mesecon.on_dignode(pos,cur_node)
                        ref_remove(pos,cur_node)
                        
                        minetest.set_node(pos,new_node)
                        mesecon.on_placenode(pos,new_node)
                        ref_place(pos,new_node)
                        
        end)

end


        
mesecons_autotools.register_action("refresh","left","air", function(user,pos,rad) 
  
        
end)
mesecons_autotools.register_action("refresh","left","block", function(user,pos,rad) 
     --mesecon.on_placenode(pos, minetest.get_node(pos))
     refresh_selection(pos,pos)
end)

mesecons_autotools.register_action("refresh","right","block", function(user,pos,rad) 
        if not mesecons_autotools.is_full_selection(user) then return end
        
        local pos1 = mesecons_autotools.get_pos(user,1)
        local pos2 = mesecons_autotools.get_pos(user,2)
        refresh_selection(pos1,pos2)       
        
end)

mesecons_autotools.register_action("refresh","right","air", function(user,pos,rad) 
         if not mesecons_autotools.is_full_selection(user) then return end
        
        local pos1 = mesecons_autotools.get_pos(user,1)
        local pos2 = mesecons_autotools.get_pos(user,2)
        refresh_selection(pos1,pos2)            
end)

        
     
     
     