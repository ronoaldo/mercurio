-- Mercurio server overrides

-- log_action logs the provided message with 'action' level.
local function log_action(msg)
    minetest.log("action", "[MOD]mercurio: "..msg)
end

-- format_pos formats the given position with no decimal places
local function fmt_pos(pos)
    return minetest.pos_to_string(pos, 0)
end

local function to_json(val)
    if val == nil then
        return "null"
    end
    local str = minetest.write_json(val)
    if str == nil then
        return "null"
    end
    return str
end


-- PvP area as defined by the server settings.
local pvp_center = minetest.setting_get_pos("pvp_area_center")
local pvp_size   = minetest.settings:get("pvp_area_size")
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
log_action("PvP area with center at " .. fmt_pos(pvp_center) .. ", and " .. pvp_size .. " blocks.")

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

-- Fix remaining unknown nodes after adding moreblocks
local function fix_nodes(from, to)
    log_action("Fixing unknown node using alias from "..from..", to "..to)
    minetest.register_alias(from, to)
end

log_action("Initializing server overrides ...")
-- Fixes several nodes missing missing after adding moreores/moreblocks
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
-- Replace trike:repair_tool into airutils:repair_tool
fix_nodes("trike:repair_tool", "airutils:repair_tool")
-- Temporary fix for draconis after upgrade to 1.2.x
fix_nodes("draconis:egg_ice_dragon_white",      "draconis:egg_ice_white")
fix_nodes("draconis:egg_ice_dragon_slate",      "draconis:egg_ice_slate")
fix_nodes("draconis:egg_ice_dragon_silver",     "draconis:egg_ice_silver")
fix_nodes("draconis:egg_ice_dragon_light_blue", "draconis:egg_ice_light_blue")
fix_nodes("draconis:egg_ice_dragon_sapphire",   "draconis:egg_ice_sapphire")
fix_nodes("draconis:egg_fire_dragon_green",     "draconis:egg_fire_green")
fix_nodes("draconis:egg_fire_dragon_red",       "draconis:egg_fire_red")
fix_nodes("draconis:egg_fire_dragon_gold",      "draconis:egg_fire_gold")
fix_nodes("draconis:egg_fire_dragon_black",     "draconis:egg_fire_black")
fix_nodes("draconis:egg_fire_dragon_bronze",    "draconis:egg_fire_bronze")
fix_nodes("draconis:dracolily_fire", "air")
fix_nodes("draconis:dracolily_ice", "air")
-- Removing disabled entities from previous mods
remove_entity(":dmobs:nyan")
remove_entity(":loot_crates:common")
remove_entity(":loot_crates:uncommon")
remove_entity(":loot_crates:rare")
remove_entity(":draconis:dracolily_fire")
remove_entity(":draconis:dracolily_ice")
-- Spawn overrides
local _orig_spawn_check = mobs.spawn_abm_check
local function mercurio_spawn_abm_check(self, pos, node, name)
    if name == "nether_mobs:netherman" then
        if pos.y >= -3000 then
            return true
        end
    end
    return _orig_spawn_check(pos, node, name)
end
mobs.spawn_abm_check = mercurio_spawn_abm_check

-- Debug spawning mobs from mobs_redo:
log_action("mobs.spawning_mobs = " .. minetest.write_json(mobs.spawning_mobs))

-- ABM to fix Nether unknown blocks already created
minetest.register_abm({
    label = "Fix unknown nodes bellow Nether",
    nodenames = {"nether:native_mapgen"},
    interval = 1.0,
    chance = 1,
    catch_up = true,
    action = function(pos, node, active_object_count, active_object_count_wider)
        if pos.y >= -11000 then
            return
        end
        log_action("Fixing Nether node node at pos "..to_json(pos))
        minetest.set_node(pos, {name="default:stone"})
    end,
})

log_action("Server overrides loaded!")