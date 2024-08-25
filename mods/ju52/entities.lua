
--
-- entity
--

ju52.vector_up = vector.new(0, 1, 0)

minetest.register_entity('ju52:wheels',{
initial_properties = {
	physical = false,
	collide_with_objects=false,
	pointable=false,
	visual = "mesh",
    backface_culling = false,
	mesh = "ju52_wheels.b3d",
	textures = {
            "airutils_metal.png", --suporte bequilha
            ju52.skin_texture, --suporte trem
            "airutils_black.png", --pneu bequilha
            "airutils_metal.png", --roda bequilha
            "airutils_black.png", --pneu trem
            "airutils_metal.png", --roda trem
        },
	},
	
    on_activate = function(self,std)
	    self.sdata = minetest.deserialize(std) or {}
	    if self.sdata.remove then self.object:remove() end
    end,
	    
    get_staticdata=function(self)
      self.sdata.remove=true
      return minetest.serialize(self.sdata)
    end,
	
})

minetest.register_entity('ju52:cabin_interactor',{
    initial_properties = {
	    physical = true,
	    collide_with_objects=true,
        collisionbox = {-1, 0, -1, 1, 3, 1},
	    visual = "mesh",
	    mesh = "airutils_seat_base.b3d",
        textures = {"airutils_alpha.png",},
	},
    dist_moved = 0,
    max_hp = 65535,
	
    on_activate = function(self,std)
	    self.sdata = minetest.deserialize(std) or {}
	    if self.sdata.remove then self.object:remove() end
    end,
	    
    get_staticdata=function(self)
      self.sdata.remove=true
      return minetest.serialize(self.sdata)
    end,

    on_punch = function(self, puncher, ttime, toolcaps, dir, damage)
        --minetest.chat_send_all("punch")
        if not puncher or not puncher:is_player() then
            return
        end
    end,

    on_rightclick = function(self, clicker)
        local name = clicker:get_player_name()
        local parent_obj = self.object:get_attach()
        if not parent_obj then return end
        local parent_self = parent_obj:get_luaentity()
        local copilot_name = nil
        if parent_self.co_pilot and parent_self._have_copilot then
            copilot_name = parent_self.co_pilot
        end
        
        if name == parent_self.driver_name then
            local itmstck=clicker:get_wielded_item()
            local item_name = ""
            if itmstck then item_name = itmstck:get_name() end
            --adf program function
            if (item_name == "compassgps:cgpsmap_marked") then
                local meta = minetest.deserialize(itmstck:get_metadata())
                if meta then
                    parent_self._adf_destiny = {x=meta["x"], z=meta["z"]}
                end
            else
                --formspec of the plane
                if not parent_self._custom_pilot_formspec then
                    airutils.pilot_formspec(name)
                else
                    parent_self._custom_pilot_formspec(name)
                end
                airutils.sit(clicker)
            end
        --=========================
        --  detach copilot
        --=========================
        elseif name == copilot_name then
            if parent_self._command_is_given then
                --open the plane menu for the copilot
                --formspec of the plane
                if not parent_self._custom_pilot_formspec then
                    airutils.pilot_formspec(name)
                else
                    parent_self._custom_pilot_formspec(name)
                end
            else
                airutils.pax_formspec(name)
            end
        end
    end,

})

minetest.register_entity('ju52:ju52',
    airutils.properties_copy(ju52.plane_properties)
)

