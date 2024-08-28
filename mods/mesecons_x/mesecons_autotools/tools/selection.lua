function iterate_selection(pos1,pos2,action)
        local xmin = math.min(pos1.x,pos2.x)
        local ymin = math.min(pos1.y,pos2.y)
        local zmin = math.min(pos1.z,pos2.z)
        
        local xmax = math.max(pos1.x,pos2.x)
        local ymax = math.max(pos1.y,pos2.y)
        local zmax = math.max(pos1.z,pos2.z)
       
        
        for ix = xmin,xmax,1 do
                for iy = ymin,ymax,1 do
                        for iz = zmin,zmax,1 do
                                action({x=ix,y=iy,z=iz})
                        end
                end
        end
        
end

function iterate_list(list,action)
        for _,v in ipairs(list) do
                action(v)
        end       
end


-- not tested, not used 
function copy_safe(pos1,pos2,shift_vector)
        local buffor = {}
        copy_to_buffor(pos1,pos2,buffor)
        paste_from_buffor(shift_vector,buffor)
end


function copy(pos1,pos2, shift_vector)
        iterate_selection(pos1,pos2, function(pos)
                        local node = minetest.get_node(pos)
			local meta = minetest.get_meta(pos):to_table()

                        local new_pos = vector.add(pos,shift_vector)
                        --minetest.set_node(new_pos, node)
                        --mesecons_autotools.set_node(new_pos, node,"copy")
			minetest.set_node(new_pos,node)
			minetest.get_meta(new_pos):from_table(meta)
			
        end)
end


--[[
function copy_to_buffor(pos1,pos2,buffor)
        iterate_selection(pos1,pos2, function(pos)
                        local node = minetest.get_node(pos)
                        table.insert(buffor, { pos = pos, node = node } )
                end)
        
end

function paste_from_buffor(shift_vector,buffor)
        for _,v in pairs(buffor) do
                local pos = v.pos
                local node = v.node
                
                local new_pos = vector.add(pos,shift_vector)
                
                --minetest.set_node(new_pos,node)
                mesecons_autotools.set_node(new_pos,node,"paste_from_buffor")
        end
        
end
]]--


function copy_to_buffor(pos1,pos2,buffor)

        iterate_selection(pos1,pos2, function(pos)
                        local node = minetest.get_node(pos)
			local meta = minetest.get_meta(pos):to_table()

                        table.insert(buffor, { node = { pos = pos, node = node }, meta = meta} )
                end)
        
end

function paste_from_buffor(shift_vector,buffor)

        for _,v in pairs(buffor) do
                local pos = v.node.pos
                local node = v.node.node
		local meta = v.meta
    
                local new_pos = vector.add(pos,shift_vector)
                
                minetest.set_node(new_pos,node)
		minetest.get_meta(new_pos):from_table(meta)

                --mesecons_autotools.set_node(new_pos,node,"paste_from_buffor")
        end
        
end



function delete(pos1,pos2)
        iterate_selection(pos1,pos2, function(pos) 
                        minetest.set_node(pos,{ name = "air" } )
			minetest.get_meta(pos):from_table({})
                end)
        
end



function shift_selection(user,shift_vector)
        if not mesecons_autotools.is_full_selection(user) then return end
        
        local pos = {}
        pos[1] = mesecons_autotools.get_pos(user,1)
        pos[2] = mesecons_autotools.get_pos(user,2)
        
        
        mesecons_autotools.set_pos(user,1, vector.add(pos[1],shift_vector))
        mesecons_autotools.set_pos(user,2, vector.add(pos[2],shift_vector))
                
        

end

function is_one_block(pos1,pos2)
        if     (pos1.x ~= pos2.x ) then return false end
        if pos1.y ~= pos2.y  then return false end
        if pos1.z ~= pos2.z then return false end
        return true
end

function is_empty_selection(pos1,pos2)
        local list = {}
        iterate_selection(pos1,pos2, function(pos)
                        local node = minetest.get_node(pos)
                        local name = node.name
                        if name ~= "air" then 
                                table.insert(list,1)
                        end
                end)
        for _,v in ipairs(list) do
                if v == 1 then 
                        return false
                end
        end
        return true
        
end

function is_tower_selection(pos1,pos2)
        if pos1.x == pos2.x and pos1.z == pos2.z then return true end
        return false
end


function size_by_direction(pos1,pos2,direction)
        local dx = math.abs(pos1.x - pos2.x) +1
        local dy = math.abs(pos1.y - pos2.y) +1 
        local dz = math.abs(pos1.z - pos2.z) +1
        
        if direction.x ~= 0 then return dx end
        if direction.y ~= 0 then return dy end
        if direction.z ~= 0 then return dz end
                
        return 0
end


