



local function move_selection(user,rad,click)    
        local pos = {}
        pos[1] = mesecons_autotools.get_pos(user,1)
        pos[2] = mesecons_autotools.get_pos(user,2)
        
        
        if pos[1] == nil then return end
        if pos[2] == nil then return end
        
        
        -- compute shift vector
        
        local shift_vector = {}
        if click == "up" then 
                shift_vector = {x=0,y=1,z=0}
        else
                shift_vector = {x=0,y=-1,z=0}
        end
        
        local new_pos1 = vector.add(pos[1],shift_vector)
        local new_pos2 = vector.add(pos[2],shift_vector)
        
        
        --[[
        if not is_empty_selection(new_pos1,new_pos2) then 
                return
        end
        ]]--
        local sel = { pos1=pos[1], pos2=pos[2]}
        if not can_move_into(sel,shift_vector) then return end
        
        
        local buffor = {}
        copy_to_buffor(pos[1],pos[2],buffor)
        delete(pos[1],pos[2])
        paste_from_buffor(shift_vector,buffor)
        
        shift_selection(user,shift_vector)        
        
        
        -- Update
        mesecons_autotools.render(user)
        mesecons_autotools.zero_stack_counter(user)
        mesecons_autotools.zero_stack_direction(user)
        
        
end






mesecons_autotools.register_action("yellow_updown","left","air", function(user,pos,rad) 
        move_selection(user,rad,"down")
end)
mesecons_autotools.register_action("yellow_updown","left","block", function(user,pos,rad) 
        move_selection(user,rad,"down")
end)

mesecons_autotools.register_action("yellow_updown","right","block", function(user,pos,rad) 
        move_selection(user,rad,"up")
end)

mesecons_autotools.register_action("yellow_updown","right","air", function(user,pos,rad) 
        move_selection(user,rad,"up")
end)

        