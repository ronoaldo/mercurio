
-- Override grasses to drop seeds

if minetest.registered_nodes["default:grass_1"] then

	for i = 4, 5 do

		minetest.override_item("default:grass_" .. i, {
			drop = {
				max_items = 1,
				items = {
					{items = {"farming:seed_wheat"}, rarity = 5},
					{items = {"farming:seed_oat"},rarity = 5},
					{items = {"default:grass_1"}}
				}
			}
		})
	end
end

if minetest.registered_nodes["default:dry_grass_1"] then

	for i = 4, 5 do

		minetest.override_item("default:dry_grass_" .. i, {
			drop = {
				max_items = 1,
				items = {
					{items = {"farming:seed_barley"}, rarity = 5},
					{items = {"farming:seed_rye"}, rarity = 5},
					{items = {"default:dry_grass_1"}}
				}
			}
		})
	end
end

if minetest.registered_nodes["default:junglegrass"] then

	minetest.override_item("default:junglegrass", {
		drop = {
			max_items = 1,
			items = {
				{items = {"farming:seed_cotton"}, rarity = 8},
				{items = {"farming:seed_rice"}, rarity = 8},
				{items = {"default:junglegrass"}}
			}
		}
	})
end

if farming.mcl then

	minetest.override_item("mcl_flowers:tallgrass", {
		drop = {
			max_items = 1,
			items = {
				{items = {"mcl_farming:wheat_seeds"}, rarity = 5},
				{items = {"farming:seed_oat"},rarity = 5},
				{items = {"farming:seed_barley"}, rarity = 5},
				{items = {"farming:seed_rye"},rarity = 5},
				{items = {"farming:seed_cotton"}, rarity = 8},
				{items = {"farming:seed_rice"},rarity = 8}
			}
		}
	})
end
