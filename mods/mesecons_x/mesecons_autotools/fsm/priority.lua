function pins_to_area(pins,defined_pins)
  -- pins : list

  local part = {}
  for _,pin in pairs(pins) do
    if is_negated(pin) then
      part[drop_negation(pin)] = false
    else
      part[pin] = true
    end
  end

  local parts = {}
  table.insert(parts,part)

  local area = {}

  area.vars = defined_pins
  area.parts = parts

  return area
end

function part_to_pins(part)
  local list = {}
  for k,v in pairs(part) do 
    if v == true then
      table.insert(list, k)
    else
      table.insert(list, add_negation(k))
    end
  end
  return list
end

function apply_priority_state(list_ifs,defined_pins)
  if list_ifs == nil then return nil end
  if #list_ifs == 0 then return {} end
  local new_ifs = {}
  local aggreg_area = pins_to_area(list_ifs[1].pins,defined_pins)
  
  table.insert(new_ifs,list_ifs[1])

  for i=2,#list_ifs do
    local curr_area = pins_to_area(list_ifs[i].pins,defined_pins)
    local new_area = area_sub(curr_area,aggreg_area)
    aggreg_area = area_add(aggreg_area,curr_area)

    for _,part in pairs(new_area.parts) do
      table.insert(new_ifs, { pins = part_to_pins(part), state = list_ifs[i].state })
    end
  end
  return new_ifs
end

function apply_priority_special_case_no_input_pins(db)  
  -- no inputs, adding one phantom input
  table.insert(db.inputs_used, "x")
  apply_priority(db)
  db.inputs_used = {}
 
end

-- changes db.trans
function apply_priority(db)
  if db.inputs_used == nil then return end
  if #db.inputs_used == 0 then 
    if count_hash(db.trans) == 0 then 
      return
    else
      apply_priority_special_case_no_input_pins(db)
      return
    end
  end


  local new_trans = {}
  for state, v in pairs(db.trans) do
    new_trans[state] = apply_priority_state(v, db.inputs_used)
  end
  db.trans = new_trans
end

------------------------------------------------------------------------
-- other algorithms
------------------------------------------------------------------------

function clear_empty_transitions(db)
  for state,ifs in pairs(db.trans) do
    if #ifs == 0 then 
      db.trans[state] = nil
    end
  end
end


------------------------------------------------------------------------
-- default behavior
------------------------------------------------------------------------


function add_default_loops(db)
  -- if no transition, stay in current state
  local hreachables = db.reachables
  for s,_ in pairs(hreachables) do
    if db.trans[s] == nil then
      db.trans[s] = {}
    end
    table.insert(db.trans[s], { pins = {} , state = s } )
  end
end


