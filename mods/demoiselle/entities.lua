
--
-- entity
--

demoiselle.vector_up = vector.new(0, 1, 0)

minetest.register_entity('demoiselle:wheels',{
initial_properties = {
	physical = false,
	collide_with_objects=false,
	pointable=false,
	visual = "mesh",
    backface_culling = false,
	mesh = "demoiselle_wheels.b3d",
    --visual_size = {x = 3, y = 3, z = 3},
	textures = {
            "demoiselle_black.png", -- pneu
            "demoiselle_metal.png", -- aro rodas
            "demoiselle_wheel.png", -- raio rodas
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

minetest.register_entity("demoiselle:demoiselle", 
    airutils.properties_copy(demoiselle.plane_properties)
)
