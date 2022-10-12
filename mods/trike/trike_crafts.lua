-- engine
minetest.register_craftitem("trike:wing",{
	description = "Trike wing",
	inventory_image = "icon3.png",
})
-- hull
minetest.register_craftitem("trike:fuselage",{
	description = "Trike body",
	inventory_image = "icon2.png",
})


-- trike
minetest.register_craftitem("trike:trike", {
	description = "Ultralight Trike",
	inventory_image = "icon1.png",
    liquids_pointable = false,

	on_place = function(itemstack, placer, pointed_thing)
		if pointed_thing.type ~= "node" then
			return
		end
        
        local pointed_pos = pointed_thing.under
        local node_below = minetest.get_node(pointed_pos).name
        local nodedef = minetest.registered_nodes[node_below]
        if nodedef.liquidtype == "none" then
			pointed_pos.y=pointed_pos.y+1.5
			local new_trike = minetest.add_entity(pointed_pos, "trike:trike")
			if new_trike and placer then
                local ent = new_trike:get_luaentity()
                local owner = placer:get_player_name()
                ent.owner = owner
				new_trike:set_yaw(placer:get_look_horizontal())
				itemstack:take_item()
                airutils.create_inventory(ent, trike.trunk_slots, owner)
			end
        end

		return itemstack
	end,
})

--
-- crafting
--

if minetest.get_modpath("default") then
	minetest.register_craft({
		output = "trike:wing",
		recipe = {
			{"",           "wool:white",          ""          },
			{"wool:white", "default:steel_ingot", "wool:white"},
			{"farming:string", "wool:white",      "farming:string"},
		}
	})
	minetest.register_craft({
		output = "trike:fuselage",
		recipe = {
			{"",                    "default:diamondblock", ""},
			{"default:steel_ingot", "default:steel_ingot",  "default:steel_ingot"},
			{"default:steel_ingot", "default:mese_block",   "default:steel_ingot"},
		}
	})
	minetest.register_craft({
		output = "trike:trike",
		recipe = {
			{"",                  ""},
			{"trike:fuselage", "trike:wing"},
		}
	})
    minetest.register_craft({
	    output = "trike:repair_tool",
	    recipe = {
		    {"default:steel_ingot", "", "default:steel_ingot"},
		    {"", "default:steel_ingot", ""},
		    {"", "default:steel_ingot", ""},
	    },
    })
end
