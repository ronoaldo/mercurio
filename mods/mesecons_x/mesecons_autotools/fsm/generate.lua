------------------------------------------------------------------------
-- generating wires
------------------------------------------------------------------------
function g_wire_line(rotation,state)
  local r = 0
  if rotation == "h" then
    r = 0
  else -- == "v"
    r = 1
  end
  return {
    node = {name="mesecons_insulated:insulated_".. state , param2 = r}, 
    meta = {}
  }
end

function g_wire_bend(rotation,state)
  local rot = 0
  if rotation == "lu" then
    rot = 1
  elseif rotation == "ru" then
    rot = 2 
  elseif rotation == "rd" then
    rot = 3
  elseif rotation == "ld" then
    rot = 0
  else
    rot = 0 
  end
  return { 
    node = {name="mesecons_extrawires:corner_" .. state, param2=rot},
    meta = {}
  }
end

function g_wire_cross(state)
  local s = "off"
  if state == "off" then
    s = "off"
  elseif state == "on" then
    s = "on"
  elseif state == "h" then
    s = "01"
  elseif state == "v" then
    s = "10"
  else
    s = "off"
  end
  return {
    node = {name="mesecons_extrawires:crossover_" .. s, param2=0},
    meta = {}
  }
end

function g_wire_t(rotation,state)
  local p = 0
  if rotation == "u" then
    p = 2
  elseif rotation == "d" then
    p = 0
  elseif rotation == "l" then
    p = 1
  else -- "r"
    p = 3
  end
  return {
    node = {name="mesecons_extrawires:tjunction_" .. state, param2=p},
    meta = {}
  }
end

function g_wire_xjunction(state)
  return {
    node = {name="mesecons_morewires:xjunction_" .. state, param2=0},
    meta = {}
  }
end

------------------------------------------------------------------------
-- generating gates
------------------------------------------------------------------------


function g_gate_not(state,rot)
  local p 
  if rot == "up" then 
    p = 3 
  elseif rot == "left" then
    p = 2
  elseif rot == "right" then
    p = 0
  else --down
    p = 1 
  end

  return {
    node =  {name="mesecons_gates:not_" .. state,param2=p},
    meta = { ["inventory"] = { } ,["fields"] = { } ,} 
  }
end

function g_gate_diode(state,rot)
  local p 
  if rot == "up" then 
    p = 3 
  elseif rot == "left" then
    p = 2
  elseif rot == "right" then
    p = 0
  else --down
    p = 1 
  end
  return {
    node =  {name="mesecons_gates:diode_" .. state, param2=p},
    meta = { ["inventory"] = { } ,["fields"] = { } ,} 
  }
end

function g_ff(state,rot,data) -- din = data in
  local p 
  if rot == "up" then 
    p = 3 
  elseif rot == "left" then
    p = 2
  elseif rot == "right" then
    p = 0
  else --down
    p = 1 
  end
  local din
  if data == "off" then din = 0 else din =1 end
  return {
    node={ name = "mesecons_regs:flipflop_off" ,param2 = p} ,
    meta={ ["inventory"] = { } ,["fields"] = { ["enable"] = 0,["data"] = din,} } 
  }
end


------------------------------------------------------------------------
-- help functions
------------------------------------------------------------------------

function set(circ,x,z,elem)
  local node = elem.node
  local meta = elem.meta
  m3_set(circ.nodes,x,1,z,node)
  m3_set(circ.metas,x,1,z,meta)
end


function is_bl_empty(c)
  if c == nil then return true end
  if c.nodes == nil then return true end
  if c.nodes.sx == 0 or c.nodes.sy == 0 or c.nodes.sz==0 then return true end
  return false
end


-- block insert
function blinsert(chost,celem,x,y,z)
  if is_bl_empty(celem) then return end
  m3_insert(chost.nodes,celem.nodes,x,y,z)
  m3_insert(chost.metas,celem.metas,x,y,z)
end




