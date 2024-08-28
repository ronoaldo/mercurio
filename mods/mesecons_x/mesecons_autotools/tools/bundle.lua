
function is_in_selection(sel,p)        
        local pos = {}
        pos[1] = sel.pos1
        pos[2] = sel.pos2
        
        if pos[1] == nil then return false end
        if pos[2] == nil then return false end
        
        local xmax = math.max(pos[1].x, pos[2].x)
        local xmin = math.min(pos[1].x, pos[2].x)
        
        local ymax = math.max(pos[1].y, pos[2].y)
        local ymin = math.min(pos[1].y, pos[2].y)
        
        local zmax = math.max(pos[1].z, pos[2].z)
        local zmin = math.min(pos[1].z, pos[2].z)
        
        local x = p.x
        local y = p.y
        local z = p.z
        
        if      (xmin<=p.x) and (p.x<=xmax) and
                (ymin<=p.y) and (p.y<=ymax) and
                (zmin<=p.z) and (p.z<=zmax) then
                        return true
                end
        return false
end

function is_in_layer(sel,p)
        local pos = {}
        pos[1] = sel.pos1
        pos[2] = sel.pos2
        
        local ymax = math.max(pos[1].y, pos[2].y)
        local ymin = math.min(pos[1].y, pos[2].y)
        
        if (p.y > ymax) or (p.y< ymin) then return false end
        return true
        
end

function is_in_tube(sel,p)
        if is_in_selection(sel,p) then return false end
        if not is_in_layer(sel,p) then return false end
        local pos = {}
        pos[1] = sel.pos1
        pos[2] = sel.pos2
        
        local xmax = math.max(pos[1].x, pos[2].x)
        local xmin = math.min(pos[1].x, pos[2].x)
        
        local ymax = math.max(pos[1].y, pos[2].y)
        local ymin = math.min(pos[1].y, pos[2].y)
        
        local zmax = math.max(pos[1].z, pos[2].z)
        local zmin = math.min(pos[1].z, pos[2].z)
         
        local x = p.x
        local y = p.y
        local z = p.z     
        
        if (xmin <=x ) and (x<=xmax) then return true end
        if (zmin <=z) and (z<=zmax) then return true end
        return false
        
end

function is_in_wings(sel,p)
        if is_in_selection(sel,p) then return false end
        if not is_in_layer(sel,p) then return false end
        if is_in_tube(sel,p) then return false end
        return true
end



function front_wall_tube(sel,p)
        local pos = {}
        pos[1] = sel.pos1
        pos[2] = sel.pos2
        
        local xmax = math.max(pos[1].x, pos[2].x)
        local xmin = math.min(pos[1].x, pos[2].x)
        
        local ymax = math.max(pos[1].y, pos[2].y)
        local ymin = math.min(pos[1].y, pos[2].y)
        
        local zmax = math.max(pos[1].z, pos[2].z)
        local zmin = math.min(pos[1].z, pos[2].z)         
        
        local x = p.x
        local y = p.y
        local z = p.z         
        
        local new_sel = {}
        local new_pos1 = vector.new(pos[1])
        local new_pos2 = vector.new(pos[2])
        local direction = {}
        
        
        if (xmin<=x) and (x<=xmax) then
                if (z > zmax) then
                        direction.x = 0
                        direction.y = 0
                        direction.z = 1
                        
                        new_pos1.z = zmax
                        new_pos2.z = zmax
                else
                        direction.x = 0
                        direction.y = 0
                        direction.z = -1
                        
                        new_pos1.z = zmin
                        new_pos2.z = zmin
                end
        end
        if (zmin<=z) and (z<=zmax) then
                if( x > xmax) then
                        direction.x = 1
                        direction.y = 0
                        direction.z = 0
                        
                        new_pos1.x = xmax
                        new_pos2.x = xmax
                else
                        direction.x = -1
                        direction.y = 0
                        direction.z = 0
                        
                        new_pos1.x = xmin
                        new_pos2.x = xmin
                        
                end
                
        end
        
        
        new_sel.pos1 = new_pos1
        new_sel.pos2 = new_pos2
        
        return new_sel,direction
end

function tunel_direction(sel,pos)
        local wall,dir = front_wall_tube(sel,pos)
        return dir
end

