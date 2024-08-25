-- wing
minetest.register_craftitem("demoiselle:wings",{
	description = "Demoiselle wings",
	inventory_image = "demoiselle_wings.png",
})
-- fuselage
minetest.register_craftitem("demoiselle:body",{
	description = "Demoiselle body",
	inventory_image = "demoiselle_body.png",
})

-- demoiselle
--[[minetest.register_craftitem("demoiselle:demoiselle", {
	description = "Demoiselle",
	inventory_image = "demoiselle.png",
    liquids_pointable = false,]]--

minetest.register_tool("demoiselle:demoiselle", {
	description = "Demoiselle",
	inventory_image = "demoiselle.png",
    liquids_pointable = false,
    stack_max = 1,

	on_place = function(itemstack, placer, pointed_thing)
		if pointed_thing.type ~= "node" then
			return
		end
        
        local stack_meta = itemstack:get_meta()
        local staticdata = stack_meta:get_string("staticdata")

        local pointed_pos = pointed_thing.under
        --local node_below = minetest.get_node(pointed_pos).name
        --local nodedef = minetest.registered_nodes[node_below]
        
		pointed_pos.y=pointed_pos.y+0.5
		local demoiselle = minetest.add_entity(pointed_pos, "demoiselle:demoiselle", staticdata)
		if demoiselle and placer then
            local ent = demoiselle:get_luaentity()
            local owner = placer:get_player_name()
            ent.owner = owner
			demoiselle:set_yaw(placer:get_look_horizontal())
			itemstack:take_item()
		end

		return itemstack
	end,
})

--
-- crafting
--

if not minetest.settings:get_bool('demoiselle.disable_craftitems') and minetest.get_modpath("default") then
	minetest.register_craft({
		output = "demoiselle:wings",
		recipe = {
			{"wool:white", "farming:string", "wool:white"},
			{"group:wood", "group:wood", "group:wood"},
			{"wool:white", "farming:string", "wool:white"},
		}
	})
	minetest.register_craft({
		output = "demoiselle:body",
		recipe = {
			{"default:steel_ingot", "default:mese_block", "default:steel_ingot"},
			{"group:wood", "group:wood", "group:wood"},
			{"default:steel_ingot", "group:wood",   "default:steel_ingot"},
		}
	})
	minetest.register_craft({
		output = "demoiselle:demoiselle",
		recipe = {
			{"demoiselle:wings",},
			{"demoiselle:body",},
		}
	})
end
