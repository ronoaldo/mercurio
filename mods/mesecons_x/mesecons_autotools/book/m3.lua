

function m3_get(m,x,y,z)
        if m == nil then return nil end
        if m[x] == nil then return nil end
        if m[x][y] == nil then return nil end
        if m[x][y][z] == nil then return nil end
        return m[x][y][z]
end

function m3_set(m,x,y,z,value)
        if m == nil then m = {} end
        if m[x] == nil then m[x] = {} end
        if m[x][y] == nil then m[x][y] = {} end
        if m[x][y][z] == nil then m[x][y][z] = {} end
        m[x][y][z] = value
end
--[[
function m3_set_pos(m,pos1,pos2)
        m.pos1 = pos1
        m.pos2 = pos2
end
]]--

function m3_flip_xy(m)
        local new_m = {}
        for ix=1,m.sx do
                for iz=1,m.sz do
                        for iy=1,m.sy do
                                m3_set(new_m,iz,iy,ix, m3_get(m,ix,iy,iz))
                        end
                end
        end
 --[[       
        -- Rotate node
        for ix=1,m.sx do
                for iz=1,m.sz do
                        for iy=1,m.sy do                                
                                local node = m3_get(m,ix,iy,iz)
                                
                                local rotated_node = 
                                        rotate_node_to_direction(node,{x=1,y=0,z=0})
                                m3_set(m,ix,iy,iz,rotated_node)
                        end
                end
        end        
 ]]--       
        new_m.sx = m.sz
        new_m.sz = m.sx
        new_m.sy = m.sy
        return new_m
end

function m3_flip_x(m)
        local new_m = {}
        for ix=1,m.sx do
                for iz=1,m.sz do
                        for iy=1,m.sy do
                                m3_set(new_m,ix,iy,m.sz-iz+1, m3_get(m,ix,iy,iz))
                        end
                end
        end
        
   --[[     
        for ix=1,m.sx do
                for iz=1,m.sz do
                        for iy=1,m.sy do                                
                                local node = m3_get(m,ix,iy,iz)
                                
                                local rotated_node = 
                                        rotate_node_to_direction(node,{x=0,y=0,z=-1})
                                m3_set(m,ix,iy,iz,rotated_node)
                        end
                end
        end        
        
]]--
        new_m.sx = m.sx
        new_m.sz = m.sz
        new_m.sy = m.sy
        return new_m        
end


function m3_rotate90(m)
        return m3_flip_x( m3_flip_xy (m))
end

function m3_rotate180(m)
        return m3_rotate90(m3_rotate90(m))
end

function m3_rotate270(m)
        return m3_rotate90(m3_rotate90(m3_rotate90(m)))
end

function rotate_m3(m,direction)
        
        if direction.x == 1 then
                return m3_rotate270(m)
        end
        if direction.x == -1 then
                return m3_rotate90(m)
        end
        if direction.z == 1 then 
                return m
        end
        if direction.z == -1 then
                return m3_rotate180(m)
        end
        return m
end



function m3_move_to_000(m)
        local new_m = {}
        
        local pos1 = m.pos1
        local pos2 = m.pos2
        
        local xmin = math.min(pos1.x,pos2.x)
        local ymin = math.min(pos1.y,pos2.y)
        local zmin = math.min(pos1.z,pos2.z)
        
        local xmax = math.max(pos1.x,pos2.x)
        local ymax = math.max(pos1.y,pos2.y)
        local zmax = math.max(pos1.z,pos2.z)
        
        
        
        local sx = xmax - xmin + 1
        local sy = ymax - ymin + 1
        local sz = zmax - zmin + 1
        
        for x=1,sx,1 do 
                for y=1,sy,1 do
                        for z=1,sz,1 do
                                m3_set(new_m,x,y,z, 
                                        m3_get(m, x-1 + xmin, y-1 + ymin, z-1+zmin))
                        end
                end
        end
        
        new_m.sx = sx
        new_m.sy = sy
        new_m.sz = sz
        return new_m
end





function selection_to_m3(pos1,pos2,direction)
        local m = {}
        iterate_selection(pos1,pos2,function(pos)
                        local node = minetest.get_node(pos)
                        m3_set(m,pos.x,pos.y,pos.z,node)
                end)
        m.pos1 = pos1
        m.pos2 = pos2
                
        m = m3_move_to_000(m)
        
        m = rotate_m3(m,direction)
        
        for ix=1,m.sx do
                for iz=1,m.sz do
                        for iy=m.sy,1,-1 do                                
                                local node = m3_get(m,ix,iy,iz)
                                local rotated_node = rotate_node_to_direction(node,direction)
                                m3_set(m,ix,iy,iz,rotated_node)
                        end
                end
        end        
        
        
        
        return m
end

function selection_to_m3_meta(pos1,pos2,direction)
        local m = {}
        iterate_selection(pos1,pos2,function(pos)
			local meta = minetest.get_meta(pos):to_table()
                        m3_set(m,pos.x,pos.y,pos.z,meta)
                end)
        m.pos1 = pos1
        m.pos2 = pos2
                
        m = m3_move_to_000(m)
        
        m = rotate_m3(m,direction)
        return m
end



function m3_to_mx(m)
        local mx={}
        for ix=1,m.sx do
                for iz=1,m.sz do
                        for iy=m.sy,1,-1 do
                                local pos = { x = ix, y=iy, z = iz }
                                local node = m3_get(m,ix,iy,iz)
                                
                                if node.name ~= "air" then 
                                        mx_set(mx,ix,iz,node)
                                        break
                                end

                        end
                end
        end        
        mx.w = m.sx
        mx.h = m.sz
        return mx
end


local function lmin(a,b)
        if a == nil then                
                return b
        else
                if b == nil then
                        return a
                else
                        return math.min(a,b)
                end
        end
end
local function lmax(a,b)
        if a == nil then                
                return b
        else
                if b == nil then
                        return a
                else
                        return math.max(a,b)
                end
        end
end

function list_to_m3(list)
        local m = {}
        
        local xmin,xmax,ymin,ymax,zmin,zmax
        
        for _,v in pairs(list) do
                local pos = v.pos
                local node = v.node
                
                m3_set(m,pos.x,pos.y,pos.z, node)
                
                xmin = lmin(xmin, pos.x)
                ymin = lmin(ymin, pos.y)
                zmin = lmin(zmin, pos.z)
                
                xmax = lmax(xmax, pos.x)
                ymax = lmax(ymax, pos.y)
                zmax = lmax(zmax, pos.z)
                
                
        end
        
        m.pos1 = {x=xmin,y=ymin,z=zmin}
        m.pos2 = {x=xmax,y=ymax,z=zmax}
        return m
end


function iterate_m3(m,action)
        for x=1,m.sx do
                for y=1,m.sy do
                        for z=1,m.sz do
                                action(m3_get(m,x,y,z))
                        end
                end
        end
end

        
function m3_insert(mbase, melement, x,y,z)
  local sx = melement.sx
  local sy = melement.sy
  local sz = melement.sz
  
  for xi=1,sx do
    for yi=1,sy do
      for zi=1,sz do
        if m3_get(melement,xi,yi,zi) ~= nil then 
          m3_set(mbase,x+xi-1,y+yi-1,z+zi-1, m3_get(melement,xi,yi,zi))
        end
      end
    end
  end
  mbase.sx = math.max(mbase.sx, x+sx-1)
  mbase.sy = math.max(mbase.sy, y+sy-1)
  mbase.sz = math.max(mbase.sz, z+sz-1)
end





