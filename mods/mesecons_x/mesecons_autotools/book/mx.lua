

function mx_get(m,x,y)
        if m == nil then return nil end
        if m[x] == nil then return nil end
        if m[x][y] == nil then return nil end
        return m[x][y]
end

function mx_set(m,x,y,value)
        if m == nil then m = {} end
        if m[x] == nil then m[x] = {} end
        if m[x][y] == nil then m[x][y] = {} end
        m[x][y] = value
end

function mx_flip_xy(m)
        local new_m = {}
        for i=1,m.w do
                for k=1,m.h do
                        mx_set(new_m,k,i, mx_get(m,i,k))
                end
        end
        new_m.h = m.w
        new_m.w = m.h
        return new_m        
end

function mx_flip_y(m)
        local new_m = {}
        for i=1,m.w do
                for k=1,m.h do
                        mx_set(new_m,m.w+1-i,k, mx_get(m,i,k))
                end
        end
        new_m.h = m.h
        new_m.w = m.w
        return new_m
end

function mx_flip_x(m)
        local new_m = {}
        for i=1,m.w do
                for k=1,m.h do
                        mx_set(new_m,i,m.h+1-k, mx_get(m,i,k))
                end
        end
        new_m.h = m.h
        new_m.w = m.w
        return new_m
end


function mx_rotate90(m)
        return mx_flip_x( mx_flip_xy (m))
end

function mx_rotate180(m)
        return mx_rotate90(mx_rotate90(m))
end

function mx_rotate270(m)
        return mx_rotate90(mx_rotate90(mx_rotate90(m)))
end

function rotate_mx(mx,direction)
        
        if direction.x == 1 then
                return mx_rotate270(mx)
        end
        if direction.x == -1 then
                return mx_rotate90(mx)
        end
        if direction.z == 1 then 
                return mx
        end
        if direction.z == -1 then
                return mx_rotate180(mx)
        end
        return mx
end



function move_mx_to_00(mx)
        local new_mx = {}
        
        local xmax = mx.xmax
        local xmin = mx.xmin
        
        local ymax = mx.ymax
        local ymin = mx.ymin
        
        
        local sx = xmax - xmin + 1
        local sy = ymax - ymin + 1
        
        for x=1,sx,1 do 
                for y=1,sy,1 do
                        mx_set(new_mx,x,y, mx_get(mx, x-1 + xmin, y-1 + ymin))
                end
        end
        
        new_mx.w = sx
        new_mx.h = sy
        return new_mx

end

