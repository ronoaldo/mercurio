local ability_ware = 5000
local ability_cooldown = 10

minetest.register_tool("moreswords:sword_smoke",{
description = "Smoke Sword",
inventory_image = "sword_smoke.png",
stack_max = 1,
 tool_capabilities = {
   full_punch_interval = 1.5,
damage_groups = {fleshy = 1},
},
groupcaps={
          snappy={times={[1]=1.90, [2]=0.90, [3]=0.30}, uses=40, maxlevel=3},
          },

groups = {sword = 1},

on_secondary_use=function(itemstack, user, pointed_thing)
  if is_attackable(pointed_thing) then
    run_cooldown("moreswords:sword_smoke",user,ability_cooldown, function()
      local object = pointed_thing.ref
      local pos = object:get_pos()
     smoke_particles(pos)
     itemstack:add_wear(ability_ware)
   end)
  else
    return
 end
 return itemstack
end,
})

function smoke_particles(pos)
  minetest.add_particlespawner({
          amount = 2000,
          time = 10,
  minpos = {x=pos.x-3, y=pos.y-3, z=pos.z-3},
  maxpos = {x=pos.x+3, y=pos.y+3, z=pos.z+3},
  minvel = {x=0.2, y=0.2, z=0.2},
  maxvel = {x=0.5, y=0.8, z=0.5},
  minacc = {x=-0.2,y=0,z=-0.2},
  maxacc = {x=0.4,y=0.2,z=0.4},
  minexptime = 6,
  maxexptime = 8,
  minsize = 10,
          maxsize = 12,
          collisiondetection = false,
          vertical = false,
  texture = "tnt_smoke.png",
  playername = player,
})
end

minetest.register_craft({
  type = "shaped",
  output = "moreswords:sword_smoke",
recipe = {
  {"","",""},
  {"tnt:tnt_stick","default:sword_diamond",""},
  {"","",""},
},
})
