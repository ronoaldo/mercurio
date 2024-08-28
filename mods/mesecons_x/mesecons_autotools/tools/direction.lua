function radians_to_vectors(rad)
    local pi = math.pi
    if (rad>=0) and (rad<=pi/4) or (rad<=2*pi) and (rad>=(3/2+1/4)*pi) then
	return {left = {x=-1,z=0,y=0},right = { x=1, z = 0,y=0 } } 
    elseif (rad >= 1/4*pi) and (rad <= (1/2+1/4)*pi) then
	return { left = {x = 0 ,z=-1,y=0}, right = { x = 0, z = 1 ,y=0} } 	
    elseif (rad >= (1-1/4)*pi ) and (rad <= (3/2-1/4)*pi ) then 
	return { left =  { x = 1, z =0 ,y=0}, right = { x = -1, z = 0 ,y=0} }
    else	
	return { left = { z =1, x = 0 ,y=0} , right = { z = -1 , x = 0,y=0 }} 
    end
end


function radians_to_direction_looking_forward(rad)
        if rad == nil then return {x=1,z=0,y=0} end
        local pi = math.pi
        if (rad>=0) and (rad<=pi/4) or (rad<=2*pi) and (rad>=(3/2+1/4)*pi) then
                return {x=0, z =1 ,y=0}
        elseif (rad >= 1/4*pi) and (rad <= (1/2+1/4)*pi) then
                return {x=-1,z=0,y=0}
        elseif (rad >= (1-1/4)*pi ) and (rad <= (3/2-1/4)*pi ) then 
                return {x=0,z=-1,y=0}
        else	
                return {x=1,z=0,y=0}
        end   
end

