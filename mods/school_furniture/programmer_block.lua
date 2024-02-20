minetest.register_node("school_furniture:programmer_block",{
	description = "programmer_block",
	tiles = {"programmer_block.png"},
	paramtype = "light",
	drawtype = "nodebox",
	use_texture_alpha = "clip",
	is_ground_content = false,
	sunlight_propagates = true,
	groups = {cracky = 3, oddly_breakable_by_hand = 3,not_in_creative_inventory=0},
	after_place_node = function(pos,placer, formname, fields,jogador)
		jogador=placer:get_player_name()
		local meta = minetest.get_meta(pos)
		meta:set_string("owner",placer:get_player_name() or "")

		meta:set_string("infotext","By Programmer: "..jogador)
		local esc = minetest.formspec_escape
		meta:set_string("formspec","size[10.5,11]"..
						"textarea[0.9,0.9;8.6,9.1;text;"..jogador..";${text}]".."button_exit[6.8,10.2;2.6,0.7;salvar;salva]")
	end,

	on_receive_fields = function(pos, formname, fields, sender)
		local meta = minetest.get_meta(pos)
		local player_name = sender:get_player_name()
		if player_name~= meta:get_string("owner") then minetest.chat_send_player(player_name,"Bloqueador por "..player_name) return end
		local text = fields.text  if not text then return end
		if string.len(text) > 512 then minetest.chat_send_player(player_name, ("Text over limit")) return end
		local meta = minetest.get_meta(pos)
		meta:set_string("text", text)
		if #text > 0 then
			meta:set_string("texto", ( text))
		else
			meta:set_string("texto", ( text))

		end
	end,

	can_dig = function(pos,player)
			local meta = minetest.get_meta(pos)
			local inv = meta:get_inventory()
			local inv2 = meta:get_inventory()
			local player_name = player:get_player_name()
			if player_name~= meta:get_string("owner") then
				minetest.chat_send_player(player_name,"This block is protected".." by: "..meta:get_string("owner"))
			return end
			return true
	end,
})
minetest.register_craft({output ="school_furniture:programmer_block 1",
	recipe = {{"default:wood","default:stone","default:wood"},
              {"default:wood","default:steel_ingot","default:wood"},
              {"default:wood","default:wood","default:wood"},}
})
