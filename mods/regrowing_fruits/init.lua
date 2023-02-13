
-- get min and max regrow interval settings
local min_interval = tonumber(minetest.settings:get("min_regrow_interval")) or 300
local max_interval = tonumber(minetest.settings:get("max_regrow_interval")) or 1500

local add_fruit_regrowable = function(fruit, node, leaves)

	-- check if node exists
	if not minetest.registered_nodes[node] then
		return
	end

	-- make sure cacao pod from cool_trees isn't placed by player
	if node == "cacaotree:pod" then
		minetest.register_node("regrowing_fruits:cacao", {
			description = "Cacao Pod",
			drawtype = "nodebox",
			tiles = {
				"cacaotree_bean_top.png",
				"cacaotree_bean_top.png^[transformFY",
				"cacaotree_bean_right.png",
				"cacaotree_bean_right.png^[transformFX",
				"cacaotree_bean_front.png",
			},
			paramtype = "light",
			paramtype2 = "wallmounted",
			node_box = {
				type = "fixed",
				fixed = {
					{-0.25, -0.5, 0, 0.25, 0.0625, 0.5},
				},
			},
			use_texture_alpha = "clip",
			drop = "cacaotree:cacao_beans 10",
			groups = {fleshy = 3, dig_immediate = 3, flammable = 2,
					  leafdecay = 3, leafdecay_drop = 1, not_in_creative_inventory = 1},
			sounds = default.node_sound_leaves_defaults(),
			walkable = false,
			is_ground_content = false,
		})

		minetest.register_on_placenode(function(pos, newnode, placer)
			if placer and placer:is_player() and newnode.name == "cacaotree:pod" then
				minetest.set_node(pos, {name = "regrowing_fruits:cacao", param2 = newnode.param2})
			end
		end)
	end

	-- make sure (moretrees) fruits don't fall on dig
	local groups = minetest.registered_nodes[node].groups
	groups.attached_node = 0

	-- wait until mods are loaded to ensure that other mods do not override overrides
	minetest.after(0.1, function()
		-- override fruit
		minetest.override_item(node, {
			--groups = groups,
			after_place_node = function(pos, placer) -- make sure (moretrees and plumtree) fruits aren't placed by player
				if placer:is_player() and node == "plumtree:plum" then
					minetest.set_node(pos, {name = node, param2 = 0})
				elseif placer:is_player() then
					minetest.set_node(pos, {name = node, param2 = 1})
				end
			end,
			on_dig = minetest.node_dig, -- override on_dig functions causing regrowth not to work
			after_dig_node = function(pos, oldnode, oldmetadata, digger)
				if oldnode.param2 == 0 and oldnode.name ~= "plumtree:plum"
						or oldnode.name == "plumtree:plum" and oldnode.param2 == 1
						or oldnode.name == "cacaotree:pod" then
					minetest.set_node(pos, {name = "regrowing_fruits:"..fruit.."_mark", param2 = oldnode.param2})
					minetest.get_node_timer(pos):start(math.random(min_interval, max_interval))
				end
			end,
		})
	end)

	-- air node to mark fruit pos
	minetest.register_node("regrowing_fruits:"..fruit.."_mark", {
		description = "Air!",
		drawtype = "airlike",
		paramtype = "light",
		sunlight_propagates = true,
		walkable = false,
		pointable = false,
		diggable = false,
		buildable_to = true,
		drop = "",
		groups = {not_in_creative_inventory = 1},
		on_timer = function(pos, elapsed)
			if not minetest.find_node_near(pos, 1, leaves) then
				minetest.remove_node(pos)
			elseif minetest.get_node_light(pos) < 11 then
				minetest.get_node_timer(pos):start(200)
			else
				minetest.set_node(pos, {name = node, param2 = minetest.get_node(pos).param2})
			end
		end
	})
end

-- apples
add_fruit_regrowable("apple", "default:apple", {"default:leaves", "moretrees:apple_tree_leaves"})

