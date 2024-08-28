




local function stack_up(user)
        if not mesecons_autotools.is_full_selection(user) then return end
        
        
        local pos = {}
        pos[1] = mesecons_autotools.get_pos(user,1)
        pos[2] = mesecons_autotools.get_pos(user,2)
        
        
        
        local ymax = math.max(pos[1].y,pos[2].y)
        local ymin = math.min(pos[1].y,pos[2].y)
        local shift_up = ymax - ymin + 1
        local shift_vector = { x= 0, y = shift_up , z=  0 }
        copy(pos[1],pos[2],shift_vector)
        shift_selection(user,shift_vector)
        
        
        if not vector.equals(mesecons_autotools.get_stack_direction(user),{x=0,y=1,z=0}) then
               mesecons_autotools.zero_stack_counter(user);               
        end
        
        
        mesecons_autotools.inc_stack_counter(user)
        mesecons_autotools.set_stack_direction(user, { x=0,y=1,z=0 } )
        
        
        -- Update
        mesecons_autotools.render(user)
        
        
        
end


local function stack_remove(user)
        if not mesecons_autotools.is_full_selection(user) then return end
        
        
        local pos = {}
        pos[1] = mesecons_autotools.get_pos(user,1)
        pos[2] = mesecons_autotools.get_pos(user,2)
        
        
        
        local ymax = math.max(pos[1].y,pos[2].y)
        local ymin = math.min(pos[1].y,pos[2].y)
        local shift_down = ymax - ymin + 1
        local shift_vector = { x= 0, y = -shift_down , z=  0 }
        
        if mesecons_autotools.get_stack_counter(user) == 0  then 
                return 
        end
        
        if not vector.equals(mesecons_autotools.get_stack_direction(user),{x=0,y=1,z=0}) then return end
        
        delete(pos[1],pos[2])
        shift_selection(user,shift_vector)
        
        mesecons_autotools.dec_stack_counter(user)
        
        
        
        -- Update
        mesecons_autotools.render(user)
end




mesecons_autotools.register_action("orange_up","left","air", function(user,pos,rad) 
        stack_remove(user)
end)
mesecons_autotools.register_action("orange_up","left","block", function(user,pos,rad) 
        stack_remove(user)               
end)

mesecons_autotools.register_action("orange_up","right","block", function(user,pos,rad) 
       stack_up(user)                
end)

mesecons_autotools.register_action("orange_up","right","air", function(user,pos,rad) 
       stack_up(user)                
end)

        
     