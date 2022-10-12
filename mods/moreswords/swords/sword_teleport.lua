local ability_ware = 5000
local ability_cooldown = 10

minetest.register_tool("moreswords:sword_teleport",{
description = "Teleportation Sword",
inventory_image = "sword_teleport.png",
stack_max = 1,
tool_capabilities = {
      full_punch_interval = 2.0,
      damage_groups = {fleshy = 5},
    },
    groupcaps={
            snappy={times={[1]=1.90, [2]=0.90, [3]=0.30}, uses=40, maxlevel=3},
            },
groups = {sword = 1},

on_secondary_use=function(itemstack,user,pointed_thing)
  if is_attackable(pointed_thing) then
    run_cooldown("moreswords:sword_teleport",user,ability_cooldown, function()
      local object = pointed_thing.ref
      local pos = object:get_pos()
      object:set_pos({x=pos.x,y=pos.y+15,z=pos.z})
      itemstack:add_wear(ability_ware)
    end)
else
  return
 end
 return itemstack
end,

})
minetest.register_craft({
  type = "shaped",
  output = "moreswords:sword_teleport",
recipe = {
  {"","",""},
  {"default:obsidian","default:sword_diamond","default:obsidian"},
  {"","",""},
},
})
