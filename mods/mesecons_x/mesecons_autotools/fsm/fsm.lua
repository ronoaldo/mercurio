dofile(minetest.get_modpath("mesecons_autotools").."/fsm/lib.lua");
dofile(minetest.get_modpath("mesecons_autotools").."/fsm/alg.lua");
dofile(minetest.get_modpath("mesecons_autotools").."/fsm/compiler.lua");
dofile(minetest.get_modpath("mesecons_autotools").."/fsm/generate.lua");
dofile(minetest.get_modpath("mesecons_autotools").."/fsm/priority.lua");

local  esc = minetest.formspec_escape

function get_stats_string(data)
  if data == nil then return "<no circuit>" end
  if data.circ == nil then return "<no circuit>" end
  if data.circ.nodes == nil then return "<no circuit>" end

  local nodes = data.circ.nodes
  local stats = "<no circuit>"
  local block, gate, wire
  local sx,xy,sz

  block, gate, wire = get_stats(nodes)    
  sx = nodes.sx
  sy = nodes.sy
  sz = nodes.sz

  stats = "size : " .. sx .. "x"..sy .. "x"..sz .. "(=".. sx*sy*sz .. ")\n" ..
  "wires : " .. wire .. "\n" ..
  "gates : " .. gate .. "\n" ..
  "others : ".. block - wire - gate .. "\n" .. 
  "blocks: " .. block
  return stats
end


local function get_fromspec_help()
  local formspec = 

  "formspec_version[3]".. 

  "size[32,25]"..    
  "style_type[textarea;font=mono]" .. 

  "label[15,0.7;FSM generator]".. 
  --"label[20,0.7;" .. file .. "]" ..


  ""
  return formspec
end


local function get_formspec(data)
  local code = minetest.formspec_escape(data.code or "")
  local name = minetest.formspec_escape(data.name or "")
  local log = minetest.formspec_escape(data.log or "")

  local stats_string = get_stats_string(data)

  local create_button = ""
  if data.circ ~= nil then 
    if data.circ.nodes ~= nil then
      create_button =    "image[27.5,23;1,1;circuit_full.png]" ..
      "button[28.5,23;3,1;create;" .. "Create" .. "]" 
    end
  end



  local formspec = 
  "formspec_version[3]".. 

  "size[32,25]"..    
  "style_type[textarea;font=mono]" .. 

  "style[question;fgimg=question.png;fgimg_hovered=question_hovered.png;border=false]" ..
  "image_button[30.8,0.2;1,1;;question;]" ..


  "label[15,0.7;FSM generator]".. 
  --"label[20,0.7;" .. file .. "]" ..
  "field[0.5,2;15,1;name;Name;" .. name .. "]"..
  "textarea[0.5,4;15,15;code;" .. "Code:;" .. code ..  "]" ..
  "textarea[16.5,2;15,17;;" .. "Compilation Logs:" .. ";" .. log .. "]" ..
  "button[0.5,19;3,1;save;" .. "Save" .. "]" .. 
  "button[14.5,20;3,1;compile;" .. "Compile" .. "]" ..


  "textarea[23.5,21;8,5;;Circuit Parameters;" .. esc(stats_string) .. "]" ..


  "label[0.5,21;Generation Options:]" ..
  "label[1,22;Circuit Type:]" .. 
  "dropdown[4,21.5;5,1;type;flat_raw;1]" ..

  create_button .. 

  ""
  return formspec
end

