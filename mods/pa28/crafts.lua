
if not minetest.settings:get_bool('pa28.disable_craftitems') then
    -- wing
    minetest.register_craftitem("pa28:wings",{
	    description = "PA28 wings",
	    inventory_image = "pa28_wings.png",
    })
-- fuselage
    minetest.register_craftitem("pa28:fuselage",{
	    description = "PA28 fuselage",
	    inventory_image = "pa28_fuselage.png",
    })
end

-- pa28
minetest.register_craftitem("pa28:pa28", {
	description = "PA-28",
	inventory_image = "pa28.png",
    liquids_pointable = true,

	on_place = function(itemstack, placer, pointed_thing)
		if pointed_thing.type ~= "node" then
			return
		end

        local pointed_pos = pointed_thing.under
        --local node_below = minetest.get_node(pointed_pos).name
        --local nodedef = minetest.registered_nodes[node_below]

		pointed_pos.y=pointed_pos.y+2
		local pa28_ent = minetest.add_entity(pointed_pos, "pa28:pa28")
		if pa28_ent and placer then
            local ent = pa28_ent:get_luaentity()
            if ent then
                local owner = placer:get_player_name()
                ent.owner = owner
			    pa28_ent:set_yaw(placer:get_look_horizontal())
			    itemstack:take_item()
                airutils.create_inventory(ent, ent._trunk_slots, owner)
            end
		end

		return itemstack
	end,
})

--
-- crafting
--

if not minetest.settings:get_bool('pa28.disable_craftitems') and minetest.get_modpath("default") then
    minetest.register_craft({
	    output = "pa28:wings",
	    recipe = {
		    {"default:tin_ingot", "default:tin_ingot", "default:tin_ingot"},
		    {"default:steel_ingot", "default:tinblock", "default:steel_ingot"},
	    }
    })

    minetest.register_craft({
	    output = "pa28:fuselage",
	    recipe = {
		    {"default:tin_ingot", "default:diamondblock", "default:tin_ingot"},
		    {"default:steel_ingot", "default:steel_ingot",  "default:steel_ingot"},
		    {"default:tin_ingot", "default:mese_block",   "default:tin_ingot"},
	    }
    })

	minetest.register_craft({
		output = "pa28:pa28",
		recipe = {
			{"pa28:wings",},
			{"pa28:fuselage",},
		}
	})
end

