
dofile(minetest.get_modpath("mesecons_autotools").."/fsm/compiler_general.lua");
dofile(minetest.get_modpath("mesecons_autotools").."/fsm/compiler_parsing.lua");
dofile(minetest.get_modpath("mesecons_autotools").."/fsm/compiler_generating.lua");
dofile(minetest.get_modpath("mesecons_autotools").."/fsm/compiler_checking.lua");

------------------------------------------------------------------------
-- compilation functions
------------------------------------------------------------------------

function compile_init(inits)
  if empty(inits) then return nil,"no init state" end
  if #inits ~= 1 then return nil,"more than one init states" end
  return inits[1]
end

function compile_pin_assigns(pins_assigns)
  local db = {}
  for _,v in ipairs(pins_assigns) do

    -- check if already defined
    if e(db,v.pin) then 
      return nil, "pin " .. v.pin .. " defined two times"
    end

    -- check if self loop
    if is_in_list(v.pins,drop_negation(v.pin)) then 
      return nil, "self reference in definition " .. v.pin 
    end
    if is_in_list(v.pins,add_negation(v.pin)) then 
      return nil, "self reference in definition " .. v.pin 
    end

    -- expand pins
    local pins_expanded = {}
    for _,p in ipairs(v.pins) do 
      if is_pin_name_n(p) then 
        table.insert(pins_expanded,p)
      elseif is_pin_group_name_n(p) then
        local gr = drop_negation(p)
        if e(db,gr) then 
          for _,pp in ipairs(db[gr]) do
            if( is_negated(p) ) then 
              table.insert(pins_expanded,swap_negation(pp))
            else
              table.insert(pins_expanded,pp)
            end
          end          
        else
          return nil, "pin " .. p .. " no defined in " .. v.pin .. " definition"
        end
      end
    end
    db[v.pin] = remove_duplicates( pins_expanded )
  end
  return db
end


function compile_state_assigns(state_assigns)
  local db = {}
  for _,v in ipairs(state_assigns) do

    -- check if already defined
    if e(db,v.state) then 
      return nil, "state group " .. v.state .. " defined two times"
    end

    -- check if self loop
    if is_in_list(v.states,v.state) then 
      return nil, "self reference in definition " .. v.state 
    end

    -- expand pins
    local states_expanded = {}
    for _,p in ipairs(v.states) do 
      if is_state_name(p) then 
        table.insert(states_expanded,p)
      elseif is_state_group_name(p) then
        if e(db,p) then 
          for _,pp in ipairs(db[p]) do
            table.insert(states_expanded,pp)
          end          
        else
          return nil, "state " .. p .. " no defined in definition " .. v.state  
        end
      end
    end
    db[v.state] =remove_duplicates( states_expanded )
  end

  return db
end

function expand_pin(pin,db)
  if is_negated(pin) then
    local pure = drop_negation(pin)
    if db[pin] == nil then
      local l = {}
      table.insert(l,pin)
      return l
    else
      local l = {}
      for _,v in pairs(db[pure]) do
        table.insert(l,swap_negation(v))
      end
      return l
    end
  else      
    if db[pin] == nil then 
      local l = {}
      table.insert(l,pin)
      return l
    else
      return db[pin]
    end
  end
end



function expand_pins(list, db)
  local l = {}
  for _,pin in ipairs(list) do
    for _,p in ipairs( expand_pin(pin,db) ) do
      table.insert(l,p)
    end
  end
  return l
end

function expand_state(s,db)
  local l = {}
  if db[s] == nil then 
    table.insert(l,s)
    return l
  else
    return db[s]
  end
end

function expand_states(list, db)
  local l = {}
  for _,state in ipairs(list) do
    for _,p in ipairs( expand_state( state, db) ) do
      table.insert(l,p)
    end
  end
  return l
end


function all_defined_states(db,list)
  for _,v in pairs(list) do
    if is_state_group_name(v) then
      if not e(db,  v) then 
        return false,v
      end
    end
  end
  return true
end

function all_defined_pins(db,list)
  for _,v in pairs(list) do
    if is_pin_group_name(v) then
      if not e(db,  v) then 
        return false,v
      end
    end
  end
  return true
end


function compile_state_outputs(state_outputs, db_pins, db_states)
  local db = {}
  for _,v in ipairs(state_outputs) do 
    local states = v.states
    local pins = v.pins


    local df,err
    -- expanding pins
    local pins_exp = expand_pins(pins,db_pins)
    df,err = all_defined_pins(db_pins,pins_exp)
    if df == false then       
      return nil, "pin '" .. err .. "' not defined in line: " .. v.line
    end


    --expand states
    local states_exp = expand_states(states, db_states)
    df,err = all_defined_states(db_states,states_exp)
    if df == false then 
      return nil, "state '" .. err ..  "' not defined, error in line: " .. v.line
    end


    -- check if state already defined 
    for _,w in pairs(states_exp) do 
      if e(db,w) then
        return nil, "state output '" .. w .. "' already defined, duplicate in line: " .. v.line  
      else
        db[w] = pins_exp
      end
    end
  end
  return db
end


function compile_state_transitions(state_transitions, db_pins, db_states)
  local db = {}
  if state_transitions == nil then
    return nil,"no transitions"
  end
  if #state_transitions == 0 then 
    return nil, "no transitions"
  end
  for _,v in pairs(state_transitions) do
    local states = v.states
    local pins = v.pins
    local state = v.state

    --expand 
    local df,err
    -- expanding pins
    local pins_exp = expand_pins(pins,db_pins)
    df,err = all_defined_pins(db_pins,pins_exp)
    if df == false then
      return nil, "pin " .. err .. " not defined, error in line: " .. v.line
    end

    --expand states
    local states_exp = expand_states(states, db_states)
    df,err = all_defined_states(db_states,states_exp)
    if df == false then 
      return nil, "state " .. err ..  " not defined, error in line: " .. v.line
    end

    -- building db
    for _,w in ipairs(states_exp) do
      if db[w] == nil then db[w] = {} end
      table.insert(db[w], { pins = pins_exp, state = state } )
    end
  end
  
  if count_hash(db) == 0 then
    return nil,"coudn't find any transitions"
  end
  
  return db
