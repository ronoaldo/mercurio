------------------------------------------------------------------------
-- general functions
------------------------------------------------------------------------

function trim(s)
   return s:match( "^%s*(.-)%s*$" )
end


function get_list_from_string(str)
  local l = {}
  for i in string.gmatch(str,"%S+") do
    table.insert(l,trim(i))
  end
  return l
end

function get_lines_from_string(str)
  local l = {}
  for i in string.gmatch(str,"[^\n]+") do
    table.insert(l,trim(i))
  end
  return l
end

function empty(list)
  if #list == 0 then return true end
  return false
end

-- exists
function e(db,key)
  if db == nil then return false end
  if db[key] ~= nil then return true end
  return false
end

function is_in_list(list,elem)
  for _,v in ipairs(list) do
    if v == elem then return true end
  end
  return false
end

function remove_duplicates(list)
  local l = {}
  local db = {}
  for key,value in pairs(list) do
    db[value] = true
  end
  for key,_ in pairs(db) do
    table.insert(l,key)
  end
  return l
end

------------------------------------------------------------------------
-- help functions
------------------------------------------------------------------------
local name_reg = "[a-zA-Z][a-zA-Z0-9_]*"

function is_name(str)
    return string.match(str,"^" .. name_reg ..  "$")
end

function is_negated(n)
  if string.match(n,"^~.*$") == nil then 
    return false 
  else 
    return true 
  end
end

function drop_negation(n)
  local name = string.match(n,"^~?(.*)$") 
  return name
end

function add_negation(n)
  return "~" .. drop_negation(n)
end

function swap_negation(n)
  if is_negated(n) then 
    return drop_negation(n)
  else
    return add_negation(n)
  end
end


function is_pin_name(n)
  if is_name(n) == nil then return false end
  return true
end

function is_pin_group_name(n)
  local name = string.match(n,"^#(.*)")
  if name == nil then return false end
  return is_pin_name(name)
end

function is_pin_name_n(n)
  if is_pin_name(n) then return true end
  
  local name = string.match(n,"^~(.*)$")
  if name == nil then return false end
  return is_pin_name(name)
end

function is_pin_group_name_n(n)
  if is_pin_group_name(n) then return true end
  
  local name = string.match(n,"^~(.*)$")
  if name == nil then return false end
  return is_pin_group_name(name)
end


function is_pin_and_group_list(list)
  for _,v in pairs(list) do
    if not is_pin_name(v)  and not is_pin_group_name(v) then return false end
  end
  return true
end

function is_pin_name_list(list)
  for _,v in pairs(list) do
    if not is_pin_name(v) then return false end
  end
  return true
end


function is_pin_and_group_list_n(list)
  for _,v in pairs(list) do
    if  not is_pin_name_n(v) and 
        not is_pin_group_name_n(v) then 
          return false 
    end
  end
  return true
end

function is_state_name(n)
    if is_name(n) == nil then return false end
    return true
end

function is_state_group_name(n)
    local name = string.match(n,"^@(.*)")
    if name == nil then return false end
    return is_state_name(name)
end

function is_state_and_group_list(list)
  for _,v in pairs(list) do
    if  (not is_state_name(v)) and 
        (not is_state_group_name(v)) then 
          return false 
    end
  end
  return true
end


--[[ not used, for delete
function is_uniq_list(list)
  local db = {} 
  for _,v in pairs(list) do 
    if db[v] == nil then 
        db[v] = true
    else
        return false
    end
  end
end
]]--
-- find first duplicate
function get_duplicate(list)
  if list == nil then return nil end
  local db = {}
  for _,v in pairs(list) do
    if db[v] == nil then
      db[v] = true
    else
      return v
    end
  end
  return nil
end