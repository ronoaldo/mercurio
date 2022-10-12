local ability_ware = 5000
local ability_cooldown = 10

minetest.register_tool("moreswords:sword_ice",{
description="Ice Sword",
inventory_image="sword_ice.png",
stack_max = 1,
tool_capabilities = {
      full_punch_interval = 2.0,
      damage_groups = {fleshy = 5},
    },
groupcaps={
        snappy={times={[1]=1.90, [2]=0.90, [3]=0.30}, uses=40, maxlevel=3},
        },
groups = {sword=1},

on_secondary_use=function(itemstack,user,pointed_thing)
  if is_attackable(pointed_thing) then
    run_cooldown("moreswords:sword_ice",user,ability_cooldown, function()
    local object = pointed_thing.ref
    local pos = object:get_pos()
    object:set_pos({x=pos.x,y=pos.y+1,z=pos.z})

    local schem = minetest.get_modpath(modname).."/schematics/prison_ice.mts"
    schem_pos = {x=pos.x-1,y=pos.y,z=pos.z-1}
    minetest.place_schematic(schem_pos,schem)
    itemstack:add_wear(ability_ware)
  end)
  end
  return itemstack
end,
})

register_midas_touch(
"moreswords:sword_ice",
"default:water_source",
minetest.get_modpath(modname)..'/schematics/midas_touch_ice.mts'
)

minetest.register_craft({
  type = "shaped",
  output = "moreswords:sword_ice",
recipe = {
  {"","",""},
  {"default:ice","default:sword_diamond","default:ice"},
  {"","",""},
},
})
