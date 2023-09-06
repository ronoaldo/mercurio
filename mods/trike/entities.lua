
--
-- entity
--

trike.vector_up = vector.new(0, 1, 0)

minetest.register_entity('trike:pointer',{
initial_properties = {
	physical = false,
	collide_with_objects=false,
	pointable=false,
	visual = "mesh",
	mesh = "trike_pointer.b3d",
    visual_size = {x = 0.4, y = 0.4, z = 0.4},
	textures = {"trike_grey.png"},
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

minetest.register_entity('trike:wheels',{
initial_properties = {
	physical = false,
	collide_with_objects=false,
	pointable=false,
	visual = "mesh",
    backface_culling = false,
	mesh = "trike_wheels.b3d",
    --visual_size = {x = 3, y = 3, z = 3},
    textures = {"trike_black.png", "trike_metal.png", "trike_black.png", "trike_metal.png",},
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

minetest.register_entity("trike:trike", 
    airutils.properties_copy(trike.plane_properties)
)
