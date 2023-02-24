--settings
local lr_height = tonumber(minetest.settings:get("lr_height")) or 30
local lr_renew = minetest.settings:get_bool("lr_renew", false)

--registering priv
minetest.register_privilege("spill", {description = "Able to use all liquids.", give_to_singleplayer=false})

--this list only contains items not autmotically filled in.
--this should be replaced with a more agnostic solution at a later date
local liquid_list = {
    --technic cans
    "technic:lava_can",
    "technic:water_can",
    --buckets
    "bucket:bucket_lava",
    "bucket:bucket_water",
    "bucket:bucket_river_water",
    "fl_bucket:bucket_water",
    "fl_bucket:bucket_river_water",
    "fl_bucket:bucket_lava",
    --bucket_wooden
    "bucket_wooden:bucket_water",
    "bucket_wooden:bucket_river_water",
}

--function for handling priv settings
local function priv_selection(default_priv, setting)
    local priv = minetest.settings:get(setting)

    if not minetest.registered_privileges[priv] then
        return default_priv
    else
        return priv
    end
end

--reads list, overrides nodes, adding priv check
local function override()
    for liquidcount = 1, #liquid_list do
        --checks if its a valid node/item
        if minetest.registered_items[liquid_list[liquidcount]] then
            --get old on_place behavior
            local old_place = minetest.registered_items[liquid_list[liquidcount]].on_place or function() end

            --override
            minetest.override_item(liquid_list[liquidcount], {
                on_place = function(itemstack, placer, pointed_thing)
                    local pname = placer:get_player_name()
                    local default_priv = priv_selection("spill", "lr_default")
                    local advanced_priv = priv_selection("server", "lr_advanced")

                    if not minetest.check_player_privs(pname, priv_selection(default_priv, "lr_default")) then
                        minetest.chat_send_player(
                            pname,
                            "[Liquid Restriction]: " .. default_priv .. " priv required to use this node"
                        )
                        return
                    else
                        if (minetest.get_pointed_thing_position(pointed_thing).y > lr_height) then
                            if not (minetest.check_player_privs(pname, priv_selection("server", "lr_advanced"))) then
                                minetest.chat_send_player(
                                    pname,
                                    "[Liquid Restriction]: " .. advanced_priv .. " priv requid at this height"
                                )
                                return
                            end
                        end
                        return old_place(itemstack, placer, pointed_thing)
                    end
                end,
                --prevents liquids from spreading
                liquid_renewable = lr_renew,
            })
        end
    end

    --disables water from being used with the replacer tool, as that bypasses the spill priv
    if minetest.get_modpath("replacer") then
        for _, name in pairs(liquid_list) do
            replacer.blacklist[name] = true;
        end
    end
end

minetest.register_on_mods_loaded(function()
    for name, def in pairs(minetest.registered_nodes) do
        if def.drawtype and (def.drawtype == "liquid" or def.drawtype == "flowingliquid")
        and minetest.get_item_group(name, "liquid_blacklist") == 0 then
            table.insert(liquid_list, name)
        end
    end

    override()
end)