function is_all_zeros(v)
  for i=1,string.len(v) do
    if string.sub(v,i,i) ~= "0" then
      return false
    end
  end
  return true
end

function new_circ()
  return { nodes = { sx=0,sy=0,sz=0} , metas = {sx=0,sy=0,sz=0} }
end

function gnode_to_circ(n)
  local c = new_circ()
  set(c,1,1,n)
  c.nodes.sx = 1
  c.nodes.sy = 1
  c.nodes.sz = 1
  c.metas.sx = 1
  c.metas.sy = 1
  c.metas.sz = 1
  return c
end


function inverse_state(v)
  if v == "on" then return "off" else return "on" end
end


function switch_01_to_onoff(c)
  if c == "0" then 
    return "off" 
  else
    return "on"
  end
end

--[[ not used 
function has_negation(list)
  for _,v in pairs(list) do
    if is_negated(v) then
      return true
    end
  end
  return false
end
]]--
function has_positive_pin(list)
  for _,v in pairs(list) do
    if not is_negated(v) then
      return true
    end
  end
  return false
end


function or_state(s1,s2)
  if s1 == "off" and s2 == "off" then return "off" else return "on" end
end

function or_value(v1,v2)
  local s = ""
  for i=1,string.len(v1) do
    if string.sub(v1,i,i) == "0" and string.sub(v2,i,i) == "0" then
      s = s .. "0" 
    else
      s = s .. "1"
    end
  end
  return s
end

------------------------------------------------------------------------
-- generating bundles of wires
------------------------------------------------------------------------

function bl_bend_1wire_from_down_to_right(x0,y0, x1,y1)
  -- (x0,y0) to (x1,y1) first going up, then going right
  local c = new_circ()

  -- vertical
  for i=y0,y1-1 do
    blinsert(c,gnode_to_circ( g_wire_line("v","off") ), x0,1,i)
  end

  -- curve
  blinsert(c,gnode_to_circ(g_wire_bend("rd","off")), x0,1,y1)

  -- horizontal
  for i=x0+1,x1 do
    blinsert(c,gnode_to_circ(g_wire_line("h","off")),i,1,y1)
  end
  return c
end


function bl_bend_bundle_from_down_to_right_step2(size)
  local c = new_circ()

  for i=1,size do
    local shifth = (i-1)*2+1
    local shiftv = size - i +1
    local maxshift = size*2-1
    blinsert(c, bl_bend_1wire_from_down_to_right(shifth,1,maxshift,shiftv),1,1,1)
  end
  return c
end


function bl_t_bundle_to_down_step2(size)
  -- crossing
  local c = new_circ()
  for i=1,size do
    local hshift = (i-1)*2+1

    for k=1,size-i do
      blinsert(c,gnode_to_circ(g_wire_cross("off")),hshift,1,k)
    end

    local vstart = size-i+1
    blinsert(c,gnode_to_circ(g_wire_t("d","off")),hshift,1,vstart)

    for k=size-i+2,size do
      blinsert(c, gnode_to_circ(g_wire_line("h","off")),hshift,1,k)
    end
  end

  for i=1,size do
    local hsift = (i-1)*2+1+1
    for k=1,size do
      blinsert(c,gnode_to_circ(g_wire_line("h","off")),hsift,1,k)
    end
  end
  return c
end


function add_left_connection(size)
  -- adding connections
  local left = new_circ()
  for i=1,size do
    blinsert(left,gnode_to_circ(g_wire_line("h","off")),1,1,i)
    blinsert(left,gnode_to_circ(g_wire_line("h","off")),2,1,i)
  end
  return left
end

function bl_bundle_horisontal(count,length)
  local  c = new_circ()
  for x=1,length do
    for y=1,count do
      blinsert(c,gnode_to_circ(g_wire_line("h","off")),x,1,y)
    end
  end
  return c
end


function add_down_connection(size)
  local down = new_circ()
  for i=1,size do
    local hshift = (i-1)*2+1
    blinsert(down,gnode_to_circ(g_wire_line("v","off")),hshift,1,1)
    blinsert(down,gnode_to_circ(g_wire_line("v","off")),hshift,1,2)
  end
  return down