local help = [==[


[General Info]
This is a Moore State Machine generator.

Each state has a name, built out of the letters (A-Z,a-Z), numbers (0-9), and underscore. Name must begin with a letter.

Each pin has a name, built out of the letters (A-Z,a-Z), numbers (0-9), and underscore. Name must begin with a letter.

[Comments]
Line that begins with ';' is a comment. White characters at the beginning are ignored.

[Init State]
Init state is declared with double square bracket '[[' and ']]'. Eg. [[init]], [[init_state]]
You must have exacly one init state.

You dont have to declare states, just use them in transitions or outputs declarations.

[Transitions]
Transitions have the following form:
 [list_of_states] list_of_pins -> [state]
where 
 'list_of_states' is a list of input state names separated by space, list must contain at least one state
 'list_of_pins' is a list of pin names separated by space, list can be empty
 'state' is output state, ie. next transition state

Eg. 
 [a] -> [b]
 [a b] -> [c]
 [a] pin1 ~pin2 -> [c]

Pins can be negated by ~. If there is no pin on the list, the value of the pin is not considered. [a] -> [b] means go from state 'a' to 'b' no matter what input pins are. [a] p1 -> [b] means, if in state 'a' and inputs pins have the following values: p1='1' and rest input pins have any value, then go to state 'b'. [a] ~p1 -> [b] means, if in state 'a' and pin 'p1' is '0', then go to state 'b' (we dont care about other input pins). [a] p1 ~p2 -> [b] means, if in state 'a' and p1='1' and p2='0' and we dont care about rest pins, then go to state 'b'.

Transition [a b] p1 -> [c] is equivalent to:
 [a] p1 -> [c]
 [b] p1 -> [c]

There must be at least one transition. 

[Priority]
Transitions declared first, have highter priority. If there is more than one transition, that satisfies pin conditions,  only the first one would be applied. 

Eg.

[a] -> [b]
[a] -> [c]

meas, FSM would go to state 'b'.

Eg. Consider the following situation:

[a] p1 p2 -> [b]
[a] p1 p3 -> [c]

and pins are (p1,p2,p3)=(1,1,1). Both transitions apply, but because [a] p1 p2 -> [b] is declared first, only this one would be applied, and FSM would transition to sate 'b'.

[Defalut Loop Transition]
Each state has automatically added self loop transition:
[state] -> [state]
This means, that if any of your conditions do not apply, the FSM stays in the same state.

Eg. 
[a] pin -> [b]

is equivalent to:

[a] pin -> [b]
[a] -> [a]
[b] -> [b]
meaning, if in state 'a' and pin=0 then FSM stays in state 'a'. If in state 'b', stay in state 'b'.

[Outputs]
Output values are declared as follows:
 [list_of_states] list_of_pins
If a pin is on the list, the value is '1'. If the pin is not on the list, the value of this pin is '0'.

Eg.
 [a] pin1 pin2
 [a b c] pin_light
Eg.
 [a] p1 
means that when the FSM is in the state 'a' then the output pin 'p1' would have value '1', and the rest of the output pins would have the value '0'.
Not declared states would automatically have output pins set to '0'.


[Fixing Input/Output Order]
Declaring input/output pins order is optional. You can declare only 'in:', only 'out:', both, or none. If you dont specify input/output pins order, then they are generated automatically, and showed on compilation logs. Syntax is:

in: list_of_pins
out: list_of_pins

where 'list_of_pins' is a list of pins separated by space.

Eg.
in: a b d
out: x y z

[State Groups]
You can declare state groups as follows:

@group_name = list_of_states

Eg.
@all = state1 state2 state3
@gr1 = state1 state2
@gr2 = state3 state4 state5
@allgrs = @gr1 @gr2 super_state

You use state group as normal state, but only where multiple states are allowed.

[@all] pin1 ~pin2 -> [state]
[@all another_state] out1 out2

Eg.
@gr = s1 s2
[@gr] -> [b]

is equivalent to:

[s1 s2] -> [b]

which is the same as:
[s1] -> [b]
[s2] -> [b]


[Pin Groups]
You can declare pin groups as follows:

#pins = pin1 pin2 ~pin4

and use them as normal pins. You cannot negate it though. 

[a] #pins some_pin -> [b]
[b] out1 out2 #pins

Eg.
#pins = p1 ~p2
[a] #pins p3 -> [b]

is the same as:

[a] p1 ~p2 p3 -> [b]


]==]
local function get_formspec_help()
  local formspec = 
  "formspec_version[3]".. 

  "size[32,25]"..    
  "style_type[textarea;font=mono]" .. 

  "style[question;fgimg=question.png;fgimg_hovered=question_hovered.png;border=false]" ..
  "style[exit;fgimg=cancel.png;fgimg_hovered=cancel.png;border=false]" ..
  "image[0.2,0.2;1,1;question.png]" ..
  "image_button_exit[30.8,0.2;1,1;;exit;]"  ..
  "textarea[1,2;30,22;;;" .. esc(help) .. "]" .. 
  ""
  return formspec
end


function on_place_fsm_book(itemstack, player, pointed_thing)
  local user = player:get_player_name()
  local rad = player:get_look_horizontal()
  local direction = radians_to_direction_looking_forward(rad)
  local fields = itemstack:get_meta():to_table().fields
  local file = fields.file

  if not mesecons_autotools.is_full_selection(user) then return nil end
  local  pos1 = mesecons_autotools.get_pos(user,1)
  local  pos2 = mesecons_autotools.get_pos(user,2)
  local sel = {pos1=pos1,pos2=pos2}

  local data = read_table_from_file(file)
  if data.circ == nil then return end
  local circ = data.circ


  paste_circuit_from_table(sel,circ,direction) 
end


