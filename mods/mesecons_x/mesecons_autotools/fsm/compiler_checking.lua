
function msg_state_values(db)

  local l = db.state_values
  if l == nil then return "" end

  local msg = ""
  for k,v in pairs(l) do
    msg = msg .. k .. ":=" .. v .. "\n"
  end
  return msg
end

function msg_inout_values(db)
  local mi = "Inputs: " .. table.concat(db.inputs_used,", ") 
  local mo = "Outputs: " .. table.concat(db.outputs_used,", ")
  return mi .. "\n" .. mo 
end


function is_compilation_success(db)
  local list = {  "init_err" , "pins_err", "states_err" ,"trans_err", 
    "state_values_err", "in_pins_err" , "out_pins_err", "outputs_err" }

  for _,v in pairs(list) do
    if db[v] ~= nil then return false end
  end

  if db.unknowns ~= nil then
    if #db.unknowns ~= 0 then return false end
  end

  return true    
end


function generate_compilation_error_message(db)
  local list = {  "init_err" , "pins_err", "states_err" ,"trans_err", 
    "state_values_err", "in_pins_err" , "out_pins_err" , "outputs_err" }

  local counter = 0
  local msg = ""
  for _,v in pairs(list) do
    if db[v] ~= nil then 
      counter = counter + 1
      msg = msg .. "error:  " .. db[v] .. "\n"  
    end
  end

  -- adding unknows lines
  if db.unknowns ~= nil then 
    if #db.unknowns ~= 0 then
      for _,v in pairs(db.unknowns) do
        msg = msg .. "error: unknown line '" .. v.line .. "'\n"
        counter = counter + 1
      end
    end
  end
  return "Errors (" .. counter .. ")\n" .. msg
end




------------------------------------------------------------------------
-- checking fsm functions
------------------------------------------------------------------------

-- TODO: redesign queue functions
function is_empty_queue(q)
  local count = 0
  for _,v in pairs(q) do
    count = count +1
  end
  if count == 0 then return true end
  return false
end

-- TODO: redesign queue functions
function push_on_queue(q,e)
  local qq = DeepCopy(q)
  table.insert(qq,e)
  return qq  
end

-- TODO: redesign queue functions
function pop_from_queue(q)
  local e = DeepCopy(q[1])
  q[1] = nil
  local newq = {}
  for _,v in pairs(q) do
    table.insert(newq,v)
  end
  return e,newq
end

function get_all_reachable_states(db)
  local init = db.init
  local queue = {}
  local color = {}
  local next_state = {} 
  local curr

  queue = push_on_queue(queue,init)
  while not is_empty_queue(queue) do
    curr,queue = pop_from_queue(queue)
    if color[curr] ~= true then 
      color[curr] = true
      if( db.trans[curr] ~= nil ) then 
        for _,ifthen in pairs(db.trans[curr]) do
          next_state = ifthen.state
          queue = push_on_queue(queue,next_state)
        end
      end
    end
  end
  return color
end


function count_hash(h)
  local c = 0
  for _,_ in pairs(h) do
    c=c+1
  end
  return c
end

-- math.log is computins some trash!!!!!!
-- is that a bug or something
-- making my own binary log function
function lg2(n)
  local c = 0
  local mul = 1
  while (mul < n ) do
    mul = 2* mul
    c=c+1
  end
  return c
end

function get_first_hash_element(h)
  if h == nil then return nil end
  local e = nil
  for k,v in pairs(h) do
    return k,v
  end
  return nil,nil
end


function compute_bitsize_of_state(db)
  local reachable = get_all_reachable_states(db)
  local count = count_hash(reachable)
  local bits_reachable = lg2(count)

  local state_values = db.state_values
  local count_values = count_hash(state_values)

  if( count_values == 0 ) then
    if bits_reachable == 0 then
      return nil,"no reachable states or only one state"
    end
    return bits_reachable
  end

  -- check if all values have the same size
  local fk,fv =  get_first_hash_element(state_values) 
  local flen = string.len(fv)
  for k,v in pairs(state_values) do
    if string.len(v) ~= flen then
      return nil, "states valuse do not have the same length, eg " .. 
      fk .. " := " .. fv .. " and " .. k .. " := " .. v
    end
  end

  -- checking if enoguth bits for reachable states
  if ( bits_reachable > flen ) then 
    return nil, "lenght of state value is too small, need " .. 
    bits_reachable .. " bits to code " .. 
    count .. " states, but got only " .. flen .. 
    "eg. " .. fk .. " := " .. fv 

  end

  if flen == 0 then
    return nil,"no reachable states or only one state"
  end

  return flen
end


function list_to_hash(list)
  local hash = {}
  for _,v in pairs(list) do
    hash[v] = true
  end
  return hash
end

function hash_in_hash(h1,h2)
  for k,_ in pairs(h1) do
    if h2[k] == nil then return false end
  end
  return true
end


