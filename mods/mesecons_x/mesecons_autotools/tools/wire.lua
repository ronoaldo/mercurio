

function get_node_from_pins(pins)
        local t = "mesecons_extrawires:tjunction_off"
        local c = "mesecons_extrawires:corner_off"
        local w = "mesecons_insulated:insulated_off"
        local a = "air"
        local x = "mesecons_morewires:xjunction_off"
        
        -- {left,up,right,down node_name, rotation} 
        local list = {
                -- empty
                {0,0,0,0,a,0},
                
                -- wire
                {1,0,1,0,w,0},
                {0,1,0,1,w,1},
                
                -- corner
                {1,0,0,1,c,0},
                {1,1,0,0,c,1},
                {0,1,1,0,c,2},
                {0,0,1,1,c,3},
                
                -- tjunction
                {1,0,1,1,t,0},
                {1,1,0,1,t,1},
                {1,1,1,0,t,2},
                {0,1,1,1,t,3},
                
                -- xjunction
                {1,1,1,1,x,0},
                
                -- starting wire
                {1,0,0,0,w,0},
                {0,1,0,0,w,1},
                {0,0,1,0,w,0},
                {0,0,0,1,w,1},
        }
        
        local node_name = "air"
        local rotate = 0
        for _,v in ipairs(list) do
                if      (pins[1] == v[1]) and
                        (pins[2] == v[2]) and
                        (pins[3] == v[3]) and
                        (pins[4] == v[4]) then
                                
                        node_name = v[5]
                        rotate = v[6]
                        
                        end
                        
        end
        
        return { name = node_name, param2 = rotate }
        
        
end

function get_pins_from_pos(pos,type)
        local node = minetest.get_node(pos)
        
        local rs = {}
        if type == "input" then
                rs = mesecon.get_any_inputrules(node)
        elseif type == "output" then
                rs = mesecon.get_any_outputrules(node)
        else
                rs = mesecon.get_any_rules(node)
        end
        if rs == nil then
                rs = {}
        else
                rs = mesecon.flattenrules (rs)
        end

        
        -- Filter only y=0
        local list = {}
        for _,v in pairs(rs) do
                if v.y == 0 then
                        if v.x ~= 0 and v.z == 0 then
                                table.insert(list,v)
                        end
                        if v.z ~= 0 and v.x == 0 then
                                table.insert(list,v)
                        end
                        
                end
        end
        
        -- constructiong pin structure
        
        local pins = {0,0,0,0}
        for _,v in pairs(list) do
                if v.x == 1 then pins[3] = 1 end
                if v.x == -1 then pins[1] = 1 end
                if v.z == 1 then pins[2] = 1 end
                if v.z == -1 then pins[4] = 1 end
        end
        return pins
end



function dir_to_inx(d)
        if d.x == 1 then return 3 end
        if d.x == -1 then  return 1 end
        if d.z == 1 then return 2 end
        if d.z == -1 then  return 4 end
        return 1
end

function get_pin_from_direction(direction)
        return dir_to_inx(direction)
end



local function neighbours_pins(pos)
        local npins = {0,0,0,0}
        for _,ix in ipairs({1,-1}) do
                
                local shift = { x=ix,y=0,z=0 }
                local neigh = vector.add(pos,shift)
                
                local pins = get_pins_from_pos(neigh)
                npins[ dir_to_inx( shift) ] = pins [ dir_to_inx( vector.multiply(shift,-1) ) ] 
        end
        for _,iz in ipairs({1,-1}) do
                
                local shift = { x=0,y=0,z=iz }
                local neigh = vector.add(pos,shift)
                
                local pins = get_pins_from_pos(neigh)
                npins[ dir_to_inx( shift) ] = pins [ dir_to_inx( vector.multiply(shift,-1) ) ] 
        end        
        return npins
end


local function pins_and(pins1,pins2)
        local pout = {}
        for i=1,4,1 do
                pout[i] = pins1[i] * pins2[i]
        end
        return pout
        
end


local function start_node(pos,direction)
        
        local node = minetest.get_node(pos)
        local name = node.name
        
        -- Only wires changed
        local list = {
                "mesecons_insulated:insulated_off","mesecons_insulated:insulated_on",
                "mesecons_extrawires:corner_off","mesecons_extrawires:corner_on",
                "mesecons_extrawires:tjunction_off", "mesecons_extrawires:tjunction_on",
                "air"
                }
        
        if not is_in_list(list,name) then return end
        
        
        local npins = neighbours_pins(pos)
        local mypins = get_pins_from_pos(pos)
        local compins = pins_and(npins,mypins)
        
       -- adding wire
        
        if direction.x == 1 then                
                compins[3] = 1
        end
        if direction.x == -1 then
                compins[1] = 1
        end
        
        if direction.z == 1 then
                compins[2] = 1
        end
        if direction.z == -1 then
                compins[4] = 1
        end        
        
        --merge_wire(pos,direction)
        local new_node = get_node_from_pins(compins)
        
        --minetest.set_node(pos,new_node)        
        mesecons_autotools.set_node(pos,new_node,"start_node")
end

local function end_node(pos,direction)
        --merge_wire(pos, vector.multiply(direction, -1))
        start_node(pos, vector.multiply(direction,-1))
end