-- ethereal
add_fruit_regrowable("banana","ethereal:banana", "ethereal:bananaleaves")
add_fruit_regrowable("banana_bunch", "ethereal:banana_bunch", "ethereal:bananaleaves")
add_fruit_regrowable("coconut", "ethereal:coconut", "ethereal:palmleaves")
add_fruit_regrowable("golden_apple", "ethereal:golden_apple", "ethereal:yellowleaves")
add_fruit_regrowable("lemon", "ethereal:lemon", "ethereal:lemon_leaves")
add_fruit_regrowable("olive", "ethereal:olive", "ethereal:olive_leaves")
add_fruit_regrowable("orange", "ethereal:orange", "ethereal:orange_leaves")

-- cool_trees
add_fruit_regrowable("cacao", "cacaotree:pod", "cacaotree:trunk") -- use trunk instead of leaves
add_fruit_regrowable("cherry", "cherrytree:cherries", "cherrytree:blossom_leaves")
add_fruit_regrowable("chestnut", "chestnuttree:bur", "chestnuttree:leaves")
add_fruit_regrowable("clementine", "clementinetree:clementine", "clementinetree:leaves")
add_fruit_regrowable("persimmon", "ebony:persimmon", "ebony:leaves")
add_fruit_regrowable("cool_lemon", "lemontree:lemon", "lemontree:leaves")
add_fruit_regrowable("acorn", "oak:acorn", "oak:leaves")
add_fruit_regrowable("cool_coconut", "palm:coconut", "palm:leaves")
add_fruit_regrowable("plum", "plumtree:plum", "plumtree:leaves")
add_fruit_regrowable("pomegranate", "pomegranate:pomegranate", "pomegranate:leaves")

-- moretrees
add_fruit_regrowable("moreacorn", "moretrees:acorn", "moretrees:oak_leaves")
add_fruit_regrowable("cedar_cone", "moretrees:cedar_cone", "moretrees:cedar_leaves")
add_fruit_regrowable("fir_cone", "moretrees:fir_cone", "moretrees:fir_leaves")
add_fruit_regrowable("spruce_cone", "moretrees:spruce_cone", "moretrees:spruce_leaves")

-- farming_plus
add_fruit_regrowable("cocoa", "farming_plus:cocoa", "farming_plus:cocoa_leaves")
add_fruit_regrowable("banana_plus", "farming_plus:banana", "farming_plus:banana_leaves")

-- multibiomegen
for i=0,230 do
	add_fruit_regrowable("fruit_"..i, "multibiomegen:fruit_"..i, "multibiomegen:leaf_"..i)
end

-- australia
add_fruit_regrowable("australia_cherry", "australia:cherry", "australia:cherry_leaves")
add_fruit_regrowable("lilly_pilly_berries", "australia:lilly_pilly_berries", "australia:lilly_pilly_leaves")
add_fruit_regrowable("macadamia", "australia:macadamia", "australia:macadamia_leaves")
add_fruit_regrowable("mangrove_apple", "australia:mangrove_apple", "australia:mangrove_apple_leaves")
add_fruit_regrowable("moreton_bay_fig", "australia:moreton_bay_fig", "australia:moreton_bay_fig_leaves")
add_fruit_regrowable("quandong", "australia:quandong", "australia:quandong_leaves")

-- aotearoa
add_fruit_regrowable("karaka_fruit", "aotearoa:karaka_fruit", "aotearoa:karaka_leaves")
add_fruit_regrowable("miro_fruit", "aotearoa:miro_fruit", "aotearoa:miro_leaves")
add_fruit_regrowable("tawa_fruit", "aotearoa:tawa_fruit", "aotearoa:tawa_leaves")
add_fruit_regrowable("hinau_fruit", "aotearoa:hinau_fruit", "aotearoa:hinau_leaves")
add_fruit_regrowable("kawakawa_fruit", "aotearoa:kawakawa_fruit", "aotearoa:kawakawa_leaves")

-- aliases
minetest.register_alias("regrowing_fruits:goldapple_mark", "regrowing_fruits:golden_apple_mark")
minetest.register_alias("regrowing_fruits:coollemon_mark", "regrowing_fruits:cool_lemon_mark")
minetest.register_alias("regrowing_fruits:coolcoconut_mark", "regrowing_fruits:cool_coconut_mark")