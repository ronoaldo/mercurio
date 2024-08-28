local  esc = minetest.formspec_escape

function fs_all(db)
        local info = fs_info(db.title,db.text,db)
        local stats = fs_stats(db.nodes, db.direction)
        local circuit = fs_circuit(db.view)
        
        local spec = info .. stats .. circuit
        return spec
end



function fs_info(title,text)
        local formspec = 
                "formspec_version[3]"..                
                "size[32,25]"..
                "field[0.5,1;8,1;title;".."Name"..";"..esc(title).."]"..                
                "label[15,0.7;Circuit Preview]"..
                "textarea[0.5,3;8,15;text;" .. "Description:" .. ";" ..
                        esc(text) .. "]" ..
                "button_exit[2.5,18;3,1;save;" .. "Save" .. "]"
                
        return formspec
end


function fs_circuit(mx_view)
        local W = 20
        local H = 20
        local startx = 10
        local starty = 2
        
        local imagew = W/(mx_view.w)
        local imageh = H/(mx_view.h)
        
        if imageh > 1 then imageh = 1 end
        if imagew > 1 then imagew = 1 end
        
        local minsize = math.min(imageh,imagew)
        imageh = minsize
        imagew = minsize
        
        local epsilon = 0.07
        

        local spec = ""
        for ix=1,mx_view.w do
                for iy=1,mx_view.h do
                        local n = mx_get(mx_view,ix,iy)
                        if n == nil then n = {name="air",param2=0} end                        
                        local img = node_to_image( n )
                        
                        
                        spec = spec .. "image["..
                                startx+ix*imagew .. "," ..
                                starty+(mx_view.h-iy+1)*imageh .. ";" ..
                                imagew +epsilon .. "," .. 
                                imageh +epsilon .. ";" ..
                                img .. "]"
                                
                end
        end
        
        return spec
        
end

function fs_stats(nodes,direction)         
        local block, gate, wire = get_stats(nodes)
        
        
        
        
        local sx = nodes.sx
        local sy = nodes.sy
        local sz = nodes.sz
        
        local stats = "size : " .. sx .. "x"..sy .. "x"..sz .. "(=".. sx*sy*sz .. ")\n" ..
                        "wires : " .. wire .. "\n" ..
                        "gates : " .. gate .. "\n" ..
                        "others : ".. block - wire - gate .. "\n" .. 
                        "blocks: " .. block
        local spec = "textarea[0.5,19;8,5;;;" .. esc(stats) .. "]" 
        return spec
end


