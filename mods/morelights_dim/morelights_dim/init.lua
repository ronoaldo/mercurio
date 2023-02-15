-- SPDX-FileCopyrightText: 2021 David Hurka <doxydoxy@mailbox.org>
--
-- SPDX-License-Identifier: CC0-1.0 OR MIT
morelights_dim = {};
dofile(minetest.get_modpath("morelights_dim") .. "/util.lua");

--- Items listed as key in this table will trigger the
--- morelights_dim.change_to_next_variant() right-click handler.
morelights_dim.light_level_tools = {};
for _, tool in ipairs(string.split(minetest.settings:get(
                                           "morelights_dim_light_level_tools") or
                                           "")) do
    morelights_dim.light_level_tools[string.trim(tool)] = true;
end

--- If true, the empty hand will trigger the
--- morelights_dim.change_to_next_variant() right-click handler.
morelights_dim.change_light_level_with_hand =
        minetest.settings:get_bool("morelights_dim_change_light_level_with_hand");
if not morelights_dim.change_light_level_with_hand then
    minetest.register_on_mods_loaded(function()
        if next(morelights_dim.light_level_tools) == nil then
            minetest.log("warning",
                         "morelights_dim: No tool for changing the light level registered. You should probably enable morelights_dim_change_light_level_with_hand.");
        end
    end)
end

--- Callback handler for the on_rightclick() callback of nodes.
---
--- Replaces the node at @p pos by @c _morelights_next_variant of that node,
--- if @p itemstack is a light bulb or optionally the empty hand.
---
--- @returns @p itemstack if the replacement was done, @c nil otherwise.
function morelights_dim.change_to_next_variant(pos, node, clicker, itemstack,
                                               _pointed_thing)
    if minetest.is_protected(pos, clicker:get_player_name()) then
        minetest.record_protection_violation(pos, clicker:get_player_name());
        return nil;
    end

    if morelights_dim.light_level_tools[itemstack:get_name()] or
            (morelights_dim.change_light_level_with_hand and
                    itemstack:is_empty()) then
        local node_def = minetest.registered_nodes[node.name];
        if node_def and node_def._morelights_dim_next_variant then
            node.name = node_def._morelights_dim_next_variant;
            minetest.swap_node(pos, node);
            return itemstack;
        end
    end
end

--- Creates a callback handler that calls morelights.change_to_next_variant,
--- and if that does not handle the call, calls @p old_handler (if present).
function morelights_dim.create_on_rightclick_handler(old_handler)
    return function(...)
        local _pos, _node, clicker, itemstack, pointed_thing = ...;
        return morelights_dim.change_to_next_variant(...) or
                       (old_handler and old_handler(...)) or
                       minetest.item_place_node(itemstack, clicker,
                                                pointed_thing);
    end
end

--- Light level to dimmed light level conversion.
morelights_dim.dimmed_light_level = {
    [15] = 10,
    [14] = 9, -- minetest.LIGHT_MAX.
    [13] = 8,
    [12] = 8,
    [11] = 7,
    [10] = 7,
    [9] = 6,
    [8] = 5,
    [7] = 4,
    [6] = 4,
    [5] = 3,
    [4] = 3,
    [3] = 2,
    [2] = 1,
    [1] = 1,
    [0] = 0,
};

--- Which texture parts should be dimmed by multiplying them.
---
--- Texture file strings are added as key,
--- and the value is a table of multipliers for dim and off state,
--- with elements @c _dimmed and @c _off.
morelights_dim.textures_to_dim = {};

--- Converts tile definition @p tile to a tile with darker light parts.
---
--- Texture components listed in textures_to_dim are multiplied.
---
--- @p state determines which multiplier to use (@c _dimmed or @c _off).
---
--- @returns the new tile definition.
function morelights_dim.create_dim_tile(tile, state)
    local texture_string = (type(tile) == "table") and tile.name or tile;

    -- Replace occurences of textures_to_dim with `(...^[multiply:color)`.
    -- ^ and : need to be escaped with backslash, if the occurence
    -- is an argument for a modifier like [combine.
    for part, multipliers in pairs(morelights_dim.textures_to_dim) do
        texture_string = morelights_dim.texture_multiply_parts(texture_string,
                                                               part,
                                                               multipliers[state]);
    end

    if type(tile) == "table" then
        local new_tile = table.copy(tile);
        new_tile.name = texture_string;
        return new_tile;
    else
        return texture_string;
    end
end

dofile(minetest.get_modpath("morelights_dim") .. "/api.lua");
