--dofile(minetest.get_modpath("automobiles_buggy") .. DIR_DELIM .. "buggy_global_definitions.lua")
--dofile(minetest.get_modpath("automobiles_buggy") .. DIR_DELIM .. "buggy_hud.lua")

-- destroy the buggy
function buggy.destroy(self, puncher)
    automobiles_lib.remove_light(self)
    if self.sound_handle then
        minetest.sound_stop(self.sound_handle)
        self.sound_handle = nil
    end

    if self.driver_name then
        -- detach the driver first (puncher must be driver)
        if puncher then
            puncher:set_detach()
            puncher:set_eye_offset({x = 0, y = 0, z = 0}, {x = 0, y = 0, z = 0})
            if minetest.global_exists("player_api") then
                player_api.player_attached[self.driver_name] = nil
                -- player should stand again
                player_api.set_animation(puncher, "stand")
            end
        end
        self.driver_name = nil
    end

    local pos = self.object:get_pos()

    if self.rag then self.rag:remove() end
    if self.front_suspension then self.front_suspension:remove() end
    if self.lf_wheel then self.lf_wheel:remove() end
    if self.rf_wheel then self.rf_wheel:remove() end
    if self.rear_suspension then self.rear_suspension:remove() end
    if self.lr_wheel then self.lr_wheel:remove() end
    if self.rr_wheel then self.rr_wheel:remove() end
    if self.steering then self.steering:remove() end
    if self.steering_axis then self.steering_axis:remove() end
    if self.driver_seat then self.driver_seat:remove() end
    if self.passenger_seat then self.passenger_seat:remove() end
    if self.fuel_gauge then self.fuel_gauge:remove() end
    if self.lights then self.lights:remove() end
    if self.r_lights then self.r_lights:remove() end

    automobiles_lib.destroy_inventory(self)
    self.object:remove()

    pos.y=pos.y+2

    --minetest.add_item({x=pos.x+math.random()-0.5,y=pos.y,z=pos.z+math.random()-0.5},'automobiles_buggy:buggy')
    minetest.add_item({x=pos.x+math.random()-0.5,y=pos.y,z=pos.z+math.random()-0.5},'automobiles_lib:engine')
    minetest.add_item({x=pos.x+math.random()-0.5,y=pos.y,z=pos.z+math.random()-0.5},'automobiles_buggy:wheel')
    minetest.add_item({x=pos.x+math.random()-0.5,y=pos.y,z=pos.z+math.random()-0.5},'automobiles_buggy:wheel')
    minetest.add_item({x=pos.x+math.random()-0.5,y=pos.y,z=pos.z+math.random()-0.5},'automobiles_buggy:wheel')
    minetest.add_item({x=pos.x+math.random()-0.5,y=pos.y,z=pos.z+math.random()-0.5},'automobiles_buggy:wheel')
end

