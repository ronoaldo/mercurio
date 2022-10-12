local ability_ware = 5000
local ability_cooldown = 10

minetest.register_tool("moreswords:sword_lava",{
description="Lava Sword",
inventory_image="sword_lava.png",
stack_max = 1,
tool_capabilities = {
      full_punch_interval = 1.0,
      damage_groups = {fleshy = 6},
    },
    groupcaps={
            snappy={times={[1]=1.90, [2]=0.90, [3]=0.30}, uses=40, maxlevel=3},
            },
groups = {sword = 1},

on_secondary_use=function(itemstack,user,pointed_thing)
    run_cooldown("moreswords:sword_lava",user,ability_cooldown, function()
  node_name = 'default:lava_source'
  place_above_pointed(pointed_thing, node_name)
  itemstack:add_wear(ability_ware)
end)
return itemstack
end,
})

register_midas_touch(
"moreswords:sword_lava",
"default:lava_source",
minetest.get_modpath(modname)..'/schematics/midas_touch_lava.mts'
)

minetest.register_craft({
  type = "shaped",
  output = "moreswords:sword_lava",
recipe = {
  {"","",""},
  {"bucket:bucket_lava","default:sword_diamond","bucket:bucket_lava"},
  {"","",""},
},
})
