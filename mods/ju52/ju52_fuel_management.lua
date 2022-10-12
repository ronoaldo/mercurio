dofile(minetest.get_modpath("ju52") .. DIR_DELIM .. "ju52_global_definitions.lua")

function ju52.contains(table, val)
    for k,v in pairs(table) do
        if k == val then
            return v
        end
    end
    return false
end

function ju52.loadFuel(self, player_name)
    local player = minetest.get_player_by_name(player_name)
    local inv = player:get_inventory()

    local itmstck=player:get_wielded_item()
    local item_name = ""
    if itmstck then item_name = itmstck:get_name() end

    local fuel = ju52.contains(airutils.fuel, item_name)
    if fuel then
        local stack = ItemStack(item_name .. " 1")

        if self._energy < JU52_MAX_FUEL then
            inv:remove_item("main", stack)
            self._energy = self._energy + fuel
            if self._energy > JU52_MAX_FUEL then self._energy = JU52_MAX_FUEL end
        end
        
        return true
    end

    return false
end

function ju52.consumptionCalc(self, accel)
    if accel == nil then return end
    if self._energy > 0 and self._engine_running and accel ~= nil then
        local consumed_power = self._power_lever/200000
        --minetest.chat_send_all('consumed: '.. consumed_power)
        self._energy = self._energy - consumed_power;
    end
    if self._energy <= 0 and self._engine_running and accel ~= nil then
        self._engine_running = false
        self._autopilot = false
        if self.sound_handle then minetest.sound_stop(self.sound_handle) end
	    self.engine:set_animation_frame_speed(0)
    end
end
