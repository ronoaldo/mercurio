-- Remove entities
local function clear_selection(user)
        if mesecons_autotools.users[user] == nil then
                mesecons_autotools.users[user] = {}                
        end
        if mesecons_autotools.users[user].entities == nil then
                mesecons_autotools.users[user].entities = {}
        end
        
        
        
        for _,v in pairs(mesecons_autotools.users[user].entities) do
                v:remove()
        end
        mesecons_autotools.users[user].entities = {}
        
        
end


-- Register entities 
minetest.register_entity(":mesecons_autotools:pos1", {
        initial_properties = {
                visual = "cube",
                visual_size = {x=1.11, y=1.11, },
                textures = {"pos1.png", "pos1.png",
                        "pos1.png", "pos1.png",
                        "pos1.png", "pos1.png"},
                collisionbox = {-0.55, -0.55, -0.55, 0.55, 0.55, 0.55},
                physical = false,
                static_save = false,
        },
        on_activate = function(self, staticdata, dtime_s)
        end,
        
        on_punch = function(self,hitter)
        end,
        on_blast = function(self, damage)
                return false, false, {} -- don't damage or knockback
        end,
})
minetest.register_entity(":mesecons_autotools:pos2", {
        initial_properties = {
                visual = "cube",
                visual_size = {x=1.1, y=1.1},
                textures = {"pos2.png", "pos2.png",
                        "pos2.png", "pos2.png",
                        "pos2.png", "pos2.png"},
                collisionbox = {-0.55, -0.55, -0.55, 0.55, 0.55, 0.55},
                physical = false,
                static_save = false,                        
        },
        on_activate = function(self, staticdata, dtime_s)
        end,
        
        on_punch = function(self,hitter)
        end,
      
        on_blast = function(self, damage)
                return false, false, {} -- don't damage or knockback
        end,
})
minetest.register_entity(":mesecons_autotools:wall", {
      	initial_properties = {
		visual = "upright_sprite",
		textures = {"wall.png"},
		visual_size = {x=10, y=10},
		physical = false,
		static_save = false,
	},
        on_activate = function(self, staticdata, dtime_s)
        end,
        
        on_punch = function(self,hitter)
        end,
      
        on_blast = function(self, damage)
                return false, false, {} -- don't damage or knockback
        end,
})

minetest.register_entity(":mesecons_autotools:pos", {
        initial_properties = {
                visual = "cube",
                visual_size = {x=1.1, y=1.1},
                textures = {"pos.png", "pos.png",
                        "pos.png", "pos.png",
                        "pos.png", "pos.png"},
                collisionbox = {-0.55, -0.55, -0.55, 0.55, 0.55, 0.55},
                physical = false,
                static_save = false,                        
        },
        on_activate = function(self, staticdata, dtime_s)
        end,
        
        on_punch = function(self,hitter)
        end,
      
        on_blast = function(self, damage)
                return false, false, {} -- don't damage or knockback
        end,
})

--[[ not used: TODO remove
local function generate_corners(user)
        local pos = {}
        pos[1] = mesecons_autotools.get_pos(user,1)
        pos[2] = mesecons_autotools.get_pos(user,2)
        
        if pos[1] == nil then return end
        if pos[2] == nil then return end
        
        
        local list = {}
        for xi = 1,2 do
                for yi = 1,2 do
                        for zi = 1,2 do                                
                                local p = { x = pos[xi].x , y = pos[yi].y , z = pos[zi].z } 
                                if not vector.equals(p,pos[1]) then                                         
                                        table.insert(list,p)
                                end
                        end
                end
        end
        return list
end
]]--


local function show_selection(user)
        local pos1 = mesecons_autotools.get_pos(user,1)
        local pos2 = mesecons_autotools.get_pos(user,2)
        
        if pos1 ~= nil  then
                local e1 = minetest.add_entity(pos1,"mesecons_autotools:pos1")
                table.insert(mesecons_autotools.users[user].entities, e1)
        end
        
        if pos2 ~= nil then
                local e2 = minetest.add_entity(pos2,"mesecons_autotools:pos2")
                table.insert(mesecons_autotools.users[user].entities, e2)
        end
        
        
        
end



mesecons_autotools.render = function(user)
        clear_selection(user)
        show_selection(user)
end



