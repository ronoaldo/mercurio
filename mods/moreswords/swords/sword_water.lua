local ability_ware = 5000
local ability_cooldown = 5

minetest.register_tool("moreswords:sword_water",{
description="Water Sword",
inventory_image="sword_water.png",
stack_max = 1,
tool_capabilities = {
      full_punch_interval = 3.0,
      damage_groups = {fleshy = 7},
    },
    groupcaps={
            snappy={times={[1]=1.90, [2]=0.90, [3]=0.30}, uses=40, maxlevel=3},
            },
groups = {sword = 1},
on_secondary_use=function(itemstack,user,pointed_thing)
  run_cooldown("moreswords:sword_water",user,ability_cooldown, function()
  node_name = 'default:water_source'
  place_above_pointed(pointed_thing, node_name)
  itemstack:add_wear(ability_ware)
end)
return itemstack
end,
})
minetest.register_craft({
  type = "shaped",
  output = "moreswords:sword_water",
recipe = {
{"","",""},
{"bucket:bucket_water","default:sword_wood","bucket:bucket_water"},
{"","",""},
},
})
