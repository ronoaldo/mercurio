
local function get_right_nr(user,rad)
        local dir = radians_to_vectors(rad)
        local left = dir.left
        local right = dir.right
        
        local lpos = {}
        lpos[1] = mesecons_autotools.get_pos(user,1)
        lpos[2] = mesecons_autotools.get_pos(user,2)
        local posrigth_number
        
        if lpos[1] == nil then return end
        if lpos[2] == nil then return end
        
        
        
        
        if right.x == 1 then
                if lpos[1].x > lpos[2].x then
                        posrigth_number = 1
                else
                        posrigth_number = 2
                end                
        elseif right.x == -1 then
                if lpos[1].x > lpos[2].x then
                        posrigth_number = 2
                else
                        posrigth_number = 1
                end                
        elseif right.z == 1 then
                if lpos[1].z > lpos[2].z then
                        posrigth_number = 1
                else
                        posrigth_number =2
                end
        elseif right.z == -1 then
                if lpos[1].z > lpos[2].z then
                        posrigth_number = 2
                else
                        posrigth_number = 1 
                end
                
        end
        
        return posrigth_number
        
end


local function move_right(user,rad)
        local dir = radians_to_vectors(rad)
        local left = dir.left
        local right = dir.right

        local right_nr = get_right_nr(user,rad) 
        local lpos = {}
        lpos[1] = mesecons_autotools.get_pos(user,1)
        lpos[2] = mesecons_autotools.get_pos(user,2)
        
        
        if right == nil then return end
        if right_nr == nil then return end
        if lpos[1] == nil then return end
        if lpos[2] == nil then return end
               
        
        local new_pos = vector.add(lpos[right_nr], right)
        mesecons_autotools.set_pos(user,right_nr, new_pos)
        
        -- Update
        mesecons_autotools.render(user)
        mesecons_autotools.zero_stack_counter(user)
end

local function can_shrink(user,right)
        local lpos = {}
        lpos[1] = mesecons_autotools.get_pos(user,1)
        lpos[2] = mesecons_autotools.get_pos(user,2)

        if right == nil then return end
        if lpos[1] == nil then return end
        if lpos[2] == nil then return end       

        if right.x ~= 0 then
                if lpos[1].x == lpos[2].x then
                        return false
                else
                        return true
                end
        end
        
        if right.z ~= 0 then
                if lpos[1].z == lpos[2].z then
                        return false
                else
                        return true
                end
        end
end


local function move_left(user,rad)
        local dir = radians_to_vectors(rad)
        local left = dir.left
        local right = dir.right

        
        if can_shrink(user,right) == false then return end
        
        
        local right_nr = get_right_nr(user,rad)
        local lpos = {}
        lpos[1] = mesecons_autotools.get_pos(user,1)
        lpos[2] = mesecons_autotools.get_pos(user,2)
        
        
        if left == nil then return end
        if lpos[1] == nil then return end
        if lpos[2] == nil then return end       
        
        
        
        local new_pos = vector.add(lpos[right_nr], left)
        mesecons_autotools.set_pos(user,right_nr, new_pos)
        
        -- Update
        mesecons_autotools.render(user)
        mesecons_autotools.zero_stack_counter(user)

end


mesecons_autotools.register_action("white","left","air", function(user,pos,rad) 
        move_left(user,rad)

        
end)
mesecons_autotools.register_action("white","left","block", function(user,pos,rad) 
        move_left(user,rad)               
end)

mesecons_autotools.register_action("white","right","block", function(user,pos,rad) 
        move_right(user,rad)
end)

mesecons_autotools.register_action("white","right","air", function(user,pos,rad) 
        move_right(user,rad)               
end)

        
     