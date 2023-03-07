-- Restore Silver and Mithril hoes
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

-- Restore Aviation Device old Recipe
local gold_ingot = "default:gold_ingot"
local diamond = "default:diamond"
local diamondblock = "default:diamondblock"
minetest.clear_craft({output='aviator:aviator'})
minetest.register_craft({
    output = 'aviator:aviator',
    recipe = {
        {gold_ingot, diamond,      gold_ingot},
        {diamond,    diamondblock, diamond},
        {gold_ingot, diamond,      gold_ingot},
    }
})

-- Restore Granite recipe
local tar = "group:tar_block"
local marble = "group:marble"
minetest.register_craft({
    output = "technic:granite 9",
    recipe = {
        { tar,    marble, tar },
        { marble, tar,    marble },
        { tar,    marble, tar }
    },
})