local function middle_node(pos, direction)
        local node = minetest.get_node(pos)
        local name = node.name
        local param2 = node.param2
        
        --minetest.set_node(pos,{name = "default:dirt"})
        --if true then return end

        if name ~= "mesecons_insulated:insulated_off" and 
                name ~= "mesecons_insulated:insulated_on" and
                name ~= "air" then
                        return
                end

        -- do crossing
        if name == "air" then 
                local prm2 = 0
                if direction.z ~= 0 then
                        prm2 = 1
                end
                if direction.x ~= 0 then
                        prm2 = 0
                end
                --minetest.set_node(pos,                         { name ="mesecons_insulated:insulated_off", param2= 1 } )
                mesecons_autotools.set_node(pos,
                        {name ="mesecons_insulated:insulated_off", param2= prm2 },
                        "middle_node")

        else
                -- if nothing to do
                if (direction.x ~= 0  ) and 
                        ( param2 == 0 or param2 == 2 ) then 
                                return 
                        end
                if (direction.z ~= 0 ) and 
                        (param2 == 1 or param2 == 3 ) then
                                return 
                        end

                --minetest.set_node(pos,{ name ="mesecons_extrawires:crossover_off" } )
                mesecons_autotools.set_node(pos,
                        { name ="mesecons_extrawires:crossover_off" },
                        "middle_node")
                        
        end
end


function create_straight_wire_n(pos,direction,size)
        local current = pos
        
        -- first 
        start_node(current,direction)
        current = vector.add(current,direction)
        
        -- middle
        for i = 2, size-1, 1 do
                middle_node(current,direction)
                current = vector.add(current,direction)
                
        end
        
        -- last
        end_node(current,direction)
end

local function distance_taxi_metric(pos1,pos2)
        local x1 = pos1.x
        local x2 = pos2.x
        
        local dx = math.abs(x2-x1)
        
        local z1 = pos1.z
        local z2 = pos2.z
        
        local dz = math.abs(z2-z1) 
        
        return dz+dx+1
end


function create_straight_wire(pos1,pos2)
        
        -- Check if straight line
        if pos1.y ~= pos2.y then return end
        if (pos1.x ~= pos2.x ) and (pos1.z ~= pos2.z) then return end
        
   
        
        -- Compute direction
        local direction = { x =0,y=0,z=0}
        if pos1.x == pos2.x then
                if pos1.z < pos2.z then
                        direction.z = 1
                else
                        direction.z = -1
                end
        end
        if pos1.z == pos2.z then
                if pos1.x < pos2.x then
                        direction.x = 1
                else
                        direction.x = -1
                end
        end
        
   
        -- Compute size   
        local size = distance_taxi_metric(pos1,pos2)
        
        
        create_straight_wire_n(pos1,direction,size)
        return true
end

function hop_pos(pos,pin)
        local new_pos = { x = pos.x, y = pos.y, z = pos.z }
        
        if pin == 1 then
                new_pos.x = pos.x - 1
        end
        if pin == 2 then
                new_pos.z = pos.z + 1
        end
        if pin == 3 then
                new_pos.x = pos.x + 1
        end
        if pin == 4 then
                new_pos.z = pos.z -1 
        end
        
        return new_pos
end

function flip_pin(pin)
        if pin == 1 then return 3 end
        if pin == 2 then return 4 end
        if pin == 3 then return 1 end
        if pin == 4 then return 2 end
end

-- TODO: refactor
function hop_pin(pin)
        if pin == 1 then return 3 end
        if pin == 2 then return 4 end
        if pin == 3 then return 1 end
        if pin == 4 then return 2 end
end



local function delete(p,pin)
        local node = minetest.get_node(p)
        local name = node.name
        
        if name == "mesecons_insulated:insulated_off" or 
                name == "mesecons_insulated:insulated_on" or 
                name == "mesecons_extrawires:corner_off" or 
                name == "mesecons_extrawires:corner_on" 
                then
                        
                -- continue deleting
                local node_pins = get_pins_from_pos(p)
                
                -- not connected to anything
                if node_pins[pin] == 0 then return end
                
                node_pins[pin] = 0
                for i=1,4,1 do 
                        if node_pins[i] == 1 then
                                --minetest.set_node(p,{name="air"})
                                mesecons_autotools.set_node(p,{name="air"},"delete")
                                delete(hop_pos(p,i),hop_pin(i))
                        end
                end
                
                
                
        elseif name == "mesecons_extrawires:crossover_off" or
                name == "mesecons_extrawires:crossover_on" or
                name == "mesecons_extrawires:crossover_10" or
                name == "mesecons_extrawires:crossover_01" then
                        
                -- continue deleting
                
                local node_pins = get_pins_from_pos(p)
                node_pins[pin] = 0
                node_pins[hop_pin(pin)] = 0
                
                local new_node = get_node_from_pins(node_pins)
                -- minetest.set_node(p,new_node)
                mesecons_autotools.set_node(p,new_node,"delete_crossover")
                delete(hop_pos(p,hop_pin(pin)),pin)
                
                
                
        elseif name == "mesecons_extrawires:tjunction_off" or 
                name == "mesecons_extrawires:tjunction_on" or
                name == "mesecons_morewires:xjunction_off" or
                name == "mesecons_morewires:xjunction_on" then
                        
                -- end of wire
                
                local node_pins = get_pins_from_pos(p)
                
                -- not connected to anything
                if node_pins[pin] == 0 then return end
                
                node_pins[pin] = 0
                local new_node = get_node_from_pins(node_pins)
                --minetest.set_node(p,new_node)
                mesecons_autotools.set_node(p,new_node,"delete_end")

                
                
        else
                -- do nothing (other blocks)
        end
end


function delete_node(pos)
       local node = minetest.get_node(pos)
       
       local pins = get_pins_from_pos(pos)
       
       --minetest.set_node(pos,{name="air"})
       mesecons_autotools.set_node(pos,{name="air"},"delete")
       
       for i=1,4,1 do
               if pins[i] == 1 then 
                       delete(hop_pos(pos,i),hop_pin(i))
               end
       end
       
       
end







