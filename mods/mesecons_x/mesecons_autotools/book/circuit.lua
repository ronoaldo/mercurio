dofile(minetest.get_modpath("mesecons_autotools").."/book/mx.lua");
dofile(minetest.get_modpath("mesecons_autotools").."/book/m3.lua");

dofile(minetest.get_modpath("mesecons_autotools").."/book/formspec.lua");
dofile(minetest.get_modpath("mesecons_autotools").."/book/image.lua");

dofile(minetest.get_modpath("mesecons_autotools").."/book/misc.lua");
dofile(minetest.get_modpath("mesecons_autotools").."/book/stats.lua");

local  esc = minetest.formspec_escape




local function show_dialog_new(user,direction)
 
        local pos1 = mesecons_autotools.get_pos(user,1)
        local pos2 = mesecons_autotools.get_pos(user,2)
        local sel = {pos1=pos1,pos2=pos2}
        
        if not mesecons_autotools.is_full_selection(user) then return end        
        
        local nodes = selection_to_m3(pos1,pos2,direction)
        local view = m3_to_mx(nodes)
        
        local db = {
                title = "",
                text = "",
                nodes = nodes,
                direction = direction,
                view = view,
        }
        local formspec = fs_all(db)
        
        minetest.show_formspec(user, "mesecons_autotools:circuit_new", formspec)

end


local function show_dialog_full(user,file)
        local info = read_table_from_file(file)
        local view =  m3_to_mx(info.nodes)

        local db = {
                title = info.title,
                text = info.text,
                nodes = info.nodes,
                direction = info.direction,
                view = view,
        }

        local formspec = fs_all(db)
        minetest.show_formspec(user, "mesecons_autotools:circuit_edit", formspec)
end


minetest.register_on_player_receive_fields(function(player, formname, fields)

     if formname ~= "mesecons_autotools:circuit_new" then return end   
     
        if (fields.save) or fields.key_enter_field == "title" then

                local user = player:get_player_name()
                local file = generate_file_name(user)
                local rad = player:get_look_horizontal()                
                local direction = radians_to_direction_looking_forward(rad)
                
                local stack = player:get_wielded_item()                  
                local inv = player:get_inventory()
                
                local new_stack = nil
                local info = {}
                local data = {}
                
                if( stack:get_name() == "mesecons_autotools:circuit_empty" ) then
                        
                        new_stack = ItemStack("mesecons_autotools:circuit_full")
                        data.file = file
                        data.description = fields.title
                        new_stack:get_meta():from_table({ fields = data})
                        
                        if inv:room_for_item("main", new_stack) then
                                inv:add_item("main", new_stack)
                        else
                                minetest.add_item(player:get_pos(), new_stack)
                        end
                        
                        -- standart info
                        info.title = fields.title
                        info.text = fields.text
                        
                        -- direction
                        info.direction = direction
                        
                        --info.direction = direction
                        
                        -- selection
                        
                        local pos1 = mesecons_autotools.get_pos(user,1)
                        local pos2 = mesecons_autotools.get_pos(user,2)                        
                        local nodes = selection_to_m3(pos1,pos2,direction)

			local metas = selection_to_m3_meta(pos1,pos2,direction)
                                        
                        
                        info.nodes = nodes
			info.metas = metas
                        save_table_to_file(file,info)
                end
        end
     
end)

minetest.register_on_player_receive_fields(function(player, formname, fields)
     if formname ~= "mesecons_autotools:circuit_edit" then return end   
     
        if (fields.save) or fields.key_enter_field == "title" then
                local user = player:get_player_name()                
                local rad = player:get_look_horizontal()  
                local direction = radians_to_direction_looking_forward(rad)
                
                local stack = player:get_wielded_item()
                local data = stack:get_meta():to_table().fields
                --local inv = player:get_inventory()
                
                local info = {}
                local file = data.file
                       
                       
                info  = read_table_from_file(file)
                info.title = fields.title
                info.text = fields.text
                save_table_to_file(file,info)
                
                
                data.title = fields.title
                data.text = fields.text
                
                
                
                data.description = fields.title
                stack:get_meta():from_table({ fields = data})
                
                
                
                
                player:set_wielded_item(stack)
                
        end
end)


function rotate_direction_right(direction)
        local d = {x=0,y=0,z=0}
        if direction.z == 1 then 
                d.x = 1
        end
        if direction.x == 1 then
                d.z = -1
        end
        if direction.z == -1 then
                d.x = -1
        end
        if direction.x == -1 then
                d.z = 1
        end
        return d
