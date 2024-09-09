function is_gate(node)
        if node == nil then return false end
        local gates = {
                "mesecons_gates:and",
                "mesecons_gates:or",
                "mesecons_gates:xor",
                "mesecons_gates:nand",
                "mesecons_gates:nor",
                "mesecons_gates:not",
                "mesecons_gates:diode",
                "mesecons_gates3:and3",
                "mesecons_gates3:or3",
                "mesecons_gates3:nor3",
                "mesecons_gates3:nand3",
                "mesecons_regs:flipflop",
                "mesecons_regs:latch"
        }
        
        local gates_with_states = {} 
        for _,v in ipairs(gates) do
                table.insert(gates_with_states,v.."_on")
                table.insert(gates_with_states,v.."_off")
        end
        
        for _,v in ipairs(gates_with_states) do
                if node.name == v then                         
                        return true 
                end
        end
        return false
end

function is_wire_node(node)
    local list = {
        "mesecons_insulated:insulated_off", "mesecons_insulated:insulated_on",
        "mesecons_extrawires:corner_off", "mesecons_extrawires:corner_on",
        "mesecons_extrawires:tjunction_off", "mesecons_extrawires:tjunction_on",
        "mesecons_extrawires:crossover_off", "mesecons_extrawires:crossover_on",
        "mesecons_extrawires:crossover_10", "mesecons_extrawires:crossover_01",
        "mesecons_morewires:xjunction_off", "mesecons_morewires:xjunction_on",
 }

  if node == nil then return false end
    local pos_name = node.name
    for i,name in ipairs(list) do
        if name == pos_name then
            return true
        end
    end
    return false
end




function get_stats(m)
        local blocks,gates,wires = 0,0,0
        iterate_m3(m, function(node)                        
                        if node == nil then return end
                        if is_wire_node(node) then 
                                wires = wires + 1
                        end
                        if is_gate(node) then
                                gates = gates+1
                        end
                        if node.name ~= "air" then
                                blocks = blocks + 1
                        end
                        
                end)
        
        return blocks,gates,wires
        
end