end

function bl_t_bundle_to_down_step2_and_down_conn(size)
  -- crossing
  local c = bl_t_bundle_to_down_step2(size)

  -- adding connections
  local down = add_down_connection(size) 

  local all = new_circ()
  blinsert(all,down,1,1,1)
  blinsert(all,c,1,1,3)
  return all

end


function bl_t_bundle_to_down_step2_and_connections(size)

  -- crossing
  local c = bl_t_bundle_to_down_step2(size)

  -- connections
  local left = add_left_connection(size)
  local down = add_down_connection(size)

  local all = new_circ()
  blinsert(all,left,1,1,3)
  blinsert(all,down,3,1,1)
  blinsert(all,c,3,1,3)
  return all

end



------------------------------------------------------------------------
-- generating circuits
------------------------------------------------------------------------


function bl_frame(gate, gstate, vstate, hstate,rot)
  -- rot = "up" | "down"

  local c = {}
  c.nodes = {}
  c.metas = {}

  if gate == "diode" or gate == "not" then 
    -- vertical wires
    set(c,1,1, g_wire_t("r",vstate))
    set(c,2,1, g_wire_bend("lu",vstate))
    set(c,1,2, g_wire_line("v",vstate))

    if gate == "diode" then 
      set(c,2,2, g_gate_diode(gstate,rot))
    else
      set(c,2,2, g_gate_not(gstate,rot))
    end

    --horizontal wires
    set(c,2,3, g_wire_t("d",hstate))

  else -- wire
    set(c,1,1, g_wire_line("v",vstate))
    set(c,1,2, g_wire_line("v",vstate))
    set(c,2,3, g_wire_line("h",hstate))
  end

  -- crossing
  if hstate == "off" and vstate == "off" then
    set(c,1,3, g_wire_cross("off"))
  elseif hstate == "on" and vstate == "off" then
    set(c,1,3, g_wire_cross("h"))
  elseif hstate == "off" and vstate == "on" then
    set(c,1,3, g_wire_cross("v"))
  else
    set(c,1,3, g_wire_cross("on"))
  end

  c.nodes.sx = 2
  c.nodes.sy = 1
  c.nodes.sz = 3
  c.metas.sx = 2
  c.metas.sy = 1
  c.metas.sz = 3
  return c
end


function bl_ff(data)
  local c = new_circ()
  set(c,1,1,g_ff("off","up",data))
  set(c,1,2,g_wire_cross("off"))
  set(c,2,2,g_wire_t("d","off"))
  set(c,2,1,g_wire_bend("lu","off"))
  c.nodes.sx = 2
  c.nodes.sy = 1
  c.nodes.sz = 2
  c.metas.sx = 2
  c.metas.sy = 1
  c.metas.sz = 2
  return c
end


function bl_register(vvalue)
  local c = new_circ()
  for i=1,#vvalue do
    local char = string.sub(vvalue,i,i)
    if char == "0" then
      blinsert(c,bl_ff("off"),(i-1)*2+1,1,1)
    else
      blinsert(c,bl_ff("on"),(i-1)*2+1,1,1)
    end
  end
  return c
end


function bl_state_value_in(v,hstate)
  -- eg. v = "01011" 
  local len = string.len(v)
  local vstate = "off"
  local c = new_circ()
  local rot = "up"

  local curri = 1
  for i=1,len do
    local char = string.sub(v,i,i)
    if char == "0" then 
      blinsert(c,bl_frame("diode",vstate, vstate,hstate,rot), (i-1)*2+1,1,1 )
    else
      blinsert(c,bl_frame("not",inverse_state(vstate), vstate,hstate,rot), (i-1)*2+1,1,1 )
    end
  end

  return c
end

