local S = trike.S

-- wing
minetest.register_craftitem("trike:wing",{
	description = S("trike wing"),
	inventory_image = "trike_wing_ico.png",
})
-- fuselage
minetest.register_craftitem("trike:fuselage",{
	description = S("trike fuselage"),
	inventory_image = "trike_body.png",
})

-- trike
minetest.register_craftitem("trike:trike", {
	description = S("Ultralight Trike"),
	inventory_image = "trike.png",
    liquids_pointable = true,

	on_place = function(itemstack, placer, pointed_thing)
		if pointed_thing.type ~= "node" then
			return
		end
        
        local pointed_pos = pointed_thing.under
        --local node_below = minetest.get_node(pointed_pos).name
        --local nodedef = minetest.registered_nodes[node_below]
        
		pointed_pos.y=pointed_pos.y+0.5
		local trike = minetest.add_entity(pointed_pos, "trike:trike")
		if trike and placer then
            local ent = trike:get_luaentity()
            local owner = placer:get_player_name()
            ent.owner = owner
			trike:set_yaw(placer:get_look_horizontal())
			itemstack:take_item()
		end

		return itemstack
	end,
})

--
-- crafting
--

if not minetest.settings:get_bool('trike.disable_craftitems') and minetest.get_modpath("default") then
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
end
