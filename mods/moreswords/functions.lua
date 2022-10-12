function is_attackable(pointed_thing)
  if pointed_thing.type ~= "object" then
    return
  end
  -- sets object var
  local object = pointed_thing.ref

  if not object:is_player() then
    return
  end
  return true
end

function place_above_pointed(pointed_thing, node_name)
  if is_attackable(pointed_thing) then
    local object = pointed_thing.ref
    local pos = object:get_pos()
  pos.y = pos.y + 2
  minetest.set_node(pos,{name=node_name})
else
  return
end
end

function register_midas_touch(wield_item,target_node,schematic_path)
  minetest.register_globalstep(function(dtime)
          for _, player in pairs(minetest.get_connected_players()) do
                  local player_name = player:get_player_name()
                  local wstack = player:get_wielded_item()
                  local wname = wstack:get_name()

                if wname == wield_item then
                  local pos = player:getpos()
                  local below = {x=pos.x,y=pos.y-1,z=pos.z}

                  if minetest.get_node(below).name == target_node then
                   minetest.place_schematic(below,schematic_path)
                  end
                 end
            end
  end)
end

function run_cooldown(id,player,duration, func)
  local player_name = player:get_player_name()
  if cooldown[id] == nil then
  cooldown[id] = {}
end
  if cooldown[id][player_name] == nil or cooldown[id][player_name] == 0.0 then
    func()
      cooldown[id][player_name] = duration
      minetest.after(duration,function()
        cooldown[id][player_name] = 0.0
        minetest.chat_send_player(player_name, string.format("%s %s", id," Cooldown is up"))
      end)
  else
    return
  end
    return cooldown[id][player_name]
end
