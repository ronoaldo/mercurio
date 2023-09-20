regrowing_fruits = {

	-- get standard min and max regrow interval from settings
    min_interval = tonumber(minetest.settings:get("min_regrow_interval")) or 300,
    max_interval = tonumber(minetest.settings:get("max_regrow_interval")) or 1500,

	-- get chance to stop regrowth
	stop_chance = tonumber(minetest.settings:get("regrowth_stop_chance")) or 0.02
}

regrowing_fruits.add = function(fruitname, leafname, param2, multiplier)

	-- check if node exists
	if not minetest.registered_nodes[fruitname] then
		return
	end

	local min = regrowing_fruits.min_interval
	local max = regrowing_fruits.max_interval
	local diff = regrowing_fruits.max_interval - regrowing_fruits.min_interval

	-- apply multiplier to standard min and max interval
	if multiplier then
		if multiplier >= 1 then
			min = multiplier * (min/2 + max/2) - diff/2 * (1/2 + multiplier/2)
			max = min + diff * (1/2 + multiplier/2)
		else
			min = multiplier * min
			max = multiplier * max
		end
	end

	-- remove nodes from attached_node group (causes regrowth not to work)
	local groups = minetest.registered_nodes[fruitname].groups
	groups.attached_node = 0

	-- wait until mods are loaded to ensure that other mods do not override overrides
	minetest.after(0, function()

		local override = {

			-- override on_dig functions causing regrowth not to work
			on_dig = minetest.node_dig,

			-- start regrowth after node has been dug
			after_dig_node = function(pos, oldnode, oldmetadata, digger)

				-- make sure node wasn't placed by player
				if oldnode.param2 == (param2 or 0) or param2 == -1 then

					-- apply chance of no fruit regrowth
					if regrowing_fruits.stop_chance == 0 or math.random(1, 1/regrowing_fruits.stop_chance) ~= 1 then

						-- set fruit marker node for regrowth
						minetest.set_node(pos, {name = fruitname.."_mark", param2 = oldnode.param2})

						-- start regrowth timer
						minetest.get_node_timer(pos):start(math.random(min, max))
					end
				end
			end,
		}

		-- set after_place_node if it is not defined or if param2 is available
		if not (param2 and minetest.registered_nodes[fruitname].after_place_node) or param2 and param2 == 0 then
			override.after_place_node = function(pos, placer)
				if placer:is_player() then
					minetest.set_node(pos, {name = fruitname, param2 = 1})
				end
			end
		elseif param2 and param2 > 0 then
			override.after_place_node = function(pos, placer)
				if placer:is_player() then
					minetest.set_node(pos, {name = fruitname, param2 = 0})
				end
			end
		end

		-- override fruit
		minetest.override_item(fruitname, override)
	end)

	-- air node to mark fruit pos
	minetest.register_node(":"..fruitname.."_mark", {
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
			if not minetest.find_node_near(pos, 1, leafname) then
				minetest.remove_node(pos)
			elseif minetest.get_node_light(pos) < 11 then
				minetest.get_node_timer(pos):start(200)
			else
				minetest.set_node(pos, {name = fruitname, param2 = minetest.get_node(pos).param2})
			end
		end
	})
end

-- default
regrowing_fruits.add("default:apple", {"default:leaves", "moretrees:apple_tree_leaves"})

-- ethereal
regrowing_fruits.add("ethereal:banana", "ethereal:bananaleaves")
regrowing_fruits.add("ethereal:banana_bunch", "ethereal:bananaleaves")
regrowing_fruits.add("ethereal:coconut", "ethereal:palmleaves")
regrowing_fruits.add("ethereal:golden_apple", "ethereal:yellowleaves", nil, 3)
regrowing_fruits.add("ethereal:lemon", "ethereal:lemon_leaves")
regrowing_fruits.add("ethereal:olive", "ethereal:olive_leaves")
regrowing_fruits.add("ethereal:orange", "ethereal:orange_leaves")

-- cool_trees
regrowing_fruits.add("cacaotree:pod", "cacaotree:trunk", -1) -- use trunk instead of leaves
regrowing_fruits.add("cherrytree:cherries", "cherrytree:blossom_leaves")
regrowing_fruits.add("chestnuttree:bur", "chestnuttree:leaves")
regrowing_fruits.add("clementinetree:clementine", "clementinetree:leaves")
regrowing_fruits.add("ebony:persimmon", "ebony:leaves")
regrowing_fruits.add("lemontree:lemon", "lemontree:leaves")
regrowing_fruits.add("oak:acorn", "oak:leaves")
regrowing_fruits.add("palm:coconut", "palm:leaves")
regrowing_fruits.add("plumtree:plum", "plumtree:leaves")
regrowing_fruits.add("pomegranate:pomegranate", "pomegranate:leaves")

-- moretrees
regrowing_fruits.add("moretrees:acorn", "moretrees:oak_leaves")
regrowing_fruits.add("moretrees:cedar_cone", "moretrees:cedar_leaves")
regrowing_fruits.add("moretrees:fir_cone", "moretrees:fir_leaves")
regrowing_fruits.add("moretrees:spruce_cone", "moretrees:spruce_leaves")

-- farming_plus
regrowing_fruits.add("farming_plus:cocoa", "farming_plus:cocoa_leaves")
regrowing_fruits.add("farming_plus:banana", "farming_plus:banana_leaves")

-- multibiomegen
for i=0,230 do
	regrowing_fruits.add("multibiomegen:fruit_"..i, "multibiomegen:leaf_"..i)
end

-- australia
regrowing_fruits.add("australia:cherry", "australia:cherry_leaves")
regrowing_fruits.add("australia:lilly_pilly_berries", "australia:lilly_pilly_leaves")
regrowing_fruits.add("australia:macadamia", "australia:macadamia_leaves")
regrowing_fruits.add("australia:mangrove_apple", "australia:mangrove_apple_leaves")
regrowing_fruits.add("australia:moreton_bay_fig", "australia:moreton_bay_fig_leaves")
regrowing_fruits.add("australia:quandong", "australia:quandong_leaves")

-- aotearoa
regrowing_fruits.add("aotearoa:karaka_fruit", "aotearoa:karaka_leaves")
regrowing_fruits.add("aotearoa:miro_fruit", "aotearoa:miro_leaves")
regrowing_fruits.add("aotearoa:tawa_fruit", "aotearoa:tawa_leaves")
regrowing_fruits.add("aotearoa:hinau_fruit", "aotearoa:hinau_leaves")
regrowing_fruits.add("aotearoa:kawakawa_fruit", "aotearoa:kawakawa_leaves")

-- load compatibility for earlier versions
dofile(minetest.get_modpath("regrowing_fruits").."/compatibility.lua")