
local cores={
{"preto","#1B1B1B70","default:coal_lump","default:coal_lump"},
{"branco","#FFFFFF70","flowers:dandelion_white","flowers:dandelion_white"},
{"vermelho","#AA000070","flowers:rose","flowers:rose"},
{"azul","#0000AA70","flowers:geranium","flowers:geranium"},
{"verde","#00ff0070","default:cactus","default:cactus"},
{"amarelo","#ffff0070","flowers:dandelion_yellow","flowers:dandelion_yellow"},
{"rosa","#ff65b570","default:coral_pink","default:coral_pink"},
{"violeta","#9400d370","flowers:viola","flowers:viola"},
{"laranja","#ff7f0070","flowers:tulip","flowers:tulip"},
{"ouro","#FFAA0070","flowers:dandelion_yellow","flowers:tulip"},
{"purpura","#5500FF70","default:coral_pink","flowers:viola"},
{"dark_grey","#464E5170","default:coal_lump","flowers:dandelion_white"},
{"indigo", "#4b008270","default:coral_cyan","default:coral_cyan"},
}

minetest.register_node("school_furniture:colored_hands",{
    description = ("colored_hands"),
    tiles = {"colored_hands.png"},
    drawtype ="signlike",
    paramtype ="light",
    walkable=false,
    is_ground_content = false,
    paramtype2 = "wallmounted",
    selection_box = {type = "wallmounted", },
    groups = {snappy = 3, flammable = 2, leaves = 1, hedge = 1},
}) 

minetest.register_craft({output = "school_furniture:colored_hands 9",
	recipe = {{"default:paper","default:paper","default:paper",},
              {"default:paper","flowers:dandelion_white","default:paper",},
              {"default:paper","default:paper","default:paper",},},})



for i = 1, #cores, 1 do
    minetest.register_node("school_furniture:colored_hands"..cores[i][1],{
    description = ("colored_hands"..cores[i][1]),
	--wield_image = {"colored_hands.png^[multiply:"..cores[i][2]},
    tiles = {"colored_hands.png^[multiply:"..cores[i][2]},
    drawtype ="signlike",
    paramtype ="light",
    walkable=false,
    is_ground_content = false,
    paramtype2 = "wallmounted",
    selection_box = {type = "wallmounted", },
    groups = {snappy = 3, flammable = 2, leaves = 1, hedge = 1},

})
minetest.register_craft({output = "school_furniture:colored_hands"..cores[i][1].." 4",
	recipe = {{"school_furniture:colored_hands",cores[i][3],cores[i][4]},}})

end
