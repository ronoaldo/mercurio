
-- add compatibility for ethereal nodes already added to default game or name changed

core.register_alias("ethereal:acacia_trunk", "default:acacia_tree")
core.register_alias("ethereal:acacia_wood", "default:acacia_wood")

core.register_alias("ethereal:fence_acacia", "default:fence_acacia_wood")
core.register_alias("ethereal:fence_junglewood", "default:fence_junglewood")
core.register_alias("ethereal:fence_pine", "default:fence_pine_wood")

core.register_alias("ethereal:acacia_leaves", "default:acacia_leaves")
core.register_alias("ethereal:pineleaves", "default:pine_needles")

core.register_alias("ethereal:mushroom_craftingitem", "flowers:mushroom_brown")
core.register_alias("ethereal:mushroom_plant", "flowers:mushroom_brown")
core.register_alias("ethereal:mushroom_soup_cooked", "ethereal:mushroom_soup")
core.register_alias("ethereal:mushroom_1", "flowers:mushroom_brown")
core.register_alias("ethereal:mushroom_2", "flowers:mushroom_brown")
core.register_alias("ethereal:mushroom_3", "flowers:mushroom_brown")
core.register_alias("ethereal:mushroom_4", "flowers:mushroom_brown")

core.register_alias("ethereal:strawberry_bush", "ethereal:strawberry_7")
core.register_alias("ethereal:seed_strawberry", "ethereal:strawberry")

for i = 1, 5 do
	core.register_alias("ethereal:wild_onion_" .. i, "ethereal:onion_" .. i)
end

core.register_alias("ethereal:onion_7", "ethereal:onion_4")
core.register_alias("ethereal:onion_8", "ethereal:onion_5")
core.register_alias("ethereal:wild_onion_7", "ethereal:onion_4")
core.register_alias("ethereal:wild_onion_8", "ethereal:onion_5")
core.register_alias("ethereal:wild_onion_craftingitem", "ethereal:wild_onion_plant")

core.register_alias("ethereal:hearty_stew_cooked", "ethereal:hearty_stew")

core.register_alias("ethereal:obsidian_brick", "default:obsidianbrick")

core.register_alias("ethereal:crystal_topped_dirt", "ethereal:crystal_dirt")
core.register_alias("ethereal:fiery_dirt_top", "ethereal:fiery_dirt")
core.register_alias("ethereal:gray_dirt_top", "ethereal:gray_dirt")
core.register_alias("ethereal:green_dirt_top", "default;dirt_with_grass")

core.register_alias("ethereal:tree_sapling", "default:sapling")
core.register_alias("ethereal:jungle_tree_sapling", "default:junglesapling")
core.register_alias("ethereal:acacia_sapling", "default:acacia_sapling")
core.register_alias("ethereal:pine_tree_sapling", "default:pine_sapling")
