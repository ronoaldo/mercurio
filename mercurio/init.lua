-- Mercurio server overrides

-- log_action logs the provided message with 'action' level.
local function log_action(msg)
    minetest.log("action", "[MOD]mercurio: "..msg)
end

-- format_pos formats the given position with no decimal places
local function fmt_pos(pos)
    return minetest.pos_to_string(pos, 0)
end

log_action("Initializing server overrides ...")

-- PvP area as defined by the server settings.
local pvp_center = minetest.setting_get_pos("pvp_area_center")
local pvp_size   = minetest.settings:get("pvp_area_size")
log_action("PvP area with center at " .. fmt_pos(pvp_center) ..
    ", and " .. pvp_size .. " blocks.")
minetest.register_on_punchplayer(function(player, hitter, time_from_last_punch, tool_capabilities, dir, damage)
    if not hitter:is_player() or not player:is_player() then
        return
    end

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
    log_action("Fixing unknown node using alias from "..from..", to "..to)
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
-- Removes surprise blocks replacing them with air
fix_nodes("tsm_surprise:question", "air")

-- Remove unknown entities
local function remove_entity(name)
    log_action("Registering entities with name=" .. name .. " for removal.")
    minetest.register_entity(name, {
        on_activate = function(self, dtime, staticdata)
            local o = self.object
            local pos = fmt_pos(o:get_pos())
            log_action("Removing entity " .. self.name .. " at " .. pos)
            o:remove()
        end
    })
end
remove_entity(":dmobs:nyan")
remove_entity(":loot_crates:common")
remove_entity(":loot_crates:uncommon")
remove_entity(":loot_crates:rare")

log_action("Server overrides loaded!")