function bl_state_value_out(v,hv,vvalue)
  -- eg. v = "01011" 
  -- eg. hv = "on" | "off"
  -- eg. vvalue "010110"
  local len = string.len(v)
  local c = new_circ()
  local rot = "down"

  local curri = 1
  for i=1,len do
    local char = string.sub(v,i,i)
    local out_wire_state = switch_01_to_onoff(string.sub(vvalue,i,i))
    if char == "1" then 
      blinsert(c,bl_frame("diode",hv, out_wire_state, hv, rot), (i-1)*2+1,1,1 )
    else
      blinsert(c,bl_frame("wire",hv, out_wire_state, hv, rot), (i-1)*2+1,1,1 )
    end
  end
  return c
end


function bl_pin_value(pins, defined_pins,hstate)
  local hpins = list_to_hash(pins)
  local c = new_circ()
  local rot = "up"
  local vstate = "off"
  for  i=1,#defined_pins do
    local v = defined_pins[i]
    local p = (i-1)*2+1
    if hpins[v] ~= nil then
      blinsert(c,bl_frame("not",inverse_state(vstate), vstate, hstate,rot),p,1,1)
    elseif hpins[add_negation(v)] ~= nil then
      blinsert(c,bl_frame("diode",vstate, vstate, hstate,rot), p,1,1)
    else
      blinsert(c,bl_frame("wire",vstate, vstate, hstate,rot), p,1,1)
    end
  end
  return c
end