end

function rotate_direction_left(direction)
    return rotate_direction_right(rotate_direction_right(rotate_direction_right(direction)))
end

function make_pos2(pos1,direction,sx,sy,sz)
        
        local right = rotate_direction_right(direction)
        
        local hv = vector.multiply(direction,sz-1)
        local vv = vector.multiply(right,sx-1)
        local uv = vector.multiply({x=0,y=1,z=0},sy-1)
        local shift = vector.add(hv, vector.add(vv,uv))
        
        local pos2 = vector.add(pos1, shift)
        
        return pos2
end

function get_all_corners_flat(sel)
        local pos = {}
        pos[1] = sel.pos1
        pos[2] = sel.pos2
        
        local xmax = math.max(pos[1].x, pos[2].x)
        local xmin = math.min(pos[1].x, pos[2].x)
        
        local ymax = math.max(pos[1].y, pos[2].y)
        local ymin = math.min(pos[1].y, pos[2].y)
        
        local zmax = math.max(pos[1].z, pos[2].z)
        local zmin = math.min(pos[1].z, pos[2].z)
        
        local pos00 = vector.new(xmin,ymin,zmin)
        local pos11 = vector.new(xmax,ymin,zmax)
        local pos10 = vector.new(xmax,ymin,zmin)
        local pos01 = vector.new(xmin,ymin,zmax)
        return {pos00=pos00,pos01=pos01,pos10=pos10,pos11=pos11}      
end



function get_corner00(sel,direction)
        local crs = get_all_corners_flat(sel)
        
        
        
        if direction.z == 1 then
                return crs.pos00
        end
        if direction.x == 1 then
                return crs.pos01
        end
        if direction.z == -1 then
                return crs.pos11
        end
        if direction.x == -1 then
                return crs.pos10
        end
        
        
end

function add_vectors(a,b,c)
        return vector.add(a,vector.add(b,c))
end




function direction_to_number(direction)
        if direction.z == 1 then return 0 end
        if direction.x == 1 then return 1 end
        if direction.z == -1 then return 2 end
        if direction.x == - 1 then return 3 end
end

function number_to_direction(nr)
        if nr == 0 then return {x=0,y=0,z=1} end
        if nr == 1 then return {x=1,y=0,z=0} end
        if nr == 2 then return {x=0,y=0,z=-1} end
        if nr == 3 then return {x=-1,y=0,z=0} end
end




function diff_directions(d1,d2)
        local p1 = direction_to_number(d1)
        local p2 = direction_to_number(d2)
        
        return number_to_direction( (p2-p1+4)%4 )
end

function flip(v)
        if v == nil then return nil end
        return vector.multiply(v,-1)
end


function paste_circuit_from_table(sel,circ,direction)
        if sel.pos1 == nil then return end
        if sel.pos2 == nil then return end
        
        
        local nodes = circ.nodes
        local metas = circ.metas        
        
        local sx = nodes.sx
        local sy = nodes.sy
        local sz = nodes.sz
        
        local right = rotate_direction_right(direction)
        
        local start_pos = get_corner00(sel,direction)

        for xi=1,sx do
                for zi=1,sz do
                        for yi=1,sy do
                                local shift= add_vectors(
                                                vector.multiply(right,xi-1),
                                                vector.multiply(direction,zi-1),
                                                vector.multiply({x=0,y=1,z=0},yi-1))
                                        
                                local pos = vector.add(start_pos, shift)
                                
                                if is_in_selection(sel,pos) then
                                
                                       local node = m3_get(nodes,xi,yi,zi)                                       if node ~= nil then
                                          local meta = m3_get(metas,xi,yi,zi)
                                          node = rotate_node(node,{x=0,y=0,z=1},direction)
                                          --minetest.set_node(pos, node)
                                          --mesecons_autotools.set_node(pos,node,"paste_circuit")
                                          minetest.set_node(pos,node)
                                          minetest.get_meta(pos):from_table(meta)
                                      end
                                      
                                end
                                
                        end
                        
                end
        end
  
end

function paste_circuit(sel,file,direction)
        if sel.pos1 == nil then return end
        if sel.pos2 == nil then return end
        
        local circ  = read_table_from_file(file)
        paste_circuit_from_table(sel,circ,direction)
        
end  
  
