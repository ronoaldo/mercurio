



mesecons_autotools.register_action("black","left","air", function(user,pos,rad) 
        -- Unselect pos
        mesecons_autotools.set_pos(user,1,nil);
        mesecons_autotools.set_pos(user,2,nil);
        
        -- Update
        mesecons_autotools.render(user)
        mesecons_autotools.zero_stack_counter(user)
        mesecons_autotools.zero_stack_direction(user)
        
end)
mesecons_autotools.register_action("black","left","block", function(user,pos,rad) 
        mesecons_autotools.set_pos(user,1,pos)
        mesecons_autotools.set_pos(user,2,pos)
        
        -- Update
        mesecons_autotools.render(user)
        mesecons_autotools.zero_stack_counter(user)
        mesecons_autotools.zero_stack_direction(user)
end)

mesecons_autotools.register_action("black","right","block", function(user,pos,rad) 
        local pos1 = mesecons_autotools.get_pos(user,1)
        local pos2 = mesecons_autotools.get_pos(user,2)
	local user_direction = radians_to_direction_looking_forward(rad)
        local sel = {}
        sel.pos1 = pos1
        sel.pos2 = pos2

        if not mesecons_autotools.is_full_selection(user) then return end
        
        local done = false
        done = create_bundle_straight_wire(sel ,pos)
        if done == true then
                local direction = tunel_direction(sel,pos)
                local distance = distance_to_selection(sel,pos,direction) -1 
                
                -- set new selection
                local front_wall = tunel_front_wall(sel,pos)
                mesecons_autotools.set_pos(user,1,front_wall.pos1)
                mesecons_autotools.set_pos(user,2,front_wall.pos2)
                shift_selection(user, vector.multiply(direction,distance))
                
                -- Update
                mesecons_autotools.render(user)
                mesecons_autotools.zero_stack_counter(user)
                mesecons_autotools.zero_stack_direction(user)               
        elseif create_bundle_bended_wire(user,sel,pos,user_direction) then
	    -- nothing to do here so far
	    -- update of new selection if inside the function
	end
                
        
        
end)

mesecons_autotools.register_action("black","right","air", function(user,pos,rad) 
                       
end)

        
     
     