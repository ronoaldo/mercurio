local function stack_right(user,rad)
        local dir = radians_to_vectors(rad)
        local left = dir.left
        local right = dir.right
        
        local pos = {}
        pos[1] = mesecons_autotools.get_pos(user,1)
        pos[2] = mesecons_autotools.get_pos(user,2)
        
        
        if pos[1] == nil then return end
        if pos[2] == nil then return end
        
        
        -- compute shift vector
        
        local shift_vector = {} 
        if right.x ~= 0 then
                shift_vector.x = right.x * (math.abs(pos[2].x - pos[1].x)+1)
                shift_vector.z = 0
                shift_vector.y = 0
        elseif right.z ~= 0 then
                shift_vector.x = 0
                shift_vector.y = 0
                shift_vector.z = right.z * (math.abs(pos[2].z - pos[1].z)+1)
        end
        
        copy(pos[1],pos[2],shift_vector)
        shift_selection(user,shift_vector)
        
        -- Update
        mesecons_autotools.render(user)
        
        
        local old_stack_direction = mesecons_autotools.get_stack_direction(user)
        if not vector.equals(old_stack_direction,right) then
               mesecons_autotools.set_stack_direction(user,right)
               mesecons_autotools.zero_stack_counter(user)
        end
        mesecons_autotools.inc_stack_counter(user)
       
        
end


local function stack_remove(user,rad)
        local dir = radians_to_vectors(rad)
        local left = dir.left
        local right = dir.right
        
        local pos = {}
        pos[1] = mesecons_autotools.get_pos(user,1)
        pos[2] = mesecons_autotools.get_pos(user,2)
        
        
        if pos[1] == nil then return end
        if pos[2] == nil then return end
        
        if not vector.equals(mesecons_autotools.get_stack_direction(user),right) then return end
        if mesecons_autotools.get_stack_counter(user) == 0  then return end        
        
        -- compute shift vector
        local shift_vector = {} 
        if right.x ~= 0 then
                shift_vector.x = - right.x * (math.abs(pos[2].x - pos[1].x)+1)
                shift_vector.z = 0
                shift_vector.y = 0
        elseif right.z ~= 0 then
                shift_vector.x = 0
                shift_vector.y = 0
                shift_vector.z = - right.z * (math.abs(pos[2].z - pos[1].z)+1)
        end
        
        delete(pos[1],pos[2])
        shift_selection(user,shift_vector)
        
        mesecons_autotools.dec_stack_counter(user)
        
        
        -- Update
        mesecons_autotools.render(user)
        
   
end





mesecons_autotools.register_action("orange","left","air", function(user,pos,rad) 
        stack_remove(user,rad)
end)
mesecons_autotools.register_action("orange","left","block", function(user,pos,rad) 
        stack_remove(user,rad)
end)

mesecons_autotools.register_action("orange","right","block", function(user,pos,rad) 
        stack_right(user,rad)
end)

mesecons_autotools.register_action("orange","right","air", function(user,pos,rad) 
        stack_right(user,rad)
end)

        
     