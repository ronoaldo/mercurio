
mesecons_autotools.register_action("test","left","air", function(user,pos,rad) 

  end)
mesecons_autotools.register_action("test","left","block", function(user,pos,rad) 
    local node = minetest.get_node(pos)
    -- print ("rules[" .. dump(mesecon.get_any_rules(node)) .. "]" )
    print("node=" .. dump(minetest.get_node(pos) ))
      print("meta=" ..dump(minetest.get_meta(pos):to_table() )  )
      end)

    mesecons_autotools.register_action("test","right","block", function(user,pos,rad) 

      end)

    mesecons_autotools.register_action("test","right","air", function(user,pos,rad) 
        local pos1 = mesecons_autotools.get_pos(user,1)
        local pos2 = mesecons_autotools.get_pos(user,2)

        print ("D=pos1="..dump(pos1) .. ", pos2="..dump(pos2))
      end)



