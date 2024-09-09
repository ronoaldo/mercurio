

function node_to_image(node)
        if node == nil then
                return "empty.png"
        end
        
        local name = node.name
        local param2 = node.param2 or 0
        
        
        if( name == "air" ) then
                return "empty.png"
        end
        
        
        if      (name == "mesecons_insulated:insulated_off") or 
                (name == "mesecons_insulated:insulated_on" ) then
                if( param2 % 2 == 0 ) then
                        return "wireh.png"
                else
                        return "wirev.png"
                end
        end
        
        if (name == "mesecons_extrawires:crossover_off") or 
        (name == "mesecons_extrawires:crossover_on") or
        (name == "mesecons_extrawires:crossover_01") or 
        (name == "mesecons_extrawires:crossover_10" ) then
                return "corssover.png"
        end
        
        if (name == "mesecons_extrawires:corner_off" ) or 
                (name == "mesecons_extrawires:corner_on" ) then
                        
                return "corner"..param2 .. ".png"
        end
        
        if (name == "mesecons_extrawires:tjunction_off" ) or 
           (name == "mesecons_extrawires:tjunction_on" ) then
                   
                return "tjunction"..param2 .. ".png"
        end
        
        if ( name == "mesecons_morewires:xjunction_off" ) or 
        ( name == "mesecons_morewires:xjunction_on" ) then
                return "xjunction.png"
        end
        
        
        if( name == "mesecons_regs:flipflop_off" ) or ( name == "mesecons_regs:flipflop_on") then
                return "ff"..param2..".png"
        end
        if( name == "mesecons_regs:latch_off" ) or ( name == "mesecons_regs:latch_on") then
                return "latch"..param2..".png"
        end
        
        
        if( name == "mesecons_gates:and_off" ) or ( name =="mesecons_gates:and_on" )then
                return "and".. param2 .. ".png"
        end
        if( name == "mesecons_gates:nand_off" ) or ( name =="mesecons_gates:nand_on" )then
                return "nand".. param2 .. ".png"
        end
        
        if( name == "mesecons_gates:nor_off" ) or ( name =="mesecons_gates:nor_on" )then
                return "nor".. param2 .. ".png"
        end
        if( name == "mesecons_gates:or_off" ) or ( name =="mesecons_gates:or_on" )then
                return "or".. param2 .. ".png"
        end
        if( name == "mesecons_gates:xor_off" ) or ( name =="mesecons_gates:xor_on" )then
                return "xor".. param2 .. ".png"
        end
        
        
        if( name == "mesecons_gates:diode_off" ) or ( name =="mesecons_gates:diode_on" )then
                return "diode".. param2 .. ".png"
        end
        
       if( name == "mesecons_gates:not_off" ) or ( name =="mesecons_gates:not_on" )then
                return "not".. param2 .. ".png"
        end 
       
       if( name == "mesecons_switch:mesecon_switch_off" ) or ( name =="mesecons_switch:mesecon_switch_on" )then
                return "mesecons_switch_off.png"
        end 
       
       if ( name == "mesecons_lightstone:lightstone_white_off" ) or ( name == "mesecons_lightstone:lightstone_white_on" ) then
               return "jeija_lightstone_white_on.png"
       end
       
       if (name == "mesecons_walllever:wall_lever_off" ) or  (name == "mesecons_walllever:wall_lever_on" ) then

        return "jeija_wall_lever_inv.png"
       end
        
        if (name == "default:mese" ) or (name == "mesecons_extrawires:mese_powered" )then 
                return "default_mese_block.png" 
        end
        
        if (name == "mesecons_powerplant:power_plant") then 
                return "jeija_power_plant.png"
        end
        
        
        if (name == "mesecons_gates3:and3_off") or (name == "mesecons_gates3:and3_on" ) then
                return "jeija_gate3_and3r"..param2..".png"
        end


        if (name == "mesecons_gates3:nand3_off") or (name == "mesecons_gates3:nand3_on" ) then
                return "jeija_gate3_nand3r"..param2..".png"
        end

        if (name == "mesecons_gates3:or3_off") or (name == "mesecons_gates3:or3_on" ) then
                return "jeija_gate3_or3r"..param2..".png"
        end
        
        if (name == "mesecons_gates3:nor3_off") or (name == "mesecons_gates3:nor3_on" ) then
                return "jeija_gate3_nor3r"..param2..".png"
        end
        
        return "unknown.png"
end
