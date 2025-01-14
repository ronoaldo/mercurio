
--
-- entity
--

pa28.vector_up = vector.new(0, 1, 0)

minetest.register_entity('pa28:wheels',{
initial_properties = {
	physical = false,
	collide_with_objects=false,
	pointable=false,
	visual = "mesh",
    backface_culling = false,
	mesh = "pa28_wheels.b3d",
	textures = {
        "airutils_black.png", --pneus traseiros
        "airutils_metal.png", --rodas traseiras
        "airutils_black.png", --pneu dianteiro
        "airutils_metal.png", --rodas dianteira
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

minetest.register_entity('pa28:p_lights',{
    initial_properties = {
	    physical = false,
	    collide_with_objects=false,
	    pointable=false,
        glow = 0,
	    visual = "mesh",
	    mesh = "pa28_lights.b3d",
        textures = {
                        "pa28_l_light.png", --luz posicao
                        "pa28_l_light.png", --luz posicao esq
                        "pa28_r_light.png", --luz posicao dir
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

minetest.register_entity('pa28:light',{
    initial_properties = {
	    physical = false,
	    collide_with_objects=false,
	    pointable=false,
        glow = 0,
	    visual = "mesh",
	    mesh = "pa28_light.b3d",
        textures = {
                "pa28_metal.png",
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

minetest.register_entity('pa28:pa28',
    airutils.properties_copy(pa28.plane_properties)
)

