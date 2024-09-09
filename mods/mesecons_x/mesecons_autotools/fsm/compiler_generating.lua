

------------------------------------------------------------------------
-- generating fsm functions
------------------------------------------------------------------------
function get_list(list)
  if list == nil then 
    return {}
  else
    return list
  end
end

--[[
function fsm_generate_trans(db)
  -- from ins -> to outs
  local results = {}
  local states = get_all_reachable_states(db)
  for state,_ in pairs(states) do
    if( db.trans[state] == nilv) then
      table.insert(results, { from = state, to = state, ins = {} , outs = {}  })
    else
      for _,ifthens in pairs(db.trans[state]) do
        local pins_in = ifthens.pins
        local next_state = ifthens.state      
        local pins_out = db.outputs[next_state]
        if pins_out == nil then pins_out =  {} end
        table.insert(results, { from = state, to = next_state, ins = pins_in, outs = pins_out } )
      end    
    end
  end
 return results 
end

]]--

function value_inc(v)
    local len = #v
    local carry = true
    local new = ""
    
    for i=len,1,-1 do
      local ch = string.sub(v,i,i)
      if carry == false then
        new =  ch .. new
      else
          if ch == "0" then
            new = "1" .. new
            carry = false
          else
            new = "0" .. new
            carry = true
          end
      end
    end
    return new
end

function next_free_value(len,db)
  local nv = string.rep("0",len)
  
  vals = {}
  -- get only vlaues
  for k,v in pairs(db) do
    vals[v] = true
  end
  
  for i=1,math.pow(2,len) do
    if vals[nv] == nil then
      return nv
    end
    nv = value_inc(nv)
  end
  
  -- should never get here
  return nil
end

function get_not_used_states(db)
  local reachables = db.reachables
  local state_values = db.state_values
  local not_used_states = {}
  
   -- checking if some states are not used
  for k,v in pairs(state_values) do
   if reachables[k] == nil then
     table.insert(not_used_states,k)
   end
  end
  
  if #not_used_states == 0 then 
    return {}
  end
  
  local list = {}
  for _,v in pairs(not_used_states) do
    table.insert(list, "state '" .. v .. "' is not used, but declared " .. v .. 
      " := " .. state_values[v])
  end
  
  return nil,list    
end


function fill_states_values(db)
  local states_values = db.state_values
  local states = db.reachables
  local filled = {}
  
  -- filling existing values
  for k,_ in pairs(states) do
    filled[k] = states_values[k]
  end
  
  local len = db.state_bitsize
  local zerostate = string.rep("0",len)
  
   -- checkint if init already has value, and if it is 0000
  if filled[init] ~= nil and filled[init] ~= zerostate then 
    return nil, "init state " .. filled[init] .. " has value " .. 
      filled[init] .. ", only value 0 is allovwd for init state"
  end
  
  -- checking if state 0000 is used by other state
  for k,v in pairs(filled) do
    if v == zerostate then 
      if k ~= db.init then
        return nil, "value " .. zerostate .. 
            " is reserved for init state, but already used by " .. 
            k .. " := " .. v
      end
    end
  end
  
  -- adding default init state as 0000 
  local init = db.init
  if filled[init] ~= nil then
    if filled[init] ~= zerostate then
      return nil,"init state must be " .. zerostate .. ", but is " .. 
        init .. " := " .. filled[init]
    end
  end
  
  if filled[init] == nil then
    filled[init] = zerostate
  end
  
  -- adding rest
  
  for k,v in pairs(states) do
    if filled[k] == nil then
        filled[k] = next_free_value(len,filled)          
    end
  end
  return filled
end

function only_reachable_state_values(db)
  local reach = db.reachables
  local values = db.state_values
  
  local new = {}

  for k,_ in pairs(values) do
    if reach[k] ~= nil then
      new[k] = values[k]
    end
  end
  return new
end


function fsm_get_all_used_inputs(db)
  local pins = {}
  
  for _,v in pairs(db.trans) do
    local ins = v.ins
    for _,pin in pairs(ins) do
      pins[drop_negation(pin)] = true
    end
  end
  return pins
end

-- appends list 2 to lits 1
-- probably there is a function for that
-- couldn't bother to find it
function append(list1,list2)
    if list2 == nil then 
      return list1
    end
    if list1 == nil then 
      return nil
    end
    
    for _,v in pairs(list2) do
      table.insert(list1,v)
    end
    return list1
end

function fsm_get_all_used_outputs(reachable_trans,db)
  local list = {}
  
  -- get all pins
  for _,v in pairs(reachable_trans) do
      local ps = db.outputs[v.to]
      apend(list,ps)
  end
  
  -- remove negations
  local list2 = {}
  for _,v in pairs(list) do
    table.insert(list2, drop_negation(v))
  end
  return remove_duplicates(list2)
end

function check_inputs(db)
  
end

------------------------------------------------------------------------
-- generating error messages
------------------------------------------------------------------------
function error_unknows(unknows)
  local msg = ""
  for _,v in pairs(unknows) do
    msg = msg .. "line: .. "  .. v.nr .. " " .. v.line .. "\n"
  end
  return msg
end
