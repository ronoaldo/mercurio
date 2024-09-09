



mesecons_autotools.register_action("red","left","air", function(user,pos,rad) 

        
end)
mesecons_autotools.register_action("red","left","block", function(user,pos,rad,under) 
        --minetest.set_node(under,{name="air"})

	if is_circuit_element(under) then
	    mesecons_autotools.set_node(under,{name="air"},"red")
	end
	    
end)

mesecons_autotools.register_action("red","right","block", function(user,pos,rad,under) 
        local sel = {} 
        sel.pos1 = mesecons_autotools.get_pos(user,1)
        sel.pos2 = mesecons_autotools.get_pos(user,2)
        if is_in_selection(sel,under) then
                iterate_selection(sel.pos1,sel.pos2,function(p) 
                                delete_node(p)
                                end)
        else
                if is_circuit_element(under) then
                        delete_node(under)
                end

        end
        

end)

mesecons_autotools.register_action("red","right","air", function(user,pos,rad) 
        if not mesecons_autotools.is_full_selection(user) then return end
        
        local pos = {}
        pos[1] = mesecons_autotools.get_pos(user,1)
        pos[2] = mesecons_autotools.get_pos(user,2)
        
        delete(pos[1],pos[2])
end)

        
     