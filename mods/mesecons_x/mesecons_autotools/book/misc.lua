
local n01 = "mesecons_extrawires:crossover_01"
local n10 = "mesecons_extrawires:crossover_10"

-- axuliary function 
function  switch (name) 
  if( name == n01 ) then 
    return n10
  else
    return n01
  end
end

function rotate_node_to_direction(node,direction)
  local add = 0 
  if direction.x == 1 then add = 3 end
  if direction.x == -1 then add = 1 end
  if direction.z == 1 then add = 0 end
  if direction.z == -1 then add = 2 end

  local param2 = node.param2 

  param2 = (param2+add)% 4

  -- special treatement for crossover wire
  if( node.name == n01 or node.name == n10 ) then 
    if( add % 2 == 0 ) then 
      return { name = node.name, param2=param2}
    else
      return { name = switch(node.name), param2=param2}
    end
  end


  return { name = node.name , param2 = param2 } 
end

local function direction_to_number(direction)
  if( direction.z == 1 ) then
    return 1
  elseif( direction.x == 1 ) then
    return 2
  elseif(direction.z == -1 )then
    return 3
  else
    return 4
  end

end



function rotate_node(node, saved_direction,direction)       
  if node == nil then return nil end
  local values = 
  {
    {0,1,2,3},
    {3,0,1,2},
    {2,3,0,1},
    {1,2,3,0}
  }

  local rotate = 
  values[direction_to_number(saved_direction)][direction_to_number(direction)]

  local new_node = {}
  new_node.name = node.name
  new_node.param2 = (node.param2+rotate)%4

  -- an exception, special treatement of crossover wire 
  if( node.name == n01 or node.name == n10 ) then

    if( rotate % 2 == 0 ) then
      new_node =  node
    else 
      new_node =  {name = switch(node.name), param2=node.param2}
    end
  end

  return new_node
end