function generate_ifthens(db)
  local c = new_circ()

  -- computing output state
  local cumulative_state = string.rep("0", db.state_bitsize)
  for state,ifs in pairs(db.trans) do
    for _,v in pairs(ifs) do
      local pins = v.pins
      local valuein = db.state_values[state]
      local valueout = db.state_values[v.state]
      local if_pin_state 
      if has_positive_pin(pins) then
        if_pin_state = "on"
      else
        if_pin_state = "off"
      end

      local if_state_state
      if is_all_zeros(valuein) then
        if_state_state = "off"
      else
        if_state_state = "on"
      end
      local if_state = or_state(if_pin_state, if_state_state)

      if if_state == "off" then -- because of negation in front of it
        -- so this one is active
        cumulative_state = or_value(cumulative_state,valueout)
      end
    end
  end

  -- generating 
  local thens = new_circ()
  local ifs = new_circ()
  local i = 1
  for state,ife in pairs(db.trans) do
    for _,v in pairs(ife) do
      local pins = v.pins
      local valuein = db.state_values[state]
      local valueout = db.state_values[v.state]
      local defined_pins = db.inputs_used

      -- if state == 0000 then skip generating
      if not is_all_zeros(valueout) then

        local if_pin_state 
        if has_positive_pin(pins) then
          if_pin_state = "on"
        else
          if_pin_state = "off"
        end

        local if_state_state
        if is_all_zeros(valuein) then
          if_state_state = "off"
        else
          if_state_state = "on"
        end

        local if_state = or_state(if_pin_state, if_state_state)


        local bl_statein = bl_state_value_in(valuein,if_state)
        local bl_pinsin = bl_pin_value(pins, defined_pins, if_state)
        local bl_stateout = bl_state_value_out(valueout,inverse_state(if_state), cumulative_state)

        -- putting all together
        local curr_pos = (i-1)*3+1
        blinsert(thens,bl_stateout,1,1,curr_pos)

        blinsert(ifs, gnode_to_circ(g_gate_not(inverse_state(if_state) ,"left")),1,1,curr_pos+2)
        blinsert(ifs, bl_statein, 2,1,curr_pos)
        blinsert(ifs, bl_pinsin, 1+1+ db.state_bitsize*2,1,curr_pos)

        i=i+1
      end
    end
  end
  blinsert(c,thens,1,1,1)
  blinsert(c,ifs, 1+db.state_bitsize*2,1,1)
  blinsert(c,bl_register(cumulative_state), 1, 1, (i-1)*3+1 )

  blinsert(c,bl_bend_bundle_from_down_to_right_step2(db.state_bitsize),1,1,(i-1)*3+1 +2) 
  blinsert(c,bl_t_bundle_to_down_step2_and_connections(db.state_bitsize),
    db.state_bitsize*2,1,(i-1)*3+1 )


  local posy = (i-1)*3+1 +2
  local posx = 2*2*db.state_bitsize + 2 
  blinsert(c,bl_bundle_horisontal(db.state_bitsize,2*#db.inputs_used),posx,1,posy)
  return c
end


function pins_to_value(lpins,defined_output_pins)
  local hpins = list_to_hash(lpins)
  local v = ""
  for _,p in ipairs(defined_output_pins) do
    if hpins[p] ~= nil then 
      if not is_negated(p) then
        v = v .. "1"
      else
        v = v .. "0"
      end
    else
      v=v.."0"
    end
  end
  return v
end


function generate_output_ifstate_thenpins(db)
  local c = new_circ()
  local defined_pins = db.outputs_used

  -- computing output state
  local cumulative_state = string.rep("0", #defined_pins)
  for state,out_pins in pairs(db.outputs) do
    local value = db.state_values[state]
    if value ~= nil then
      if is_all_zeros(value) then
        cumulative_state = pins_to_value(out_pins,defined_pins  )
      end
    end
  end

-- generating 
  local ifs = new_circ()
  local thens = new_circ()
  local nots = new_circ()
  local i = 1
  for state,out_pins in pairs(db.outputs) do
    local value = db.state_values[state]
    if value == nil then return new_circ() end --aborting all, no states

    local pinso = pins_to_value(out_pins,defined_pins)

    local if_state_state
    if is_all_zeros(value) then
      if_state = "off"
    else
      if_state = "on"
    end

    local bl_state = bl_state_value_in(value,if_state)
    local bl_stateout = bl_state_value_out(pinso,inverse_state(if_state), cumulative_state)

    -- putting all together
    local curr_pos = (i-1)*3+1
    blinsert(ifs,bl_state,1,1,curr_pos)
    blinsert(nots, gnode_to_circ(g_gate_not(inverse_state(if_state) ,"right")),
      1,1,curr_pos+2)

    blinsert(thens, bl_stateout, 1,1,curr_pos)
    i=i+1

  end

  blinsert(c,ifs,1,1,1)
  blinsert(c,nots, db.state_bitsize*2+1,1,1)
  blinsert(c,thens,db.state_bitsize*2+2,1,1)
  if count_hash(db.outputs) ~= 0 then
    blinsert(c,bl_t_bundle_to_down_step2_and_down_conn(db.state_bitsize),
      1,1,(i-1)*3+1 )
  end

  return c

end

-----------------------------------------------------------------

function fill_with_air(c)
  if c == nil then return nil end
  local sx = c.nodes.sx
  local sy = c.nodes.sy
  local sz = c.nodes.sz

  for ix=1,sx do
    for iy=1,sy do
      for iz=1,sz do
        if m3_get(c.nodes,ix,iy,iz) == nil then 
          m3_set(c.nodes,ix,iy,iz, {name="air",param2=0})
        end
      end
    end
  end
  -- do I have to fill meta too?
end




function fsmgenerate_raw(db)
  local ifth  = generate_ifthens(db)
  local ifout = generate_output_ifstate_thenpins(db)
  local c = new_circ()

  local hsize = ifth.nodes.sx
  local vsize = ifth.nodes.sz

  local hsize2 = ifout.nodes.sx
  local vsize2 = ifout.nodes.sz

  local max = math.max(vsize,vsize2)


  blinsert(c,ifth,1,1,max+1-vsize)
  blinsert(c,ifout,hsize+2,1,max-vsize2+1 )

  blinsert(c,bl_bundle_horisontal(db.state_bitsize,1),
    1+ifth.nodes.sx,1, max+1-db.state_bitsize)

  fill_with_air(c)
  return c
end

function generate_circuit(bin,options)
  return  fsmgenerate_raw(bin)
end
