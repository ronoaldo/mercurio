

function has_wire_sticking_out(pos,direction)
    local pins = get_pins_from_pos(pos,"any")
    local dir_pin = dir_to_inx(direction)
    
    if( pins[dir_pin] == 1 ) then 
	return true 
    else 
	return false 
    end
end


function get_shifts(p00,move_direction, look_direction,sel)
    local curr = p00
    local shift = 0
    local shifts = {}

    while ( is_in_selection(sel,curr) ) do 
	if( has_wire_sticking_out(curr,look_direction) ) then
	    table.insert(shifts,shift)
	end
	shift = shift + 1
	curr = vector.add(curr,move_direction)
    end
    return shifts
end


function hight_of_selection(sel)
    local pos1 = sel.pos1 
    local pos2 = sel.pos2 
    return math.abs(pos1.y-pos2.y)+1
end

function replace(sel,direction,new_node)
    local p00 = get_corner00(sel,direction)
    local v_move = direction
    local h_move = rotate_direction_right(direction)
    local v_look = rotate_direction_left(direction)
    local h_look = rotate_direction_right(h_move)

    local usize = hight_of_selection(sel)
    local u_move = { x=0,y=1,z=0}

    

for k=1,usize do
    
    local hshifts = get_shifts(p00,h_move,h_look,sel)
    local vshifts = get_shifts(p00,v_move,v_look,sel)

    local hsize = #hshifts
    local vsize = #vshifts
    local m = math.min(hsize,vsize)

    for i=1,m do
	local hs = vector.multiply(h_move,hshifts[i])
	local vs = vector.multiply(v_move,vshifts[i])
	local hvs = vector.add(hs,vs)
	local pos = vector.add(p00,hvs)
	
	--local node = minetest.get_node(pos)
	--print("debug.node="..dump(node))
	--minetest.set_node(pos,new_node)
	
	-- remove metadata TODO
	mesecons_autotools.set_node(pos,new_node,"place+refresh")
    end

    p00 = vector.add(p00,u_move)
end

end



function unconnect(sel,direction)
    local nover = "mesecons_extrawires:crossover_off"

    replace(sel,direction,{name=nover})
    
end

function connect(sel,direction)
    local ncross = "mesecons_morewires:xjunction_off"
    replace(sel,direction,{name=ncross})
end





mesecons_autotools.register_action("grey","left","air", function(user,pos,rad) 
    local pos1 = mesecons_autotools.get_pos(user,1)
    local pos2 = mesecons_autotools.get_pos(user,2)

    local direction = radians_to_direction_looking_forward(rad)

    if pos1 == nil then return end
    if pos2 == nil then return end

    local sel = {pos1=pos1, pos2=pos2}

    unconnect(sel,direction)        
end)
mesecons_autotools.register_action("grey","left","block", function(user,pos,rad) 
    local pos1 = mesecons_autotools.get_pos(user,1)
    local pos2 = mesecons_autotools.get_pos(user,2)

    local direction = radians_to_direction_looking_forward(rad)

    if pos1 == nil then return end
    if pos2 == nil then return end

    local sel = {pos1=pos1, pos2=pos2}

    unconnect(sel,direction)        

end)

mesecons_autotools.register_action("grey","right","block", function(user,pos,rad) 
    local pos1 = mesecons_autotools.get_pos(user,1)
    local pos2 = mesecons_autotools.get_pos(user,2)

    local direction = radians_to_direction_looking_forward(rad)

    if pos1 == nil then return end
    if pos2 == nil then return end

    local sel = {pos1=pos1, pos2=pos2}

    connect(sel,direction)        

        
end)

mesecons_autotools.register_action("grey","right","air", function(user,pos,rad) 
    local pos1 = mesecons_autotools.get_pos(user,1)
    local pos2 = mesecons_autotools.get_pos(user,2)

    local direction = radians_to_direction_looking_forward(rad)

    if pos1 == nil then return end
    if pos2 == nil then return end

    local sel = {pos1=pos1, pos2=pos2}

    connect(sel,direction)        
                       
end)

        
     
     