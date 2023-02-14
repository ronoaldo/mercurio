local cores={
{"preto","#00000070"},
{"branco","#FFFFFF70"},
{"vermelho","#AA000070"},
{"azul","#0000AA70"},
{"verde","#00ff0070"},
{"amarelo","#ffff0070"},
{"rosa","#ff65b570"},
{"violeta","#9400d370"},
{"laranja","#ff7f0070"},
{"ouro","#FFAA0070"},
{"purpura","#5500FF70"},
{"dark_grey","#464E5170"},
{"indigo", "#4b008270"},
}

for i = 1, #cores, 1 do
minetest.register_node("school_furniture:school_cabinet_"..cores[i][1], {
	description = ("school_cabinet_"..cores[i][1]),
	paramtype = "light",
	use_texture_alpha ="clip",
    paramtype2 = "facedir",
	sunlight_propagates = true,
	drawtype = "mesh",
	mesh = "school_cabinet.obj",
	tiles= {"(school_cabinet.png^[multiply:"..cores[i][2]..")^school_cabinet_detalhe.png",},
	groups = {cracky = 2, oddly_breakable_by_hand = 2, soil = 1,},
	node_box = 	{ type = "fixed",fixed = {-0.5, -0.5, -0.5, 0.5, 1.5, 0.5}},
    selection_box = {type = "fixed",fixed = {-0.5, -0.5, -0.5, 0.5, 1.5, 0.5}},

on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		meta:set_string("formspec",
				"size[8,9]"..
				"list[current_name;main;3,2;2,2;]"..
				"list[current_player;main;0,5;8,4;]" ..
				"listring[]")

		meta:set_string("owner", "")
		local inv = meta:get_inventory()
		inv:set_size("main", 8*4)
	end,
after_place_node = function(pos, placer)
			local meta = minetest.get_meta(pos)
			meta:set_string("owner", placer:get_player_name())
			meta:set_string("infotext","school_cabinet: "..placer:get_player_name() or "")
		end,

can_dig = function(pos,player)
		local meta = minetest.get_meta(pos);
		local inv = meta:get_inventory()
		return inv:is_empty("main")
	end
})

end
