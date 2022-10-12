local ability_ware = 5000
local ability_cooldown = 10

minetest.register_tool("moreswords:sword_pick",{
  description = "Pick Sword",
  inventory_image = "sword_pick.png",
  --stack_max = 1,
  tool_capabilities = {
        full_punch_interval = 1.0,
        damage_groups = {fleshy = 5},
      },
      groupcaps={
                  snappy={times={[1]=1.90, [2]=0.90, [3]=0.30}, uses=40, maxlevel=3},
                  cracky = {times={[3]=1.60}, uses=10, maxlevel=1},
                  },

  groups = {sword = 1,pickaxe=1},

  on_secondary_use=function(itemstack,user,pointed_thing)
    if is_attackable(pointed_thing) then
      run_cooldown("moreswords:sword_pick",user,ability_cooldown, function()
      local dig_depth = 15

      local object = pointed_thing.ref
      local pos = object:get_pos()
      local below = {x=pos.x-1, y=pos.y-1,z=pos.z-1}
      local schem = minetest.get_modpath(modname)..'/schematics/replace_air.mts'

      schem_pos = below
      for i=schem_pos.y, below.y-dig_depth,-1 do
       minetest.place_schematic(schem_pos,schem)
       schem_pos.y = i
     end
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
  output = "moreswords:sword_pick",
recipe = {
  {"","",""},
  {"default:pick_diamond","default:sword_diamond",""},
  {"","",""},
},
})