--[[
function paste_circuit(sel,file,direction)
        if sel.pos1 == nil then return end
        if sel.pos2 == nil then return end
        
        local info  = read_table_from_file(file)
        
        --local rotate_direction = diff_directions(direction)
        --local nodes = rotate_m3(info.nodes,direction)
        local nodes = info.nodes
        local metas = info.metas        
        
        local sx = nodes.sx
        local sy = nodes.sy
        local sz = nodes.sz
        
        local right = rotate_direction_right(direction)
        
        local start_pos = get_corner00(sel,direction)

        for xi=1,sx do
                for zi=1,sz do
                        for yi=1,sy do
                                local shift= add_vectors(
                                                vector.multiply(right,xi-1),
                                                vector.multiply(direction,zi-1),
                                                vector.multiply({x=0,y=1,z=0},yi-1))
                                        
                                local pos = vector.add(start_pos, shift)
                                
                                if is_in_selection(sel,pos) then
                                
                                        local node = m3_get(nodes,xi,yi,zi)                                
					local meta = m3_get(metas,xi,yi,zi)
                                        node = rotate_node(node,{x=0,y=0,z=1},direction)
                                        --minetest.set_node(pos, node)
                                        --mesecons_autotools.set_node(pos,node,"paste_circuit")
					minetest.set_node(pos,node)
					minetest.get_meta(pos):from_table(meta)
                                end
                                
                        end
                        
                end
        end 
end
 ]]--


local function make_selection(user,file,direction,pos)
        local info  = read_table_from_file(file)
        --local rotate_direction = diff_directions(info.direction,direction)
        local rotate_direction= info.direction
        
        local nodes = info.nodes
        local sx = nodes.sx
        local sy = nodes.sy
        local sz = nodes.sz
        
        
        local pos2 = make_pos2(pos,direction,sx,sy,sz)
        
        -- Update
        mesecons_autotools.set_pos(user,1,pos)
        mesecons_autotools.set_pos(user,2,pos2)
        mesecons_autotools.render(user)
        mesecons_autotools.zero_stack_counter(user)
        mesecons_autotools.zero_stack_direction(user)  
end

local function on_place_full_circuit(itemstack, player, pointed_thing)
        local user = player:get_player_name()
        local rad = player:get_look_horizontal()
        local direction = radians_to_direction_looking_forward(rad)
        local fields = itemstack:get_meta():to_table().fields
        local file = fields.file
                
        if not mesecons_autotools.is_full_selection(user) then return nil end
        local  pos1 = mesecons_autotools.get_pos(user,1)
        local  pos2 = mesecons_autotools.get_pos(user,2)
        local sel = {pos1=pos1,pos2=pos2}
        paste_circuit(sel,file,direction)
        
end


local function on_use_new_circuit(itemstack, player, pointed_thing)
        local user = player:get_player_name()
        local rad = player:get_look_horizontal()
        local direction = radians_to_direction_looking_forward(rad)
        
        if not mesecons_autotools.is_full_selection(user) then 
                -- show dialog with info or chat info        
                return
        end
        show_dialog_new(user,direction)
        
        return nil
end

local function on_use_full_circuit(itemstack, player, pointed_thing)
        local user = player:get_player_name()
        local rad = player:get_look_horizontal()
        local direction = radians_to_direction_looking_forward(rad)
        local fields = itemstack:get_meta():to_table().fields
        local file = fields.file
        
        
        if( pointed_thing.type == "node" ) then                
                make_selection(user,file,direction,pointed_thing.above)
        else
                show_dialog_full(user,file,player)
        end

        return nil
end

local function none(itemstack, player, pointed_thing)
        return nil
end



--minetest.register_craftitem("mesecons_autotools:circuit_empty", {
minetest.register_tool("mesecons_autotools:circuit_empty", {
                description = "Circuit Empty",
                inventory_image = "circuit_empty.png",                                
                stack_max = 1,
                
                on_use = on_use_new_circuit,
                on_place = none,
                on_secondary_use = none,                
                
        })

--minetest.register_craftitem("mesecons_autotools:circuit_full", {
minetest.register_tool("mesecons_autotools:circuit_full", {
                description = "Circuit saved",
                inventory_image = "circuit_full.png",                
                groups = {not_in_creative_inventory = 1},                
                stack_max = 1,
                on_use = on_use_full_circuit,
                on_place = on_place_full_circuit,                
                --on_secondary_use = on_place_full_circuit,
               
                
        })
