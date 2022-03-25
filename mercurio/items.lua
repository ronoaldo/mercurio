local stick = "default:stick"
local silver_ingot = "moreores:silver_ingot"
local mithril_ingot = "moreores:mithril_ingot"

minetest.register_craft({
    type = "shaped",
    output = "moreores:hoe_silver 1",
    recipe = {
        {silver_ingot, silver_ingot, ""},
        {"",           stick,        ""},
        {"",           stick,        ""}
    }
})

minetest.register_craft({
    type = "shaped",
    output = "moreores:hoe_mithril 1",
    recipe = {
        {mithril_ingot, mithril_ingot, ""},
        {"",            stick,        ""},
        {"",            stick,        ""}
    }
})