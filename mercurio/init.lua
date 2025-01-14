-------------------------------
-- Mercurio server overrides --
-------------------------------

local path = minetest.get_modpath("mercurio")

-- Helper functions
mercurio = {}

-- log_action logs the provided message with 'action' level.
mercurio.log_action = function(msg)
    minetest.log("action", "[MOD]mercurio: "..msg)
end

-- format_pos formats the given position with no decimal places
mercurio.fmt_pos = function(pos)
    if pos == nil then
        return "null"
    end
    return minetest.pos_to_string(pos, 0)
end

-- to_json formats the provided value as a JSON string.
mercurio.to_json = function(val, pretty)
    if val == nil then
        return "null"
    end
    local str = minetest.write_json(val, pretty)
    if str == nil then
        return "null"
    end
    return str
end

-- Syntax suggar
local log_action = mercurio.log_action
local fmt_pos = mercurio.fmt_pos
local to_json = mercurio.to_json

-- PvP area as defined by the server settings.
-- If not specified in minetest.conf, defaults to the whole world being pvp enabled.
local pvp_center = minetest.setting_get_pos("pvp_area_center") or {x=0, y=0, z=0}
local pvp_size   = minetest.settings:get("pvp_area_size") or 33000

-- Custom on_punchplayer callback to implement server-wide damage overrides.
minetest.register_on_punchplayer(function(player, hitter, time_from_last_punch, tool_capabilities, dir, damage)
    -- If the damage is not between players, proceed regular damage calculation.
    if not hitter:is_player() or not player:is_player() then
        return
    end

    -- If damage is done between players and outside PvP, skip damage calculation.
    local pos = player:get_pos()
    local bound_x = pos.x <= (pvp_center.x-pvp_size) or pos.x >= (pvp_center.x+pvp_size)
    local bound_y = pos.y <= (pvp_center.y-pvp_size) or pos.y >= (pvp_center.y+pvp_size)
    local bound_z = pos.z <= (pvp_center.z-pvp_size) or pos.z >= (pvp_center.z+pvp_size)
    if bound_x or bound_y or bound_z then
        return true
    end

    -- No exceptions, resume regular damage calculation as usual.
    return
end)
log_action("PvP area with center at " .. fmt_pos(pvp_center) .. ", and " .. pvp_size .. " blocks.")

-- Creating the video_producer privilege to allow players to record vídeos from battles.
minetest.register_privilege("video_producer", {
    description = "Can record vídeos not taking any damage",
    give_to_singleplayer = false
})
minetest.register_on_joinplayer(function(player)
    local name = player:get_player_name()
    if minetest.check_player_privs(name, {video_producer = true}) then
        local groups = player:get_armor_groups() or {}
        groups.immortal = 1
        player:set_armor_groups(groups)
        log_action("*** Player is a video_producer, adding invincible armor group")
    end
end)

-- Small fix to respawn mod to avoid showing immortal players death message/log.
local _orig_respawn_death = respawn.death
local function respawn_death(player, data)
    if not player then return false end
    local groups = player:get_armor_groups()
    if groups then
        if groups.immortal then
            -- Avoid showing the message for immortal players
            return false
        end
    end
    return _orig_respawn_death(player, data)
end
respawn.death = respawn_death

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
local function alias(from, to, force)
    log_action("Fixing unknown node using alias from "..from..", to "..to)
    if force and force == true then
        minetest.register_alias_force(from, to)
    else
        minetest.register_alias(from, to)
    end
end