function tunel_front_wall(sel,pos)
        local wall,dir = front_wall_tube(sel,pos)
        return wall
end




function is_dir_vertical(direction)
        if direction.z ~= 0 then return true end
        return false
end

function is_look_vertical(rad)
        local dir = radians_to_direction_looking_forward(rad)
        return is_dir_vertical(dir)
end

--[[
function is_dir_horizontal(direction)
        if direction.x ~= then return true end
        return false
end
]]--

function front_wall_by_direction(sel,direction)
        local pos = {}
        pos[1] = sel.pos1
        pos[2] = sel.pos2
        
        local xmax = math.max(pos[1].x, pos[2].x)
        local xmin = math.min(pos[1].x, pos[2].x)
        
        local ymax = math.max(pos[1].y, pos[2].y)
        local ymin = math.min(pos[1].y, pos[2].y)
        
        local zmax = math.max(pos[1].z, pos[2].z)
        local zmin = math.min(pos[1].z, pos[2].z)         
        
        
        local new_sel = {}
        local new_pos1 = vector.new(pos[1])
        local new_pos2 = vector.new(pos[2])
        
        if direction.x == 1 then
                new_pos1.x = xmax
                new_pos2.x = xmax
        end
        if direction.x == -1 then
                new_pos1.x = xmin
                new_pos2.x = xmin
        end
        if direction.z == 1 then
                new_pos1.z = zmax
                new_pos2.z = zmax
        end
        if direction.z == -1 then
                new_pos1.z = zmin
                new_pos2.z = zmin
        end
        if direction.y == 1 then
                new_pos1.y = ymax
                new_pos2.y = ymax
        end
        if direction.y == -1 then 
                new_pos1.y = ymin
                new_pos2.y = ymin
        end
        
        new_sel.pos1 = new_pos1
        new_sel.pos2 = new_pos2
        
        return new_sel
end
--[[
function get_wing_cords(sel,p)
        local  zero = {x =0,z=0}
        local cord 
        if is_in_selection(sel,p) then return zero end
        if not is_in_layer(sel,p) then return zero end
        
        local pos = {}
        pos[1] = sel.pos1
        pos[2] = sel.pos2
        
        local xmax = math.max(pos[1].x, pos[2].x)
        local xmin = math.min(pos[1].x, pos[2].x)
        
        local ymax = math.max(pos[1].y, pos[2].y)
        local ymin = math.min(pos[1].y, pos[2].y)
        
        local zmax = math.max(pos[1].z, pos[2].z)
        local zmin = math.min(pos[1].z, pos[2].z)
         
        local x = p.x
        local y = p.y
        local z = p.z            
        
        if (x>xmax) and (z>zmax) then 
                cord = { x = 1, z = 1}
        end
        if (x<xmin) and (z>zmax) then
                cord = {x = -1 , z = 1}
        end
        if (z<zmin) and (x>xmax) then
                cord = { x = 1 , z = -1 } 
        end
        if (z < zmin) and (x < xmin) then
                cord = { x -1 ,z = -1 }
        end
        
        return cord
end
]]--
--[[
function front_wall_wing(sel,p,rad)
        local cord = get_wing_cords(sel,p)
        
        local wall_dir
        wall_dir.y = 0
        
        if cord.x == 1 and cord.z == 1 then
                if is_look_vertical(rad) then
                        wall_dir = {x=1,z=0}
                else
                        wall_dir = {x=0,z=1}
                end                
        end
        
        if cord.x == -1 and cord.z == 1 then
                if is_look_vertical(rad) then
                        wall_dir = {x=-1,z=0}
                else
                        wall_dir = {x=0,z=1}
                end                
        end
        
        if cord.x == 1 and cord.z == -1 then
                if is_look_vertical(rad) then
                        wall_dir = {x=1,z=0}
                else
                        wall_dir = {x=0,z=-1}
                end                
        end

        if cord.x == -1 and cord.z == -1 then
                if is_look_vertical(rad) then
                        wall_dir = {x=-1,z=0}
                else
                        wall_dir = {x=0,z=-1}
                end                
        end
        
        local wall = front_wall_by_direction(wall_dir)
        
        return wall,wall_dir
end

]]--
function distance_to_selection(sel,p,direction)
        local dist = 0 
        local pos = {}
        pos[1] = sel.pos1
        pos[2] = sel.pos2
        
        if not is_in_layer(sel,p) then return dist end
        
        --local direction = tunel_direction(sel,p)
        
        
        local xmax = math.max(pos[1].x, pos[2].x)
        local xmin = math.min(pos[1].x, pos[2].x)
        
        local ymax = math.max(pos[1].y, pos[2].y)
        local ymin = math.min(pos[1].y, pos[2].y)
        
        local zmax = math.max(pos[1].z, pos[2].z)
        local zmin = math.min(pos[1].z, pos[2].z)      
       
        if direction.x ~= 0 then
                if direction.x == 1 then
                       dist = math.abs(p.x - xmax)
                elseif direction.x == -1 then
                        dist = math.abs(xmin-p.x)
                end
                
        elseif direction.z ~= 0 then
                if direction.z == 1 then
                        dist = math.abs(p.z - zmax)
                elseif direction.z == -1 then
                        dist = math.abs(zmin - p.z)
                end
                
        end
        
        return dist + 1
        
