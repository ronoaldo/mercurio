-- SPDX-FileCopyrightText: 2021 David Hurka <doxydoxy@mailbox.org>
--
-- SPDX-License-Identifier: CC0-1.0 OR MIT
--
--- Registers texture parts @p texture_file to be multiplied with
--- @p dimmed_multiplier or @p off_multiplier when making dimmed variants.
---
--- @p dimmed_multiplier and @p off_multiplier will be inserted into
--- a `(...^[multiply:...)` texture modifier.
--- Both multipliers may be ommited to use the default multipliers.
function morelights_dim.register_texture_for_dimming(texture_file,
                                                     dimmed_multiplier,
                                                     off_multiplier)
    morelights_dim.textures_to_dim[texture_file] = {
        _dimmed = dimmed_multiplier or "#dddddd",
        _off = off_multiplier or "#a5a5a5",
    };
end

--- Registers the tool @p tool_name to change the light level
--- if used with right-click on a light node.
---
--- For not registered tools,
--- the original on_rightclick() handler will be called instead.
function morelights_dim.register_light_level_tool(tool_name)
    morelights_dim.light_level_tools[tool_name] = true;
end

--- Registers a dimmed and an off variant of the node @p node_name.
---
--- The original node is modified so that a right-click with
--- the correct tool changes it to the dim variant.
--- The dim variant changes to the off variant at right-click,
--- and the off variant changes back to normal.
---
--- The dim and off variants drop the normal variant when destroyed,
--- and do not appear in the creative inventory.
---
--- The dim and off variants have darkened textures for the light texture
--- parts as specified with morelights_dim.register_texture_to_dim().
---
--- The original node needs to be a light source.
---
--- @example
--- @code
--- morelights_dim.register_texture_for_dimming(
---     "morelights_vintage_block.png", "#dddddd", #a5a5a5);
--- morelights_dim.register_light_level_tool("morelights:bulb");
--- morelights_dim.make_dim_variant("morelights_vintage:block");
--- morelights_dim.make_dim_variant("morelights_vintage:smallblock");
--- [...]
--- @endcode
function morelights_dim.register_dim_variants(node_name)
    local override_def, dim_def, off_def =
            morelights_dim.make_dim_variants(node_name);
    if override_def then
        minetest.override_item(node_name, override_def);
        minetest.register_node(":" .. node_name .. "_morelights_dim_dimmed",
                               dim_def);
        minetest.register_node(":" .. node_name .. "_morelights_dim_off",
                               off_def);
    end
end

--- Creates the node (override) definitions which would be used
--- by morelights_dim.register_dim_variants().
---
--- You can use these to do additional modifications to the node definitions.
--- This may be necessary e. g. to tweak drawing of seasonally colored grass
--- or whatever.
---
--- The node definitions will have the field @c _morelights_dim_next_variant,
--- where it is assumed that the nodes will be called by the schema
--- `:..._morelights_dim_dimmed` and `:..._morelights_dim_off`.
---
--- @returns override_def, dim_def, off_def, original_def
function morelights_dim.make_dim_variants(node_name)
    local name_dimmed = node_name .. "_morelights_dim_dimmed";
    local name_off = node_name .. "_morelights_dim_off";

    local original_def = minetest.registered_nodes[node_name];
    if not original_def then
        minetest.log("warning",
                     "morelights_dim.make_dim_variant(): " .. node_name ..
                             " is not a registered node.");
        return;
    end

    if not (original_def.light_source and original_def.light_source > 0) then
        minetest.log("error",
                     "morelights_dim.make_dim_variant(): " .. node_name ..
                             " is not a light source.");
        return; -- TODO Check if this check even works.
    end

    -- Update normal variant.
    local override_def = {};
    override_def._morelights_dim_next_variant = name_dimmed;
    override_def.on_rightclick = morelights_dim.create_on_rightclick_handler(
                                         original_def.on_rightclick);

    -- Create dim variant.
    local dim_def = table.copy(original_def);
    dim_def._morelights_dim_next_variant = name_off;
    dim_def.on_rightclick = morelights_dim.create_on_rightclick_handler(
                                    original_def.on_rightclick);
    dim_def.drop = original_def.drop or node_name;
    dim_def.groups = dim_def.groups or {};
    dim_def.groups.not_in_creative_inventory = 1;
    dim_def.light_source =
            morelights_dim.dimmed_light_level[original_def.light_source];

    -- Generate textures for dim variant.
    for _, tile_type in ipairs({ "tiles", "overlay_tiles", "special_tiles" }) do
        if (type(original_def[tile_type]) == "table") then
            dim_def[tile_type] = {};
            for i, tile in pairs(original_def[tile_type]) do
                dim_def[tile_type][i] = morelights_dim.create_dim_tile(tile,
                                                                       "_dimmed");
            end
        end
    end

    -- Create off variant.
    local off_def = table.copy(original_def);
    off_def._morelights_dim_next_variant = node_name;
    off_def.on_rightclick = morelights_dim.create_on_rightclick_handler(
                                    original_def.on_rightclick);
    off_def.drop = original_def.drop or node_name;
    off_def.groups = off_def.groups or {};
    off_def.groups.not_in_creative_inventory = 1;
    off_def.light_source = 0;

    -- Generate textures for dim variant.
    for _, tile_type in ipairs({ "tiles", "overlay_tiles", "special_tiles" }) do
        if (type(original_def[tile_type]) == "table") then
            off_def[tile_type] = {};
            for i, tile in pairs(original_def[tile_type]) do
                off_def[tile_type][i] = morelights_dim.create_dim_tile(tile,
                                                                       "_off");
            end
        end
    end

    return override_def, dim_def, off_def, original_def;
end