log_action("Initializing server overrides ...")
-- Fixes several nodes missing missing after adding moreores/moreblocks
alias("ethereal:redwood_wood_micropanel", "ethereal:panel_redwood_wood_1")
alias("ethereal:redwood_wood_microslab", "ethereal:slab_redwood_wood_1")
alias("stairs:stair_red",      "bakedclay:stair_baked_clay_red")
alias("stairs:stair_inner_red","bakedclay:stair_baked_clay_red_inner")
alias("stairs:stair_outer_red","bakedclay:stair_baked_clay_red_outer")
alias("stairs:stair_orange",      "bakedclay:stair_baked_clay_orange")
alias("stairs:stair_inner_orange","bakedclay:stair_baked_clay_orange_inner")
alias("stairs:stair_outer_orange","bakedclay:stair_baked_clay_orange_outer")
alias("stairs:stair_grey",      "bakedclay:stair_baked_clay_grey")
alias("stairs:stair_inner_grey","bakedclay:stair_baked_clay_grey_inner")
alias("stairs:stair_outer_grey","bakedclay:stair_baked_clay_grey_outer")
alias("stairs:slab_red", "bakedclay:slab_baked_clay_red")
alias("bakedclay:red_microslab",   "bakedclay:slab_baked_clay_red_1")
alias("stairs:slab_orange", "bakedclay:slab_baked_clay_orange")
alias("bakedclay:orange_microslab","bakedclay:slab_baked_clay_orange_1")
alias("stairs:slab_grey", "bakedclay:slab_baked_clay_grey")
alias("bakedclay:grey_microslab",  "bakedclay:slab_baked_clay_grey_1")
alias("stairs:stair_Adobe", "building_blocks:stair_Adobe")
-- Removes surprise blocks replacing them with air
alias("tsm_surprise:question", "air")
-- Replace trike:repair_tool into airutils:repair_tool
alias("trike:repair_tool", "airutils:repair_tool")
-- Temporary fix for draconis after upgrade to 1.2.x
alias("draconis:egg_ice_dragon_white",      "draconis:egg_ice_white")
alias("draconis:egg_ice_dragon_slate",      "draconis:egg_ice_slate")
alias("draconis:egg_ice_dragon_silver",     "draconis:egg_ice_silver")
alias("draconis:egg_ice_dragon_light_blue", "draconis:egg_ice_light_blue")
alias("draconis:egg_ice_dragon_sapphire",   "draconis:egg_ice_sapphire")
alias("draconis:egg_fire_dragon_green",     "draconis:egg_fire_green")
alias("draconis:egg_fire_dragon_red",       "draconis:egg_fire_red")
alias("draconis:egg_fire_dragon_gold",      "draconis:egg_fire_gold")
alias("draconis:egg_fire_dragon_black",     "draconis:egg_fire_black")
alias("draconis:egg_fire_dragon_bronze",    "draconis:egg_fire_bronze")
-- Remove mapserver nodes
alias("mapserver:border", "default:stone")
alias("mapserver:label", "default:stone")
alias("mapserver:poi_blue", "default:stone")
alias("mapserver:poi_green", "default:stone")
alias("mapserver:poi_orange", "default:stone")
alias("mapserver:poi_red", "default:stone")
alias("mapserver:poi_purple", "default:stone")
alias("mapserver:train", "default:stone")
-- Force alias for stone to avoid inventory bug (game replacing inv item with air)
alias("draconis:dracolily_fire", "default:stone", true)
alias("draconis:dracolily_ice", "default:stone", true)
alias("draconis:blood_fire_dragon", "default:stone", true)
alias("draconis:blood_ice_dragon", "default:stone", true)
-- Removing disabled entities from previous mods
remove_entity(":dmobs:nyan")
remove_entity(":loot_crates:common")
remove_entity(":loot_crates:uncommon")
remove_entity(":loot_crates:rare")
-- Spawn overrides
local _orig_spawn_check = mobs.spawn_abm_check
local do_not_spawn = {
    -- Do not spawn some dmobs monsters, they're weird/annoying
    "dmobs:nyan",
    "dmobs:rat",
    "dmobs:wasp",
    "dmobs:wasp_leader",
    -- Do not spawn dmobs dragons, using Draconis for them
    "dmobs:dragon1",
    "dmobs:dragon2",
    "dmobs:dragon3",
    "dmobs:dragon4",
    "dmobs:dragon",
    "dmobs:dragon1",
    "dmobs:dragon2",
    "dmobs:dragon3",
    "dmobs:dragon4",
    "dmobs:dragon_black",
    "dmobs:dragon_blue",
    "dmobs:dragon_great",
    "dmobs:dragon_great_tame",
    "dmobs:dragon_green",
    "dmobs:dragon_red",
    "dmobs:waterdragon",
    "dmobs:waterdragon_2",
    "dmobs:wyvern",
    -- Do not spawn some of the animals, using Animalia for them
    "mobs_animal:chicken",
    "mobs_animal:cow",
    "mobs_animal:kitten",
    "mobs_animal:rat",
    "mobs_animal:sheep_",
}
local function mercurio_spawn_abm_check(self, pos, node, name)
    if name == "nether_mobs:netherman" then
        if pos.y >= -3000 then
            return true
        end
    end
    for _, s in ipairs(do_not_spawn) do
        if name:find(s) then
            return true
        end
    end
    return _orig_spawn_check(pos, node, name)
end
mobs.spawn_abm_check = mercurio_spawn_abm_check

-- Debug spawning mobs from mobs_redo:
-- log_action("mobs.spawning_mobs = " .. minetest.write_json(mobs.spawning_mobs))

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

-- Load beta server settings
local is_beta_server = minetest.settings:get("mercurio_beta_server")
if is_beta_server == "true" then
    log_action("Enabling beta features")
    dofile(path .. "/beta.lua")
end

-- Load server chat filter
filter.import_file(path .. "/bannedwords/pt_BR.txt")
filter.import_file(path .. "/bannedwords/es.txt")
filter.import_file(path .. "/bannedwords/en.txt")

-- Load server-only craft items
dofile(path .. "/items.lua")

-- Load admin commands
dofile(path .. "/admin.lua")

-- Unified Inventory Monkey Patch
dofile(path .. "/inventory.lua")

-- Monkey patches
dofile(path .. "/patches.lua")
dofile(path .. "/xdecor.lua")

log_action("Server overrides loaded!")