function same_hash(h1,h2) 
  if hash_in_hash(h1,h2) and hash_in_hash(h2,h1) then return true else return false end
end
--[[ not used
function hash_cut_hash(h1,h2)
  local h3 = {}
  for k,_ in pairs(h1) do
    if h2[k] ~= nil then
      h3[k] = true
    end
  end
  return h3
end
]]--
function hash_minus_hash(h1,h2)
  local out = {}
  for k,_ in pairs(h1) do
    if h2[k] == nil then 
      out[k] = true
    end
  end
  return out
end


function hash_to_list(h)
  local list = {}
  for k,v in pairs(h) do
    table.insert(list,k)
  end
  return list
end


function check_dead_states(db)
  -- states reachable from init
  local hreachable = db.reachables
  local trans = {}

  -- all states in trans
  for state,v in pairs(db.trans) do
    table.insert(trans,state)
  end

  local htrans = list_to_hash(trans)

  if same_hash(hreachable,htrans) then
    return nil,nil
  else
    local hdiff = hash_minus_hash(htrans,hreachable)
    if count_hash(hdiff) ~= 0 then 
      local ldiff = hash_to_list(hdiff)
      return nil, "following states '" .. table.concat(ldiff,", ") .. 
      "' are used in transitions but are not reachable from init state"
    end
    return nil,nil
  end
end

function cmp_list_eq(a,b)
  local ha = list_to_hash(a)
  local hb = list_to_hash(b)

  return same_hash(ha,hb) 
end


function list_minus_list(l1,l2)
  local h1 = list_to_hash(l1)
  local h2 = list_to_hash(l2)
  local minus = hash_minus_hash(h1,h2)
  return hash_to_list(minus)
end

function get_all_inputs_from_reachable_transitions(db)
  local list = {}
  for state,v in pairs(db.trans) do
    if db.reachables[state] then
      for _,w in pairs(v) do
        append(list,drop_negation_list(w.pins))
      end
    end
  end
  local sorted_by_name = DeepCopy(remove_duplicates(list))
  table.sort(sorted_by_name)
  return sorted_by_name 
end

function get_inpus_from_transistions_and_check_with_declared(db)
  local ins_from_trans = get_all_inputs_from_reachable_transitions(db)
  local ins_from_def = db.in_pins

  if cmp_list_eq(ins_from_def,ins_from_trans) then
    return ins_from_def
  else
    local more_in_def = list_minus_list(ins_from_def,ins_from_trans)
    local more_in_trans = list_minus_list(ins_from_trans, ins_from_def)


    if #more_in_def ~= 0 then 
      return nil, "pins '" .. table.concat(more_in_def, ", ") .. 
      "' declared in 'in:' but never used in transitions";
    end
    if #more_in_trans ~= 0 then
      return nil, "pins '" .. table.concat(more_in_trans, ", " ) ..
      "' used in transitions, but not declared in 'in:'"
    end

    return nil, {"pins declared and pins used in transitions are not the same"}
  end
end

function get_inputs(db)
  -- checking if input pins are not declared
  if db.in_pins == nil or #db.in_pins == 0 then
    return get_all_inputs_from_reachable_transitions(db)
  end

  -- checing if the same as from transistion
  return get_inpus_from_transistions_and_check_with_declared(db)
end

function get_all_output_from_reachable_transitions(db)
  local list = {}
  for state,v in pairs(db.trans) do
    if db.reachables[state] then
      for _,w in pairs(v) do
        if db.outputs[w.state] ~= nil then 
          append(list,db.outputs[w.state])
        end
      end
    end
  end
  
  -- adding also outpus of init state
  append(list, db.outputs[db.init])

  local sorted_by_name = DeepCopy(remove_duplicates(list))
  table.sort(sorted_by_name)
  return sorted_by_name 
end


function get_outputs_from_transistions_and_check_with_declared(db)
  local outs_from_trans = get_all_output_from_reachable_transitions(db)
  local outs_from_def = db.out_pins

  if cmp_list_eq(outs_from_trans,outs_from_def) then
    return outs_from_def
  else
    local more_in_def = list_minus_list(outs_from_def,outs_from_trans)
    local more_in_trans = list_minus_list(outs_from_trans, outs_from_def)


    if #more_in_def ~= 0 then 
      return nil, "pins '" .. table.concat(more_in_def, ", ") .. 
      "' declared in 'out:' but never used in output states";
    end
    if #more_in_trans ~= 0 then
      return nil, "pins '" .. table.concat(more_in_trans, ", " ) ..
      "' used in output state definitons, but not declared in 'out:'"
    end

    return nil, {"pins declared and pins used in transitions are not the same"}
  end  
end

function get_outputs(db)
  -- check if output pins are declared
  if db.out_pins == nil or #db.out_pins == 0 then
    return get_all_output_from_reachable_transitions(db)
  end
  return get_outputs_from_transistions_and_check_with_declared(db)
end