end

function compile_state_values(state_values)
  local db = {}
  if state_values == nil then return db end

  for _,v in pairs(state_values) do
    local state = v.state
    local value = v.value
    if db[state] ~= nil then 
      return nil, "duplicate state value definition, ".. state .. 
      " := " .. db[state] .. " and " .. state .. " := " .. v.value
    else
      db[state] = value
    end
  end

  -- checking if all values the same length

  local min = 0
  -- seting initial value of min (bigger than any of the elment)
  for k,v in pairs(db) do
    min = min + string.len(v)
  end

  local max = 0
  local maxs,mins
  for k,v in pairs(db) do
    if string.len(v) < min then
      min = string.len(v)
      mins = k
    end
    if string.len(v) > max then
      max = string.len(v)
      maxs = k
    end
  end

  if (min ~= 0 and min ~= max) then
    return nil, "values of states have different length, " .. mins .. " := " .. db[mins] ..
    " and " .. maxs .. " := " .. db[maxs] 
  end

  -- checking if values are uniq
  local vdb = {} 
  for k,v in pairs(db) do
    if vdb[v] ~= nil then
      return nil, "duplicate state value, " .. k .. " := " .. v .. " and " .. vdb[v] .. " := " .. v
    else
      vdb[v] = k
    end
  end

  return db
end





function compile_in_pins(in_pins)
  if #in_pins > 1 then return nil, "multiple input pins definitions" end

  local duplicate = get_duplicate(in_pins[1])
  if duplicate == nil then 
    return (in_pins[1] or {})
  else
    return nil, "input pins duplicated: " .. duplicate
  end
end

function compile_out_pins(out_pins)     
  if #out_pins > 1 then return nil, "multiple output pins definitions" end

  local duplicate = get_duplicate(out_pins[1])
  if duplicate == nil then 
    return (out_pins[1] or {} )
  else
    return nil, "output pins duplicated: " .. duplicate
  end
end




function compile_code(code)

  local data = parse_code(code)
  local db = {}


  local init,erroi = compile_init(data.inits)
  local bin_pins,errop = compile_pin_assigns(data.pin_assigns)
  local bin_states,erros = compile_state_assigns(data.state_assigns)
  local bin_outputs,erroo = compile_state_outputs(data.state_outputs, bin_pins,bin_states)
  local bin_trans,errot = compile_state_transitions(data.state_transitions, bin_pins,bin_states)
  local bin_state_values, errosv = compile_state_values(data.state_values)
  local bin_in_pins,erroip = compile_in_pins(data.in_pins)
  local bin_out_pins,erroop = compile_out_pins(data.out_pins)

  db.init = init
  db.init_err = erroi

  db.pins = bin_pins
  db.pins_err = errop

  db.states = bin_states
  db.states_err = erros

  db.outputs = bin_outputs
  db.outputs_err = erroo

  db.trans = bin_trans 
  db.trans_err = errot

  db.state_values = bin_state_values
  db.state_values_err = errosv

  db.in_pins = bin_in_pins
  db.in_pins_err = erroip

  db.out_pins = bin_out_pins
  db.out_pins_err = erroop

  db.unknowns = data.unknowns
  

  if not is_compilation_success(db) then 
    return nil,generate_compilation_error_message(db)
  end


  -- further processing 

  -- warning: orders of executing functions is important, they depend on the db data
  -- I know, it's a huge weld :)
  local errs = {}
  local err
  local msg = ""
  function insert_error(err)
    if err ~= nil then 
      if type(err) == "table" then 
        for _,i in pairs(err) do 
          table.insert(errs,i)
        end
      else
        table.insert(errs,err) 
      end
    end
  end
  function err_string()
    -- show errors
    if #errs > 0 then 
      msg = ""
      for _,v in pairs(errs) do
        msg = msg .. "error: " .. v .. "\n"
      end
      msg = "Errors(".. #errs .. "):\n" .. msg
      return msg
    end
    return ""
  end



  db.reachables = get_all_reachable_states(db)

  _,err = get_not_used_states(db)
  insert_error(err); if #errs ~= 0 then return nil, err_string() end

  db.state_bitsize,err = compute_bitsize_of_state(db)  
  insert_error(err); if #errs ~= 0 then return nil, err_string() end

  db.state_values = only_reachable_state_values(db)

  _,err = check_dead_states(db)
  insert_error(err); if #errs ~= 0 then return nil, err_string() end

  db.state_values,err = fill_states_values(db)
  insert_error(err); if #errs ~= 0 then return nil, err_string() end

  db.inputs_used,err = get_inputs(db)
  insert_error(err); if #errs ~= 0 then return nil, err_string() end

  db.outputs_used,err = get_outputs(db)
  insert_error(err); if #errs ~= 0 then return nil, err_string() end

  
  

  --- further checking: applying priority and others
  add_default_loops(db)    
  apply_priority(db)  
  clear_empty_transitions(db)

  -- the part above must be rewritten, too many welds here
  -- additionally, algorithm does not remove all unused states, 
  -- therefore sometimes it generates dead transistions
  -- the FSM is correct, but when generated has unused subcircuits
  -- TODO: fix this
  
  ----------------------------------------

  

  

  return db,"\nCompilation successful\n\n" ..
  msg_state_values(db) .. "\n" ..
  "\n" .. msg_inout_values(db)

end





