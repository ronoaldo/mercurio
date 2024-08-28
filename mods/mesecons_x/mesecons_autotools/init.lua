dofile(minetest.get_modpath("mesecons_autotools").."/debug.lua");


mesecons_autotools = {}
mesecons_autotools.users = {}
mesecons_autotools.actions = {}


-- Basic functions

--[[
mesecons_autotools = 
{ 
        user_name = {
                pos[1..2] = { x = number, y = number, z = number}
                stack_direction = {x,y,z}
                stack_counter = number
                entities = <list of minetest.add_entity()>
                options = {
                        option1 = value1
                        option2 = value2
                }
        }
        
        user_name = ...
]]--

mesecons_autotools.set_pos = function(user,nr,pos)        
        if mesecons_autotools.users[user] == nil then
                mesecons_autotools.users[user] = {}
        end
        if mesecons_autotools.users[user].pos == nil then
                mesecons_autotools.users[user].pos = {}
        end
        if pos == nil then 
                mesecons_autotools.users[user].pos[nr] = nil
        else
                local p = vector.new(pos)
                mesecons_autotools.users[user].pos[nr] = p
        end
end

mesecons_autotools.get_pos = function(user,nr)
        if mesecons_autotools.users[user] == nil then
                return nil
        end
        if mesecons_autotools.users[user].pos == nil then
                return nil
        end
        if mesecons_autotools.users[user].pos[nr] == nil then
                return nil
        else
                return vector.new(mesecons_autotools.users[user].pos[nr])
        end
        

end

mesecons_autotools.get_stack_counter = function(user)
        if mesecons_autotools.users[user] == nil then
                mesecons_autotools.users[user] = {}
        end
        
        if mesecons_autotools.users[user].stack_counter == nil then 
                mesecons_autotools.users[user].stack_counter = 0
        end
        
        return mesecons_autotools.users[user].stack_counter 
end

mesecons_autotools.inc_stack_counter = function(user)
        -- get value and create structure if needed
        local count = mesecons_autotools.get_stack_counter(user)
        mesecons_autotools.users[user].stack_counter   = count   + 1        
end

mesecons_autotools.dec_stack_counter = function(user)
        -- get value and create structure if needed
        local count = mesecons_autotools.get_stack_counter(user)
        if count == 0 then return end
        mesecons_autotools.users[user].stack_counter   = count   - 1        
end

mesecons_autotools.zero_stack_counter = function(user)
        -- get value and create structure if needed
        local count = mesecons_autotools.get_stack_counter(user)
        mesecons_autotools.users[user].stack_counter   = 0
end

mesecons_autotools.zero_stack_direction = function(user)
        if mesecons_autotools.users[user] == nil then
                mesecons_autotools.users[user] = {}
        end
        mesecons_autotools.users[user].stack_direction = { x = 0, y = 0, z =0 }
end

mesecons_autotools.set_stack_direction = function(user,direction)
        -- get rid of nils
        mesecons_autotools.zero_stack_direction(user)
        mesecons_autotools.users[user].stack_direction = direction
end

mesecons_autotools.get_stack_direction = function(user)
        if mesecons_autotools.users[user] == nil then
                mesecons_autotools.users[user] = {}
        end
        if mesecons_autotools.users[user].stack_direction == nil then
                mesecons_autotools.users[user].stack_direction = { x = 0, y = 0, z =0 }
        end
        return mesecons_autotools.users[user].stack_direction
end


mesecons_autotools.set_option = function(user,field,value)
        if mesecons_autotools.users[user] == nil then
                mesecons_autotools.users[user] = {}
        end
        if mesecons_autotools.users[user].options == nil then
                mesecons_autotools.users[user].options = {}
        end
        mesecons_autotools.users[user].options[field] = value
end

mesecons_autotools.get_option = function(user,field)
        if mesecons_autotools.users[user] == nil then 
                return nil
        end
        if mesecons_autotools.users[user].options == nil then
                return nil
        end
        return mesecons_autotools.users[user].options[field]
end

mesecons_autotools.is_full_selection = function(user)
        if  mesecons_autotools.get_pos(user,1) == nil then return false end
        if  mesecons_autotools.get_pos(user,2) == nil then return false end
        return true
end


-- Actions/Callbacks ('user' clicked 'button' on 'pos' using 'tool')

-- button = "left" | "right"
-- pos = { x = number, y = number, z = number }
-- tool = "black" | "red" | ...
-- type = "air" | "block" 
        
mesecons_autotools.execute_action = function(tool,button,type,user,pos,rad,under)
--        if user == nil then return end
--        if pos == nil then return end
        if tool == nil then return end
        if button == nil then return end
        if type == nil then return end
        if rad == nil then return end
        -- under == nil can be nil
        
        if mesecons_autotools.actions[tool] == nil then return end
        if mesecons_autotools.actions[tool][button] == nil then return end
        if mesecons_autotools.actions[tool][button][type] == nil then return end
        
        
        mesecons_autotools.actions[tool][button][type](user,pos,rad,under)
        
end



mesecons_autotools.register_action = function(tool,button,type,action)
        if mesecons_autotools.actions[tool] == nil then
                mesecons_autotools.actions[tool] = {}
        end
        if mesecons_autotools.actions[tool][button] == nil then
                mesecons_autotools.actions[tool][button] = {}
        end
        if mesecons_autotools.actions[tool][button][type] == nil then
                mesecons_autotools.actions[tool][button][type] = {}
        end
        mesecons_autotools.actions[tool][button][type] = action
end


function is_in_list(list,value)
        
        for _,v in ipairs(list) do
                if v == value then return true end
                        
        end
        return false
        
end


 function ref_place(pos,node)
                        if minetest.get_item_group(node.name, "mesecon_needs_receiver") == 1 then
                                mesecon.receiver_place(pos)
                        end
                end

 function ref_remove(pos,node)
                        if minetest.get_item_group(node.name, "mesecon_needs_receiver") == 1 then
                                mesecon.receiver_remove(pos)
                        end
                end
                



mesecons_autotools.set_node = function(pos,node,why)
        
        if why == nil then 
                minetest.set_node(pos,node)
        else

                if is_in_list({"start_node","place+refresh"},why) then
                        local n = minetest.get_node(pos)
                        mesecon.on_dignode(pos,n)
                        ref_remove(pos,n)


                        minetest.set_node(pos,node)
                        mesecon.on_placenode(pos,node)
                        ref_place(pos,node)
                end
                
                
                if is_in_list({"start_node","middle_node"},why) then
                        minetest.set_node(pos,node)
                        mesecon.on_placenode(pos,node)
                        ref_place(pos,node)
                end
                
                
                
                        
                
                if is_in_list({"delete"},why) then
                        local n = minetest.get_node(pos)
                        mesecon.on_dignode(pos,n)
                        ref_remove(pos,n)
                        
                        minetest.set_node(pos,node)
                        mesecon.on_placenode(pos,node)
                        ref_place(pos,node)
                        
                end
                
                
                if is_in_list({"delete_crossover","delete_end"},why) then                        --
                        local n = minetest.get_node(pos)
                        mesecon.on_dignode(pos,n)
                        ref_remove(pos,n)
                        
                        minetest.set_node(pos,node)
                        mesecon.on_placenode(pos,node)
                        ref_place(pos,node)
                        
                        
                        
                end
                
                if is_in_list({"paste_circuit"},why) then 
                        minetest.set_node(pos,node)
                end
                
                if is_in_list({"add_wire"},why) then 
                        minetest.set_node(pos,node)
                end
        
                if is_in_list({"red"},why) then 
                        local n = minetest.get_node(pos)
                        mesecon.on_dignode(pos,n)
                        ref_remove(pos,n)
                        
                        minetest.set_node(pos,node)
                        mesecon.on_placenode(pos,node)
                        ref_place(pos,node)

                end
                
                if is_in_list({"put_tail_wires"},why) then 
                        minetest.set_node(pos,node)
                end

                if is_in_list({"copy"},why) then 
                        minetest.set_node(pos,node)
                end
                
                if is_in_list({"paste_from_buffor"},why) then 
                        minetest.set_node(pos,node)
                end                

                
        end
        
end

  
-- Register Tools

dofile(minetest.get_modpath("mesecons_autotools").."/tools.lua");


-- Register Rendering 

dofile(minetest.get_modpath("mesecons_autotools").."/render.lua");

-- Regiser Circuit

dofile(minetest.get_modpath("mesecons_autotools").."/book/circuit.lua");
--dofile(minetest.get_modpath("mesecons_autotools").."/book/library.lua");
dofile(minetest.get_modpath("mesecons_autotools").."/book/file.lua");

-- Register FSM generator
dofile(minetest.get_modpath("mesecons_autotools").."/fsm/fsm.lua");

-- Register Formula generator
--dofile(minetest.get_modpath("mesecons_autotools").."/formula/formula.lua");


-- Register chatcommands

dofile(minetest.get_modpath("mesecons_autotools").."/commands/all_commands.lua");

