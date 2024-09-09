
function can_move_into(sel,direction)        
        local front_wall = front_wall_by_direction(sel,direction)
        
        local pos1 = vector.new(front_wall.pos1)
        local pos2 = vector.new(front_wall.pos2)
        
        pos1 = vector.add(pos1,direction)
        pos2 = vector.add(pos2,direction)
        
        local shifted ={pos1=pos1,pos2=pos2}
        
        local result = {}
        iterate_selection(pos1,pos2, function(pos)
                local node = minetest.get_node(pos)
                local name = node.name

                if name == "air" then 
                        return
                end
                if
                        name == "mesecons_insulated:insulated_off" or
                        name == "mesecons_insulated:insulated_on" then
                                
                        local pins = get_pins_from_pos(pos)
                        local dpin = get_pin_from_direction(direction)
                        if pins[dpin] == 1 then 
                                return
                        else
                                table.insert(result,false)
                                return
                        end
                        
                        
                end
                return  table.insert(result,false)
        end)

        for _,v in pairs(result) do
                if v == false then
                        return false
                end
        end
        
        return true
end


function is_pos_connected(pos,direction)
        local node = minetest.get_node(pos)
        
        local pins = get_pins_from_pos(pos)
        local dpin = get_pin_from_direction(direction)
        
        -- no sticking out
        if pins[dpin] == 0 then return false end
        
        
        local neigh_pos
        local neigh_pins
        local connect_pin
        
        -- checking pos[out] <-> neigh[in]
        
        pins = get_pins_from_pos(pos,"output")
        dpin = get_pin_from_direction(direction)
        neigh_pos = hop_pos(pos,dpin)
        neigh_pins = get_pins_from_pos(neigh_pos,"input")
        connect_pin = neigh_pins[ hop_pin(dpin) ]
        
        if connect_pin == 1 then 
                return true
        end
        
        -- checking pos[in] <-> neidth[out]
        
        pins = get_pins_from_pos(pos,"input")
        dpin = get_pin_from_direction(direction)
        neigh_pos = hop_pos(pos,dpin)
        neigh_pins = get_pins_from_pos(neigh_pos,"output")
        connect_pin = neigh_pins[ hop_pin(dpin) ]
        
        if connect_pin == 1 then 
                return true
        end
        
        
        
        return false
        

        
--[[        
        local neigh_pos = hop_pos(pos,dpin)
        local neigh_pins = get_pins_from_pos(neigh_pos)
        local connect_pin = neigh_pins[ hop_pin(dpin) ]
        
        if connect_pin == 1 then 
                return true
        else
                return false
        end
]]--
end


function generate_tail_wires(back_wall,direction)
        local pos1 = back_wall.pos1
        local pos2 = back_wall.pos2
        
        local back_direction = vector.multiply(direction,-1)
        local bd_pin = get_pin_from_direction(back_direction)
        
        
        local list_pos = {}
        iterate_selection(pos1,pos2, function(pos)
                        if is_pos_connected(pos,back_direction) then
                                table.insert(list_pos,pos)
                        end
                end)
        return list_pos
end

function put_tail_wires(list,direction)
        local node = {} 
        node.name = "mesecons_insulated:insulated_off"
        node.param2 = 0
        for _,pos in ipairs(list) do
                if direction.x ~= 0 then
                       node.param2 = 0 
                else
                        node.param2 = 1
                end
                --minetest.set_node(pos,node)
                mesecons_autotools.set_node(pos,node,"put_tail_wires")
                
        end
        
end


function get_back_wall(sel,direction)
       return front_wall_by_direction(sel, vector.multiply(direction,-1)) 
end




local function move_selection(user,rad,click)
        local dir = radians_to_vectors(rad)
        local left = dir.left
        local right = dir.right
        
        local pos = {}
        pos[1] = mesecons_autotools.get_pos(user,1)
        pos[2] = mesecons_autotools.get_pos(user,2)
        
        
        if pos[1] == nil then return end
        if pos[2] == nil then return end
        
        
        -- compute shift vector
        
        local direction = {}
        if click == "left" then 
                direction = left 
        else
                direction = right
        end
        
        local buffor = {}
        local tail = {}
        local sel = { pos1=pos[1], pos2=pos[2]}
        local back_wall = get_back_wall(sel,direction)
        
        if not can_move_into(sel,direction) then return end
        
        copy_to_buffor(pos[1],pos[2],buffor)
        tail = generate_tail_wires(back_wall,direction)
        

        delete(pos[1],pos[2])
        paste_from_buffor(direction,buffor)
        put_tail_wires(tail,direction)
        
        shift_selection(user,direction)        
        
        
        -- Update
        mesecons_autotools.render(user)
        mesecons_autotools.zero_stack_counter(user)
        mesecons_autotools.zero_stack_direction(user)
end






mesecons_autotools.register_action("yellow","left","air", function(user,pos,rad) 
        move_selection(user,rad,"left")
end)
mesecons_autotools.register_action("yellow","left","block", function(user,pos,rad) 
        move_selection(user,rad,"left")
end)

mesecons_autotools.register_action("yellow","right","block", function(user,pos,rad) 
        move_selection(user,rad,"right")
end)

mesecons_autotools.register_action("yellow","right","air", function(user,pos,rad) 
        move_selection(user,rad,"right")
end)

        
     
     