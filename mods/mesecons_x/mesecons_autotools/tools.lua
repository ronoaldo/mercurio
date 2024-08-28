-- Common functions
-- a bit of a weld (TODO: fix that)
function is_circuit_element(pos)
    local node = minetest.get_node(pos)
    local name = node.name
    
    local m = string.match(name,"^mesecons_")
    if m ~= nil then 
        return true
    end
    
    m = string.match(name,"^mesecons:")
    if m ~= nil then 
        return true
    end
    
    if name == "default:mese" then 
            return true
    end
    
    
    return false
end




-- Register all tools and callbacks


dofile(minetest.get_modpath("mesecons_autotools").."/tools/selection.lua");
dofile(minetest.get_modpath("mesecons_autotools").."/tools/direction.lua");
dofile(minetest.get_modpath("mesecons_autotools").."/tools/wire.lua");
dofile(minetest.get_modpath("mesecons_autotools").."/tools/bundle.lua");





local tool_list = { 
        {"black", "Auto Wire Tool"},
        {"grey", "Auto crossing Tool"},
        {"blue",  "Selection Tool"},
        {"white_up", "Selection Top Edge Tool"},
        {"white_down", "Selection Bottom Edge Tool"},
        {"white", "Selection Right Edge Tool"},
        {"orange", "Stack Right Tool"},
        {"orange_up", "Stack Up Tool"},
        {"red", "Delete Tool"},
        {"yellow", "Move Horizontal Tool"},
        {"yellow_updown", "Move Vertical Tool"},                        
        {"refresh", "Refresh Tool"},
        
        }
for _,t in pairs(tool_list) do 
        local tool = t[1]
        local description = t[2]

        minetest.register_tool("mesecons_autotools:" .. tool , {
            description = description,
            inventory_image = tool .. ".png",
            stack_max = 1,
            groups = { tool =1  },

            on_use = function(itemstack, player, pointed_thing) 
                local pos = pointed_thing.under
                local player_pos = vector.round(player:get_pos())
                local player_name = player:get_player_name()
                local rad = player:get_look_horizontal()
                
                if pointed_thing.type == "node" then
                        if (is_circuit_element(pos)) then
                                pos = pointed_thing.under
                                mesecons_autotools.execute_action(tool,"left","block", player_name, pos, rad, pointed_thing.under);
                        else
                                pos = pointed_thing.above
                                mesecons_autotools.execute_action(tool,"left","block", player_name, pos, rad, pointed_thing.under);
                        end
                        
                elseif pointed_thing.type == "nothing" then
                        if (is_circuit_element(player_pos)) then
                                pos = pointed_thing.under
                                mesecons_autotools.execute_action(tool,"left","air", player_name, player_pos, rad);
                        else
                                pos = pointed_thing.above
                                mesecons_autotools.execute_action(tool,"left","air", player_name, player_pos, rad);
                        end
                end
            
           end,
                    
           on_place = function(itemstack, player, pointed_thing)
                local pos = pointed_thing.under
                local player_pos = vector.round(player:get_pos())
                local player_name = player:get_player_name()
                local rad = player:get_look_horizontal()
                
                if pointed_thing.type == "node" then
                        if (is_circuit_element(pos)) then
                                pos = pointed_thing.under
                                mesecons_autotools.execute_action(tool,"right","block", player_name, pos, rad, pointed_thing.under);
                        else
                                pos = pointed_thing.above
                                mesecons_autotools.execute_action(tool,"right","block", player_name, pos, rad, pointed_thing.under);
                        end
                end

                
            end,
            on_secondary_use = function(itemstack, player, pointed_thing)
                local pos = pointed_thing.under
                local player_pos = vector.round(player:get_pos())
                local player_name = player:get_player_name()
                local rad = player:get_look_horizontal()
                
                if pointed_thing.type == "nothing" then
                        if (is_circuit_element(player_pos)) then
                                pos = pointed_thing.under
                                mesecons_autotools.execute_action(tool,"right","air", player_name, player_pos, rad);
                        else
                                pos = pointed_thing.above
                                mesecons_autotools.execute_action(tool,"right","air", player_name, player_pos, rad);
                        end
                
                end       
                
            end      
            

        })



        -- Implementations
        dofile(minetest.get_modpath("mesecons_autotools").."/tools/" .. tool .. "/".. tool .. ".lua");

end
