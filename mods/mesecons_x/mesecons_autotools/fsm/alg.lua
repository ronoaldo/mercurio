------------------------------------------------------------------------
-- logic functions
------------------------------------------------------------------------


function show(area)
  local vars = area.vars
  local s = ""
  dump(area)
  if #area.parts == 0 then 
    s = "(none)"
  else
    
    for _,part in pairs(area.parts) do
      for _,v in ipairs(vars) do
        if ( part[v] == true ) then s = s .. "  " .. v  end
        if part[v] == false then s = s .. " ~" .. v  end
        if part[v] == nil then s = s .. "  x" end
      end
      s = s .. "\n"
    end
    return s
  end
end


function area_add(a1,a2)
  local a3 = area_copy(a1)
  
  for _,v in pairs(a2.parts) do
    table.insert(a3.parts,v)
  end
  return a3
end


function drop_negation_list(list)
  local l = {}
  for _,v in pairs(list) do
    table.insert(l, drop_negation(v))
  end
  return l
end

function swap_truefalse(v)
  if v == true then return false end
  return true
end


function part_sub_part(a,b)  
  
  local vars = {}
  
  for keya,_ in pairs(b) do
    if (a[keya] == true and b[keya] == false ) or 
    ( a[keya] == false and b[keya] == true  ) then 
        local ll = {}
        table.insert(ll,a)
        return ll 
      end
  
    if a[keya] == nil and b[keya] ~= nil then 
      vars[keya] = swap_truefalse(b[keya])
    end
  end
  
  local parts = {}
  for k,v in pairs(vars) do
    local new = copy_list(a)
    new[k] = v
    table.insert(parts,new)
  end
  return parts
end

function insert_parts_in_area(a,list)
  local c = {}
  c = area_copy(a)
  for _,v in pairs(list) do
    table.insert(c.parts, v)
  end
  return c
end


function area_sub_part(a,p)
  local c = {}
  c.vars = copy_list(a.vars)
  c.parts = {}
  
  for _,part in pairs(a.parts) do
    local l = part_sub_part(part,p)
    c = insert_parts_in_area(c,l)
  end
  return c
end

--[[
function copy_list(l)
  local nl = {}
  for k,v in pairs(l) do
    nl[k] = v
  end
  return nl
end
]]--
function copy_list(l)
  return DeepCopy(l)
end



function area_copy(a)
  return DeepCopy(a)
end

--[[
function area_copy(a)
  local c = {}
  c.vars = copy_list(a.vars)
  c.parts = {}
  for _,v in pairs(a.parts) do
    table.insert(c.parts, copy_list(v))
  end
  return c
end
]]--

function area_sub(a,b)
  local c = {}
  c = area_copy(a)
  
  for _,v in pairs(b.parts) do
    c = area_sub_part(c,v)
  end
  return c
end



--[[
local a1 = { 
    vars={"a","b","c","d"}, 
    parts = { 
      { d = true} , 
      --{c = true } 
      }
  }
local a2 = { 
    vars={"a","b","c","d"}, 
    parts = { { a=false, b =true,c = true}  }
  }
  
  ]]--
--local a = area_sub(a1,a2)


--[[
print(show(a1))
print(show(a2))
print(show(a))
--]]