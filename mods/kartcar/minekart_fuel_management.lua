--
-- fuel
--

function minekart.contains(table, val)
    for k,v in pairs(table) do
        if k == val then
            return v
        end
    end
    return false
end

function minekart.loadFuel(self, player_name, free)
    free = free or false

    local player = minetest.get_player_by_name(player_name)
    local inv = player:get_inventory()

    local itmstck=player:get_wielded_item()
    local item_name = ""
    if itmstck then item_name = itmstck:get_name() end

    local fuel = minekart.contains(minekart.fuel, item_name)
    if fuel or free == true then
        local stack = ItemStack(item_name .. " 1")
        if self._energy < 1 then
            if free == false then inv:remove_item("main", stack) end
            if fuel then
                self._energy = self._energy + fuel
            else
                self._energy = 1
            end
            if self._energy > 1 then self._energy = 1 end
            minekart.last_fuel_display = 0
            if self._energy == 1 then minetest.chat_send_player(player_name, "Full tank!") end
        end
        
        return true
    end

    return false
end
