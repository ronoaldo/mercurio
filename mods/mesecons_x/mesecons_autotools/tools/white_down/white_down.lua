
local function move_up(user)        
        local vector_up = vector.new(0,1,0)
        
        
        local lpos = {}
        lpos[1] = mesecons_autotools.get_pos(user,1)
        lpos[2] = mesecons_autotools.get_pos(user,2)
        local posdown_number
        
        if lpos[1] == nil then return end
        if lpos[2] == nil then return end
        
        if lpos[1].y == lpos[2].y then return end
        
        if lpos[1].y < lpos[2].y then
                posdown_number = 1
        else
                posdown_number = 2
        end
        
        local new_pos = vector.add(lpos[posdown_number], vector_up)
        mesecons_autotools.set_pos(user,posdown_number, new_pos)
        
        -- Update
        mesecons_autotools.render(user)
        mesecons_autotools.zero_stack_counter(user)
        
end

local function move_down(user)
         local vector_up = vector.new(0,-1,0)
        
        
        local lpos = {}
        lpos[1] = mesecons_autotools.get_pos(user,1)
        lpos[2] = mesecons_autotools.get_pos(user,2)
        local posdown_number
        
        if lpos[1] == nil then return end
        if lpos[2] == nil then return end
        
        
        
        if lpos[1].y < lpos[2].y then
                posdown_number = 1
        else
                posdown_number = 2
        end
        
        local new_pos = vector.add(lpos[posdown_number], vector_up)
        mesecons_autotools.set_pos(user,posdown_number, new_pos)
        
        -- Update
        mesecons_autotools.render(user)
        mesecons_autotools.zero_stack_counter(user)
end

mesecons_autotools.register_action("white_down","left","air", function(user,pos,rad) 
        move_down(user);
end)
mesecons_autotools.register_action("white_down","left","block", function(user,pos,rad) 
        move_down(user);
end)

mesecons_autotools.register_action("white_down","right","block", function(user,pos,rad) 
        move_up(user);               
end)

mesecons_autotools.register_action("white_down","right","air", function(user,pos,rad) 
        move_up(user);               
end)
