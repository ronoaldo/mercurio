local S = minetest.get_translator("whitelist")

minetest.register_on_prejoinplayer(function(name, ip)

  if not whitelist.is_whitelist_enabled() then return end

  if not whitelist.is_player_whitelisted(name) then
    return S("You're not whitelisted!")                   -- this doesn't currently work
  end

end)
