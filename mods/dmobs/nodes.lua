-- wasps nest
minetest.register_node("dmobs:hive", {
	description = "Wasp Nest",
	tiles = {"dmobs_hive.png"},
	groups = {crumbly=1, oddly_breakable_by_hand=1, falling_node=1, flammable=1},
	on_destruct = function(pos, oldnode)
		minetest.add_entity(pos, "dmobs:wasp")
		minetest.add_entity(pos, "dmobs:wasp")
		minetest.add_entity(pos, "dmobs:wasp")
		minetest.add_entity(pos, "dmobs:wasp")
	end,
})

-- golem
minetest.register_node("dmobs:golemstone", {
	description = "golem stone",
	tiles = {"dmobs_golem_stone.png",},
	groups = {cracky=1},
	on_construct = function(pos, node, _)

		local node1 = minetest.get_node({x=pos.x, y=pos.y-1, z=pos.z}).name
		local node2 = minetest.get_node({x=pos.x, y=pos.y-2, z=pos.z}).name
		local node3 = minetest.get_node({x=pos.x, y=pos.y+1, z=pos.z}).name

		if node1 == "default:stone"
		and node2 == "default:stone"
		and node3 == "air" then

			minetest.add_entity(pos, "dmobs:golem_friendly")
			minetest.remove_node({x=pos.x, y=pos.y-1, z=pos.z})
			minetest.remove_node({x=pos.x, y=pos.y-2, z=pos.z})
			minetest.remove_node({x=pos.x, y=pos.y, z=pos.z})
		end
	end,
})