end

--[[
function direction_to_pins(direction)
        local pin = {0,0,0,0}
        if direction.x == -1 then 
                pin[1] = 1
        end
        if direction.x == 1 then 
                pin[3] = 1
        end
        if direction.z == 1 then
                pin[2] = 1
        end
        if direction.z == -1 then
                pin[4] == 1
        end
        return pin
end
]]--
function direction_to_pin(direction)
        if direction.x == -1 then 
                return 1
        end
        if direction.x == 1 then 
                return 3
        end
        if direction.z == 1 then
                return 2
        end
        if direction.z == -1 then
                return 4
        end
end


function pos_to_connect(wall,direction)
        local list = {}
        iterate_selection(wall.pos1,wall.pos2, function(pos)
                        local pins = get_pins_from_pos(pos)
                        local dpin = direction_to_pin(direction)
                        if pins[dpin] == 1 then
                                table.insert(list,pos)
                        end
                end)
        return list
end

function _is_block_type(pos,direction)
        local node = minetest.get_node(pos)
        local name = node.name
        
        if name == "air" then 
                return "buildable"
        end
        
        if      name == "mesecons_insulated:insulated_off" or 
                name == "mesecons_insulated:insulated_on" then 
                
                local param2 = node.param2
                local pin = direction_to_pin(direction)
                
                if (param2==0 or param2==2) and (pin==2 or pin==4) then
                        return "buildable"
                end
                if (param2==1 or param2==3) and (pin==1 or pin==3) then
                        return "buildable"
                end
                return "last"
        end
        
        
        local pos_pins = get_pins_from_pos(pos)
        local dir_pin = flip_pin(direction_to_pin(direction))
        if pos_pins[dir_pin] ==1 then 
                return  "last"
        end
        return "cancel"
end


function is_block_type(pos,direction)
        local res = _is_block_type(pos,direction)
        local node = minetest.get_node(pos)
        local name = node.name
        
        
        return res
end


function is_block_cancel(pos,direction)
        if is_block_type(pos,direction) == "cancel" then
                return true
        else
                return false
        end
end

function is_block_last(pos,direction)
        if is_block_type(pos,direction) == "last" then
                return true
        else
                return false
        end
end

function is_block_buildable(pos,direction)
        if is_block_type(pos,direction) == "buildable" then
                return true
        else
                return false
        end
end



function _can_build_wire(pos,direction,size)
        local current = { x=pos.x , y =pos.y, z=pos.z}
        
        local flag = false
        for i=1,size,1 do
                
                if is_block_cancel(current,direction) then                         
                        return false
                end
                if is_block_last(current,direction) then                        
                        return true
                end
                
                current = vector.add(current,direction)
        end        
        return flag
end

function can_build_wire(pos,direction,size)
        return _can_build_wire(pos,direction,size)
end


function add_wire(pos,direction)
        local node = minetest.get_node(pos)
        local name = node.name
        
        if name == "air" then                
                local pins = get_pins_from_pos(pos)
                local dpin = direction_to_pin(direction)
                
                pins[dpin] = 1
                pins[flip_pin(dpin)] = 1
                
                local nnode = get_node_from_pins(pins)
                
                --minetest.set_node(pos,nnode)                
                mesecons_autotools.set_node(pos,nnode,"add_wire")
        else
                local nnode = { name = "mesecons_extrawires:crossover_off" }
                --minetest.set_node(pos, nnode)
                mesecons_autotools.set_node(pos,nnode,"add_wire")
                        
        end
        

        