local function show_dialog_fsm(player,itemstack)
  local user = player:get_player_name()
  local fields = itemstack:get_meta():to_table().fields
  local file = fields.file
  local stack = player:get_wielded_item()  
  local db = {}
  local data = {}

  if file == nil then
    file = generate_file_name_fsm(user)
    fields.file = file
    stack:get_meta():from_table({ fields = fields})
    player:set_wielded_item(stack)

    data.code = ""
    data.name = ""
    data.log = ""
    save_table_to_file(file,data)
  else
    data  = read_table_from_file(file)
    if data == nil then data = {} end
  end

  local formspec = get_formspec(data)

  minetest.show_formspec(user, "mesecons_autotools:fsm_show", formspec)
end


function fsm_make_selection(user,file,direction,pos)
  if file == nil then return end

  local data  = read_table_from_file(file)
  if data.circ == nil then return end
  local nodes = data.circ.nodes

  if nodes == nil then return end

  local sx = nodes.sx
  local sy = nodes.sy
  local sz = nodes.sz

  local pos2 = make_pos2(pos,direction,sx,sy,sz)

  -- Updatecd 
  mesecons_autotools.set_pos(user,1,pos)
  mesecons_autotools.set_pos(user,2,pos2)
  mesecons_autotools.render(user)
  mesecons_autotools.zero_stack_counter(user)
  mesecons_autotools.zero_stack_direction(user)  
end


local function on_use_fsm_book(itemstack, player, pointed_thing)
  local user = player:get_player_name()
  local data = itemstack:get_meta():to_table().fields
  local rad = player:get_look_horizontal()
  local direction = radians_to_direction_looking_forward(rad)
  local file = data.file
--  local stack = player:get_wielded_item()  

  if( pointed_thing.type == "node" ) then 
    fsm_make_selection(user,file,direction,pointed_thing.above)   
  else
    show_dialog_fsm(player,itemstack)     
  end

  return nil 
end

minetest.register_on_player_receive_fields(function(player, formname, fields)
    if formname ~= "mesecons_autotools:fsm_show" then return end   
    local user = player:get_player_name()                
    local stack = player:get_wielded_item()
    local ffields = stack:get_meta():to_table().fields

    if( fields.question ) then
      local fs = get_formspec_help()
      minetest.show_formspec(user, "mesecons_autotools:fsm_show", fs) 
      return
    end



    local data = {}
    local file = ffields.file

    if file == nil then
      file = generate_file_name_fsm(user)
      ffields.file = file
      data.name =""
      data.code =""
      data.log =""

      save_table_to_file(file,data) -- just to generate file
    else
      data  = read_table_from_file(file)
      if data == nil then data = {} end
    end

    data.name = fields.name or ""
    data.code = fields.code or ""


    if (fields.save) or fields.key_enter_field == "name" then 
      ffields.description = data.name
      stack:get_meta():from_table({ fields = ffields})
      player:set_wielded_item(stack)
      save_table_to_file(file,data) 

    elseif fields.compile then
      ffields.description = data.name
      stack:get_meta():from_table({ fields = ffields})
      player:set_wielded_item(stack)


      -- saving code before compiling 
      -- (just in case the game crashes during compilation)
      data.log = "\ngame crashed?\nkeep the code and report bug :)"
      save_table_to_file(file,data)

      --compilation area


      local bin,err  = compile_code(data.code)
      if bin == nil then
        data.log = err
        data.circ = nil
      else
        local circ = generate_circuit(bin,{})
        data.circ = circ
        data.log = err
      end

      --end of copmilation area

      save_table_to_file(file,data)

      local formspec = get_formspec(data)
      minetest.show_formspec(user, "mesecons_autotools:fsm_show", formspec)

    elseif fields.create then
      if data.circ == nil then return end
      if data.circ.nodes == nil then return end

      -- create file
      local blue  = {}
      blue.nodes = data.circ.nodes
      blue.metas = data.circ.metas
      blue.title = data.name
      blue.text = ""
      blue.direction = {x=0,y=0,z=1}

      -- save file

      local blue_file  = generate_file_name(user)
      save_table_to_file(blue_file,blue)

      -- create item in inventory

      local new_stack = ItemStack("mesecons_autotools:circuit_full")
      local b  = {}
      b.file = blue_file             
      b.description = blue.title
      new_stack:get_meta():from_table({ fields = b})

      local inv = player:get_inventory()
      if inv:room_for_item("main", new_stack) then
        inv:add_item("main", new_stack)
      else
        minetest.add_item(player:get_pos(), new_stack)
      end
    end


  end)

minetest.register_tool("mesecons_autotools:fsm", {
    description = "FSM generator",
    inventory_image = "fsm_book.png",                                
    stack_max = 1,

    on_use = on_use_fsm_book,
    on_place = on_place_fsm_book,
    on_secondary_use = none,                

  })
