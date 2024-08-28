

local function select_pos(user,pos,nr)
        mesecons_autotools.set_pos(user,nr,pos);
        
        
        -- Update
        mesecons_autotools.render(user)
        mesecons_autotools.zero_stack_counter(user)
end




mesecons_autotools.register_action("blue","left","air", function(user,pos,rad) 
        select_pos(user,pos,1)
end)
mesecons_autotools.register_action("blue","left","block", function(user,pos,rad) 
        select_pos(user,pos,1)                
end)

mesecons_autotools.register_action("blue","right","block", function(user,pos,rad) 
        select_pos(user,pos,2)
end)

mesecons_autotools.register_action("blue","right","air", function(user,pos,rad) 
        select_pos(user,pos,2)
end)

     