end
--[[ not used
function add_last_wire(pos,direction)
        local pins = get_pins_from_pos(pos)
        local dpin = direction_to_pin(direction)
        
        pins[flip_pin(dpin)] = 1
        
        local node = get_node_from_pins(pins)
        
        minetest.set_node(pos,node)
        
end
]]--

function build_wire_inside(pos,direction,size)
        local current = { x=pos.x , y =pos.y, z=pos.z}   
        
        if not can_build_wire(pos,direction,size) then return end
        
        for i=1,size,1 do
                if is_block_cancel(current,direction) then 
                        return
                elseif is_block_buildable(current,direction) then
                        add_wire(current,direction)
                elseif is_block_last(current,direction) then                        
                        break
                end
                current = vector.add(current,direction)
        end        
end



function create_wires_inside_selection(sel,wall,direction)
        local size = size_by_direction(sel.pos1,sel.pos2,direction)
        local back_direction = vector.multiply(direction,-1)
        
        
        iterate_selection(wall.pos1,wall.pos2,function(pos)
                        build_wire_inside(pos,back_direction,size)
                end)
    
end


function create_bundle_straight_wire(sel,pos)
        local pos1 = sel.pos1
        local pos2 = sel.pos2 
        
        if not is_in_tube(sel,pos) then return false end
        
        local wall,direction = front_wall_tube(sel,pos)
        
        local distance = distance_to_selection(sel,pos,direction)

        if      is_one_block(pos1,pos2) or 
                is_empty_selection(pos1,pos2)  or
                is_tower_selection(pos1,pos2) then
                        
                iterate_selection(sel.pos1, sel.pos2, function(pos) 
                       create_straight_wire_n(pos,direction,distance)
                end)
        else
                
                create_wires_inside_selection(sel,wall,direction)
                
                
                local wire_list = pos_to_connect(wall,direction)                
                iterate_list(wire_list,function(pos)                                
                                create_straight_wire_n(pos,direction,distance)
                        end)
                
        end
        return true        
end



function is_flat_selection(sel)
    local p1 = sel.pos1
    local p2 = sel.pos2

    if( p1.x == p2.x and p1.z == p2.z ) then return false end
    if (p1.x == p2.x ) then return true end
    if( p1.z == p2.z ) then return true end
    return false
end

