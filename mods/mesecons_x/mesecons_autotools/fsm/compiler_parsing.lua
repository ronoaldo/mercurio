
------------------------------------------------------------------------
-- parsing functions
------------------------------------------------------------------------

function is_pin_assign(line)
    if line == nil then return nil end
    local pin,pins = string.match(line,"^%s*([#].*)%s*=(.*)$")
    if pin == nil or pins == nil then return nil end
    pin = trim(pin)
    
    if( is_pin_group_name(trim(pin)) ~= true ) then return nil end
    
    local list = get_list_from_string(pins)
    if( not is_pin_and_group_list_n(list) ) then return nil end
    
    local data = {}
    data.pin = pin
    data.pins = list
    return data
  end
  

function is_state_assign(line)
    if line == nil then return nil end
    local state,states = string.match(line, "^%s*(@.*)%s*=(.*)$")
    if state == nil or states == nil then return nil end
    state = trim(state)
    
    if( not is_state_group_name(state) ) then return nil end
    
    local list = get_list_from_string(states)
    if( not is_state_and_group_list(list) ) then return nil end
    
    local data = {}
    data.state = state
    data.states = list
    data.line = line
    return data
end

function is_bin_value(value)
  if value == nil then return false end
  for i=1,#value do
    local ch = string.sub(value,i,i)
    if (ch ~= "0" ) and (ch ~= "1" ) then return false end
  end
  return true
end


function is_state_value_assign(line)
    if line == nil then return nil end
    local state,value = string.match(line, "^%s*(.*)%s*:=(.*)$")
  
    if state == nil then return nil end
    if value == nil then return nil end
    state = trim(state)
    value = trim(value)
    
    if not is_state_name(state) then return nil end
    if not is_bin_value(value) then return nil end
    
    local data = {} 
    data.state = state
    data.value = value
    return data
end


function is_in_assign(line)
    if line == nil then return nil end
    local ins = string.match(line, "^%s*in:(.*)$")
  
    if ins == nil then return nil end
    local list = get_list_from_string(ins)
    if( not is_pin_name_list(list) ) then return nil end
    
    local data = {} 
    data = list
    return data
end

function is_out_assign(line)
     if line == nil then return nil end
    local ins = string.match(line, "^%s*out:(.*)$")
  
    if ins == nil then return nil end
    local list = get_list_from_string(ins)
    if( not is_pin_name_list(list) ) then return nil end
    
    local data = {} 
    data = list
    return data 
end


function is_init_assign(line)
  if line == nil then return nil end
  local init = string.match(line,"^%s*[[][[]%s*(.*)%s*[]][]]%s*$")
  if init == nil then return nil end
  if( not is_state_name(init)) then return nil end
  return trim(init)
end


function is_state_output_assign(line)
  if line == nil then return nil end
  local states,pins = string.match(line, "^%s*[[]%s*(.*)%s*[]](.*)$")
  if( states == nil or pins == nil ) then return nil end
  
  local state_list = get_list_from_string(states)
  if empty(state_list) then return nil end
  if not is_state_and_group_list(state_list) then return nil end
  
  local pin_list = get_list_from_string(pins)
  if empty(pin_list) then return nil end
  --if not is_pin_and_group_list_n(pin_list) then return nil end
  if not is_pin_and_group_list(pin_list) then return nil end
  --if not is_pin_name_list(pin_list) then return nil end
  
  local data = {}
  data.states = state_list
  data.pins = pin_list
  data.line = line
  return data
end

function is_state_transition_assign(line)
  if line == nil then return nil end
  local states,pins,state = string.match(line,"^%s*[[](.*)[]](.*)->%s*[[](.*)[]]%s*$")
  if states == nil or state == nil or pins == nil then return nil end
  
  local state_list = get_list_from_string(states)
  if empty(state_list) then return nil end
  if not is_state_and_group_list(state_list) then return nil end
  
  local pin_list = get_list_from_string(pins)
  if not is_pin_and_group_list_n(pin_list) then return nil end
  
  if not is_state_name(trim(state)) then return nil end
  
  local data = {}
  data.states = state_list
  data.pins = pin_list
  data.state = trim(state)
  data.line = line
  return data
end

function is_comment(line)
  if line == nil then return nil end
  local comment = string.match(line,"^%s*;.*$")
  return comment
end



function parse_code(text)
  local inits = {}
  local pin_assigns = {}
  local state_assigns = {}
  local state_outputs = {}
  local state_transitions = {}
  local state_values = {}
  local in_pins = {}
  local out_pins = {}
  local unknowns = {}
  
  local lines = get_lines_from_string(text)
  for i,line in ipairs(lines) do
    local init = is_init_assign(line)
    local pin_assgn = is_pin_assign(line)
    local state_assign = is_state_assign(line)
    local state_output = is_state_output_assign(line)
    local state_transition = is_state_transition_assign(line)
    local state_value = is_state_value_assign(line)
    local in_pin = is_in_assign(line)
    local out_pin = is_out_assign(line)
    local comment  = is_comment(line)
    
    if( init ~= nil ) then 
      table.insert(inits,init)
    elseif pin_assgn ~= nil then
      table.insert(pin_assigns,pin_assgn)
    elseif state_assign ~= nil then 
      table.insert(state_assigns,state_assign)
    elseif state_output ~=nil then 
      table.insert(state_outputs,state_output)
    elseif state_transition ~= nil then 
      table.insert(state_transitions, state_transition)
    elseif state_value ~= nil then
      table.insert(state_values,state_value)
    elseif in_pin ~= nil then
      table.insert(in_pins,in_pin)
    elseif out_pin ~= nil then
      table.insert(out_pins,out_pin)
    elseif comment ~= nil then 
      -- drop comment
    else
      table.insert(unknowns,{nr=i, line = line})
    end
  end
  
  local data = {}
  data.inits = inits
  data.pin_assigns = pin_assigns
  data.state_assigns = state_assigns
  data.state_outputs = state_outputs
  data.state_transitions = state_transitions
  data.state_values = state_values
  data.in_pins = in_pins
  data.out_pins = out_pins
  data.unknowns = unknowns
  return data
end
