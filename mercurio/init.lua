minetest.log("action", "[MOD]mercurio: Initializing...")

-- PvP area
minetest.register_on_punchplayer(function(player, hitter, time_from_last_punch, tool_capabilities, dir, damage)
    if not hitter:is_player() or not player:is_player() then
        return
    end

    local pvp_center = minetest.setting_get_pos("pvp_area_center")
    local pvp_size   = minetest.settings:get("pvp_area_size")

    local pos = player:get_pos()
    local bound_x = pos.x <= (pvp_center.x-pvp_size) or pos.x >= (pvp_center.x+pvp_size)
    local bound_y = pos.y <= (pvp_center.y-pvp_size) or pos.y >= (pvp_center.y+pvp_size)
    local bound_z = pos.z <= (pvp_center.z-pvp_size) or pos.z >= (pvp_center.z+pvp_size)

    if bound_x or bound_y or bound_z then
        return true
    end
    return
end)

-- Fix remaining unknown nodes after adding moreblocks
local function fix_nodes(from, to)
    minetest.log("action", "[MOD]mercurio: F´ixing node using alias from "..from..", to "..to)
    minetest.register_alias(from, to)
end
fix_nodes("ethereal:redwood_wood_micropanel", "ethereal:panel_redwood_wood_1")
fix_nodes("ethereal:redwood_wood_microslab", "ethereal:slab_redwood_wood_1")

fix_nodes("stairs:stair_red",      "bakedclay:stair_baked_clay_red")
fix_nodes("stairs:stair_inner_red","bakedclay:stair_baked_clay_red_inner")
fix_nodes("stairs:stair_outer_red","bakedclay:stair_baked_clay_red_outer")

fix_nodes("stairs:stair_orange",      "bakedclay:stair_baked_clay_orange")
fix_nodes("stairs:stair_inner_orange","bakedclay:stair_baked_clay_orange_inner")
fix_nodes("stairs:stair_outer_orange","bakedclay:stair_baked_clay_orange_outer")

fix_nodes("stairs:stair_grey",      "bakedclay:stair_baked_clay_grey")
fix_nodes("stairs:stair_inner_grey","bakedclay:stair_baked_clay_grey_inner")
fix_nodes("stairs:stair_outer_grey","bakedclay:stair_baked_clay_grey_outer")

fix_nodes("stairs:slab_red", "bakedclay:slab_baked_clay_red")
fix_nodes("bakedclay:red_microslab",   "bakedclay:slab_baked_clay_red_1")

fix_nodes("stairs:slab_orange", "bakedclay:slab_baked_clay_orange")
fix_nodes("bakedclay:orange_microslab","bakedclay:slab_baked_clay_orange_1")

fix_nodes("stairs:slab_grey", "bakedclay:slab_baked_clay_grey")
fix_nodes("bakedclay:grey_microslab",  "bakedclay:slab_baked_clay_grey_1")

fix_nodes("stairs:stair_Adobe", "building_blocks:stair_Adobe")

minetest.log("action", "[MOD]mercurio: Loaded!")