-- direction of selection (according to the shape (=flat edge)
function sel_directions_frontwall(sel)
    local p1 = sel.pos1
    local p2 = sel.pos2

    if( p1.x == p2.x ) then
	return {x=1,y=0,z=0},{x=-1,y=0,z=0}
    end
    if( p1.z == p2.z ) then
	return {x=0,y=0,z=1},{x=0,y=0,z=-1}
    end
    print "Error: sel_direction(sel) not a flat selection (use is_flat_selection(sel) to check!!!"
    return {x=0,y=0,z=0}
end


function normalize(p)
    local x,y,z
    if( p.x > 0 ) then x = 1 end
    if( p.x == 0 ) then x = 0 end
    if( p.x < 0 ) then x = -1 end

    if( p.y > 0 ) then y = 1 end
    if( p.y == 0 ) then y = 0 end
    if( p.y < 0 ) then y = -1 end

    if( p.z > 0 ) then z = 1 end
    if( p.z == 0 ) then z = 0 end
    if( p.z < 0 ) then z = -1 end
    return {x=x,y=y,z=z} 
end
-- vectors directing from p1 to p2
function toward_direction(p1,p2)
    local d1 =  {x=p2.x-p1.x,y=0,z=0 }
    local d2 =   {x=0,y=0,z=p2.z-p1.z}
    return normalize(d1),normalize(d2)
end

-- comparing two points/vectors
function cmp(p1,p2) 
    if (p1.x==p2.x) and (p1.y==p2.y) and (p1.z==p2.z) then return true else return false end
end

-- {p1,p2} cup {p3,p4} // only one can be common, so I dont check other possibilietes
function cup(p1,p2,p3,p4)
    if cmp(p1,p3) then return p1 end
    if cmp(p1,p4) then return p1 end
    if cmp(p2,p3) then return p2 end
    if cmp(p2,p4) then return p2 end
--print("DEGUG.CRITICAL ERROR: cup, p1,p2,p3,p4 =" ..dump(p1)..dump(p2)..dump(p3)..dump(p4))
    return nil
end

-- checks if vectors have the same parallerism
function same_line(d1,d2)
    if math.abs(d1.x) == math.abs(d2.x) and math.abs(d1.z) == math.abs(d2.z) then return true end
    return false
end

-- returns direction from selection toward point, and direction from poin towards selection
function compute_directions(sel,pos)
    local s1,s2 
    local sp1,sp2
    
    s1,s2 = sel_directions_frontwall(sel)	
--print("sel,pos="..dump(sel).."," .. dump(pos))
    sp1,sp2 = toward_direction(sel.pos1,pos) -- no matter if sel.pos1 or sel.pos2
--print("toward="..dump(sp1)..","..dump(sp2))
    local sel_direction = cup(s1,s2,sp1,sp2)

    local p1,p2
    p1,p2 = toward_direction(pos,sel.pos1) -- no matter if sel.pos1 or sel.pos2
    local pos_direction 
    if same_line(sel_direction,p1) then 
	pos_direction = p2
    else
	pos_direction = p1
    end
    return sel_direction, pos_direction
end


-- computing point A
function compute_A(sel,sel_dir, pos, pos_dir)
    local s1 = sel.pos1
    local s2 = sel.pos2

    local dist1x = math.abs(pos.x-s1.x)
    local dist2x = math.abs(pos.x-s2.x)
    local dist1z = math.abs(pos.z-s1.z)
    local dist2z = math.abs(pos.z-s2.z)

    local mx = math.min(dist1x,dist2x)
    local mz = math.min(dist1z,dist2z)

    local sihfta
    if pos_dir.x ~= 0 then 
	shifta = vector.multiply(pos_dir,mx)
    else
	shifta = vector.multiply(pos_dir,mz)
    end
    local a = vector.add(shifta,pos)
    return a
end

--[[

function compute_X(sel,sel_dir,pos,pos_dir,A)
    local d = vector.multiply(sel_dir,-1)
    return vector.add(A,d)    
end

]]--
--[[
function selection_len(sel)
    local p1=sel.pos1
    local p2=sel.pos2
    if( p1.x == p2.x ) then return math.abs(p2.z-p1.z)+1 end
    if( p1.z == p2.z ) then return math.abs(p2.x-p1.x)+1 end
    
--    print("CRITICAL ERRROR ERROR ERROR: selection_len(sel): "..dump(sel))
end
]]--
--[[
function compute_D(sel,sel_dir,pos,pos_dir,A)
    local l = selection_len(sel)
    return vector.add(A, vector.multiply(pos_dir,l-1))
end
]]--
--[[
function crossing_point(p1,p1_dir,p2)
    local len
    local cross
    if(p1_dir.x ~= 0 ) then
	len = math.abs(p2.x-p1.x)
    else
	len = math.abs(p2.z-p1.z)
    end
    cross = vector.add(p1,vector.multiply(p1_dir,len))
    return cross
end
]]--

function create_wire_bended(p1,dir1, p2, dir2)
    local len
    if(dir1.x ~= 0 ) then
	len = math.abs(p2.x-p1.x)
    else
	len = math.abs(p2.z-p1.z)
    end
    create_straight_wire_n(p1,dir1,len+1)
    
    local cross = vector.add(p1,vector.multiply(dir1,len))
    if(dir2.x ~= 0 ) then
	len = math.abs(p2.x-p1.x)
    else
	len = math.abs(p2.z-p1.z)
    end
    create_straight_wire_n(cross,dir2,len+1)
end
--[[
function create_bundle_twist_wire(sel,in_dir,_X,_Y,xm, out_dir, _A,am)
    local max_size = 0
--print("debug|sel.in_dir,X,Y,xm,out_dir,A,am=" .. dump(sel) .. dump(in_dir)..dump(X)..dump(Y)..dump(xm)..dump(out_dir)..dump(A).. dump(am))

    local usize = hight_of_selection(sel)
    local X = _X
    local A = _A
    local Y = _Y

    for k=1,usize do
	--move all point up to next layer

        local shifts_in = get_shifts(X,xm,in_dir,sel)
        local ssize = #shifts_in
	max_size = math.max(max_size,ssize)
	
print("shifts="..dump(shifts_in))	
	for i=1,ssize do
	    local start_pos = vector.add(X,vector.multiply(xm,shifts_in[i]))
	    local end_pos = vector.add(A,vector.multiply(am,i-1))
	    create_wire_bended(start_pos,in_dir,end_pos,vector.multiply(out_dir,1))
	end

	local up = {x=0,y=1,z=0}
	X = vector.add(X,up)
	Y = vector.add(Y,up)
	A = vector.add(A,up)
	
	
    end        
    return max_size

end
]]--
function compute_S1(sel,sel_dir,pos,pos_dir)
    local s1 = sel.pos1
    local s2 = sel.pos2
    local p = pos

    local sx1 = math.abs(p.x-s1.x)
    local sx2 = math.abs(p.x-s2.x)
    local sz1 = math.abs(p.z-s1.z)
    local sz2 = math.abs(p.z-s2.z)
    
    local mx = math.min(sx1,sx2)
    local mz = math.min(sz1,sz2)

    local A = compute_A(sel,sel_dir, pos,pos_dir)
    local len
    if( sel_dir.x ~= 0 ) then
	len = mx
    else
	len = mz
    end
    local S1 = vector.add(A, vector.multiply( vector.multiply(sel_dir,len)   , -1))
    return S1
	
end

function get_virtual_shifts(pos,move_direction,look_direction,sel)
    local curr = pos
    local shift = 0 
    local shifts = {}
    while( is_in_selection(sel,curr) ) do
	table.insert(shifts,shift)
	shift = shift + 1
	curr = vector.add(curr,move_direction)
    end
    return shifts
end

function create_bundle_bended_wire(user,sel,pos,user_dir)
    local sel_direction, pos_direction
    local pos1 = sel.pos1
    local pos2 = sel.pos2

    if not is_in_wings(sel,pos) then return false end
    if not is_flat_selection(sel) then return false end

    sel_direction,pos_direction = compute_directions(sel,pos)

    local usize = hight_of_selection(sel)
    local S1_original = compute_S1(sel,sel_direction,pos,pos_direction)
    local max_wires = 0
    
    
    if 	is_empty_selection(pos1,pos2) then
	local S1 = S1_original
	for k=1,usize do
	    local shifts = get_virtual_shifts(S1,pos_direction,sel_direction,sel)
	    local ssize = #shifts
	    max_wires = math.max(max_wires,ssize)
	    for i=1,ssize do
		local start_pos = vector.add(S1,vector.multiply(pos_direction,shifts[i]))
	        local end_pos = vector.add(pos, vector.multiply(sel_direction,i-1))
		create_wire_bended(start_pos,sel_direction,end_pos, vector.multiply(pos_direction,-1))
	    end
	    S1 = vector.add(S1,{x=0,y=1,z=0})
	end
    else
	local S1 = S1_original
        for k=1,usize do
    	    local shifts = get_shifts(S1,pos_direction,sel_direction,sel)
    	    local ssize = #shifts
	    max_wires=math.max(max_wires,ssize)
	    for i=1,ssize do
	        local start_pos = vector.add(S1,vector.multiply(pos_direction,shifts[i]))
	        local end_pos = vector.add(pos, vector.multiply(sel_direction,i-1))
	        create_wire_bended(start_pos,sel_direction,end_pos, vector.multiply(pos_direction,-1))
	    end
	    S1 = vector.add(S1,{x=0,y=1,z=0})
        end    
    end

    -- computing selection
    local new_sel = {}  
    new_sel.pos1 = pos
    new_sel.pos2 = vector.add(vector.add(pos, vector.multiply(sel_direction,max_wires-1)),{x=0,y=usize-1,z=0})

    mesecons_autotools.set_pos(user,1,new_sel.pos1)
    mesecons_autotools.set_pos(user,2,new_sel.pos2)
    mesecons_autotools.render(user)

    mesecons_autotools.zero_stack_counter(user)
    mesecons_autotools.zero_stack_direction(user)

    return true
end
