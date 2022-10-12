--local abr = minetest.get_mapgen_setting('active_block_range')

local pi = math.pi
local random = math.random
local min = math.min
local max = math.max
local abs = math.abs
local floor = math.floor

local deg=math.deg
local rad=math.rad

local vct = vector

-- constants
local SAIL_ROT_RATE = 4	
local WIND_FACTOR = 0.05
local RUDDER_LIMIT = 30	-- degrees
local RUDDER_TURN_RATE = rad(12)
local LONGIT_DRAG_FACTOR = 0.13*0.13
local LATER_DRAG_FACTOR = 2.0
local ROLL_RATE = rad(2)
local ROLL_FACTOR=0.1

local modpath = minetest.get_modpath('sailing_kit')
dofile(modpath ..'/regstuff.lua')
dofile(modpath ..'/wind.lua')

local function dot(v1,v2)
	return v1.x*v2.x+v1.y*v2.y+v1.z*v2.z
end

local function sign(n)
	return n>=0 and 1 or -1
end

local function minmax(v,m)
	return min(abs(v),m)*sign(v)
end

local function get_wind()
	return wind.wind
end

local boat_activation = function(self,std)
--	self.object:set_rotation({x=0,y=pi,z=0})
--	self.object:set_velocity({x=0,y=0,z=0.5})

	self.sheet_limit=90
	self.rudder_angle = 0
	local pos = self.object:get_pos()
	local mast=minetest.add_entity(pos,'sailing_kit:mast')
	local sail=minetest.add_entity(pos,'sailing_kit:sail')
	local sailcolor = mobkit.recall(self,'sailcolor')
	if sailcolor then
		sail:set_properties({textures={"sail.png^[multiply:".. sailcolor}})
	end
	local rudder=minetest.add_entity(pos,'sailing_kit:rudder')
	mast:set_attach(self.object,'',{x=0,y=8,z=4},{x=0,y=0,z=0})
	sail:set_attach(mast,'',{x=0,y=0,z=0},{x=0,y=0,z=0})
	rudder:set_attach(self.object,'',{x=0,y=0,z=-26},{x=0,y=0,z=0})
	self.mast = mast
	self.sail = sail
	self.rudder = rudder
	self.sail_set = false
	self.sail_timer = minetest.get_us_time()
end

local destroy=function(self)
	local pos = self.object:get_pos()
	if self.mast then self.mast:remove() end
	if self.sail then self.sail:remove() end
	if self.rudder then self.rudder:remove() end
	self.object:remove()
	pos.y=pos.y+2
	for i=1,3 do
		minetest.add_item({x=pos.x+random()-0.5,y=pos.y,z=pos.z+random()-0.5},'default:wood')
	end	
	for i=1,9 do
		minetest.add_item({x=pos.x+random()-0.5,y=pos.y,z=pos.z+random()-0.5},'farming:string')
	end	
end

local sailstep = function(self)
	if self.hp <= 0 then 
		destroy(self) 
		return
	end
	
--	local dtime = min(self.dtime,0.5)
	local accel_y = self.object:get_acceleration().y
	if not self.mast then return end
	local _,_,spos,sailrot = self.mast:get_attach()
	
	if sailrot then
		local wind = get_wind()
		local vel = self.object:get_velocity()
		wind = {x=wind.x - vel.x,y=0,z=wind.z-vel.z}
		local rotation = self.object:get_rotation()
		local pitch = rotation.x
		local newpitch = pitch
		local yaw = rotation.y
		local newyaw=yaw
		local roll = rotation.z
		local newroll=roll
		
		local hdir = minetest.yaw_to_dir(yaw)		-- hull direction unit vector
		local nhdir = {x=hdir.z,y=0,z=-hdir.x}		-- lateral unit vector
		
		local longit_speed = dot(vel,hdir)
		local longit_drag = vct.multiply(hdir,longit_speed*longit_speed*LONGIT_DRAG_FACTOR*-1*sign(longit_speed))
		local later_speed = dot(vel,nhdir)
		local later_drag = vct.multiply(nhdir,later_speed*later_speed*LATER_DRAG_FACTOR*-1*sign(later_speed))
		local accel = vct.add(longit_drag,later_drag)
		local rudder_angle = self.rudder_angle
		
--		local _,_,spos,sailrot = self.mast:get_attach()
		
		-- player control
		if self.driver then
			local plyr = minetest.get_player_by_name(self.driver)
			if plyr then			
				local ctrl = plyr:get_player_control()
				-- sail
				if self.sail_set then
					if ctrl.up then
						self.sheet_limit = min(self.sheet_limit+15*self.dtime,90)
					elseif ctrl.down then
--						self.sheet_limit = max(self.sheet_limit-7*dtime,0)
						self.sheet_limit = max(abs(sailrot.y)-15*self.dtime,0)
					end
				else	-- paddle
					local paddleacc
					if longit_speed < 1.0 and ctrl.up then
						paddleacc = 0.5
					elseif longit_speed >  -1.0 and ctrl.down then
						paddleacc = -0.5
					end
					if paddleacc then accel=vct.add(accel,vct.multiply(hdir,paddleacc)) end
				end
				
				if ctrl.jump and minetest.get_us_time()>self.sail_timer+500000 then
					self.sail_timer = minetest.get_us_time()
					if self.sail_set then
						self.sail_set = false
						self.sail:set_properties({is_visible=false})
					else
						self.sail_set = true
						self.sail:set_properties({is_visible=true})
					end					
				end
				-- rudder
				if ctrl.right then
					rudder_angle = max(self.rudder_angle-20*self.dtime,-RUDDER_LIMIT)
				elseif ctrl.left then
					rudder_angle = min(self.rudder_angle+20*self.dtime,RUDDER_LIMIT)
				end	
			end
		end
		
		-- move rudder
		if rudder_angle ~= self.rudder_angle then
			self.rudder_angle = rudder_angle
			self.rudder:set_attach(self.object,'',{x=0,y=0,z=-26},{x=0,y=self.rudder_angle,z=0})
		end
		if abs(self.rudder_angle)>5 then 
--			newyaw = yaw+dtime*RUDDER_TURN_RATE*longit_speed*self.rudder_angle/30 
--			newyaw = yaw+dtime*(1-1/(longit_speed*0.5+1))*self.rudder_angle/30*RUDDER_TURN_RATE
			newyaw = yaw+self.dtime*(1-1/(abs(longit_speed)+1))*self.rudder_angle/30*RUDDER_TURN_RATE*sign(longit_speed)
		end
		
		if self.sail_set then
			-- get sail direction
--			local _,_,spos,sailrot = self.mast:get_attach()
			local syaw = yaw - rad(sailrot.y)
			local sdir = minetest.yaw_to_dir(syaw)
			local snormal = {x=sdir.z,y=0,z=-sdir.x}	-- rightside, dot is negative
			-- wind force on sail
			local wsforce =  dot(wind,snormal)
			
			-- turn sail
			local tight = false
			local newsailrot = sailrot.y - wsforce*SAIL_ROT_RATE*self.dtime
			if abs(newsailrot) >= self.sheet_limit then			-- it is tight
				newsailrot = self.sheet_limit * sign(newsailrot)
				tight = true
			end
			self.mast:set_attach(self.object,'',spos,{x=0,y=newsailrot,z=0})
			
			if tight then	-- sail exerts force on the hull
				local forcevec = vct.multiply(snormal,wsforce*wsforce*WIND_FACTOR*sign(wsforce))
				accel=vct.add(accel,forcevec)
				
						-- lateral pressure
				local prsr = dot(forcevec,nhdir)
--				newroll = prsr*rad(ROLL_FACTOR)
				newroll = (1-1/(prsr*ROLL_FACTOR+1)) * rad(90)	  -- poor man's arctan
			else
				newroll = 0
			end
		else
			newroll=0
		end
		
		local bob = minmax(dot(accel,hdir),1)	-- vertical bobbing
		
		if self.isinliquid then
			accel.y = accel_y+bob
			newpitch = vel.y * rad(6)
			self.object:set_acceleration(accel)
		end
		
		if abs(newroll-roll)>ROLL_RATE*self.dtime then newroll=roll+ROLL_RATE*self.dtime*sign(newroll-roll) end
		if newroll~=roll or newyaw~=yaw or newpitch~=pitch then self.object:set_rotation({x=newpitch,y=newyaw,z=newroll}) end
		
		-- workaround for broken attachments
		if random()>0.95 then self.sail:set_attach(self.mast,'',{x=0,y=0,z=0},{x=0,y=0,z=0}) end
	end
end

local colors ={
black='#4C4C4C',
blue='#99CEFF',
brown='#D5B695',
cyan='#B2FFFF',
dark_green='#7FB263',
dark_grey='#999999',
green='#B3FFB2',
grey='#CCCCCC',
magenta='#FFB2E0',
orange='#FFDD99',
pink='#FFD8D8',
red='#FFB2B2',
violet='#DCB2FF',
white='#FFFFFF',
yellow='#FFFF80',
}

local paint_sail=function(self,puncher,ttime, toolcaps, dir, damage)
	if puncher:is_player() then
		local itmstck=puncher:get_wielded_item()
		if itmstck then
			local name=itmstck:get_name()
			local _,indx = name:find('dye:')
			if indx then
				local color = name:sub(indx+1)
				local colstr = colors[color]
-- minetest.chat_send_all(color ..' '.. dump(colstr))
				if colstr then
					self.sail:set_properties({textures={"sail.png^[multiply:".. colstr}})
					mobkit.remember(self,'sailcolor',colstr)
					itmstck:set_count(itmstck:get_count()-1)
					puncher:set_wielded_item(itmstck)
				end
			else -- deal damage
				if not self.driver and toolcaps and toolcaps.damage_groups and toolcaps.damage_groups.fleshy then
					mobkit.hurt(self,toolcaps.damage_groups.fleshy - 1)
					mobkit.make_sound(self,'hit')
				end
			end	
		end
	end
end

minetest.register_entity('sailing_kit:boat',{
--[[ initial_properties = {
	physical = true,
	collisionbox = {-0.6, -0.8, -0.6, 0.6, 0.9, 0.6},
	visual = "mesh",
	mesh = "sailboat_hull.obj",
	textures = {"default_wood.png"},
},	--]]

	physical = true,
	collisionbox = {-0.6, -0.8, -0.6, 0.6, 0.9, 0.6},
	makes_footstep_sound = true,
	visual = "mesh",
	mesh = "sailboat_hull.obj",
	textures = {"default_wood.png"},
	
	water_drag = 0,		-- handled by object's own logic.
	buoyancy = 0.45,
	sounds={
		hit = 'default_dig_choppy'
		},

on_rightclick=function(self, clicker)
	if clicker:get_attach() == nil then
--		clicker:set_attach(self.object,'',{x=20,y=3,z=0},{x=0,y=0,z=0})
		clicker:set_attach(self.object,'',{x=-3,y=2,z=-21},{x=0,y=0,z=0})
		clicker:set_eye_offset({x=0,y=0,z=-20},{x=0,y=0,z=-5})
		player_api.player_attached[clicker:get_player_name()] = true
		minetest.after(0.2, function()
			player_api.set_animation(clicker, "sit" , 30)
		end)
		self.driver = clicker:get_player_name()
	else
		clicker:set_detach()
		player_api.player_attached[clicker:get_player_name()] = false
		clicker:set_eye_offset({x=0,y=0,z=0},{x=0,y=0,z=0})
		player_api.set_animation(clicker, "stand" , 30)
		self.driver = nil
	end
end,

on_step = mobkit.stepfunc,
logic = sailstep,

on_activate=function(self,std)
	mobkit.actfunc(self,std)
	boat_activation(self,std)
end,

get_staticdata = mobkit.statfunc,

on_punch = paint_sail,

})

minetest.register_entity('sailing_kit:mast',{
initial_properties = {
	physical = true,
	pointable=false,
	visual = "mesh",
	mesh = "mast01.obj",
	textures = {"default_junglewood.png"},
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

minetest.register_entity('sailing_kit:sail',{
initial_properties = {
	physical = false,
	collide_with_objects = false,
	pointable=false,
	is_visible=false,
	visual = "mesh",
	mesh = "sail01.obj",
	textures = {"sail.png^[multiply:#FFEBCC"},
--	textures = {"sail.png^[colorize:#FFE1B2:alpha"},
	backface_culling = false,
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

--[[
minetest.register_entity('sailing_kit:seat',{
initial_properties = {
	physical = true,
	collisionbox = {-0.8, 0, -0.8, 0.8, 0.05, 0.8},
	visual = "mesh",
	mesh = "sailboat_seat.obj",
	textures = {"default_wood.png"},
	},
	
on_activate = function(self,std)
	self.sdata = minetest.deserialize(std) or {}
	if self.sdata.remove then self.object:remove() end
end,
	
get_staticdata=function(self)
  	
  self.sdata.remove=true
  return minetest.serialize(self.sdata)
end,
	
})	--]]

minetest.register_entity('sailing_kit:rudder',{
initial_properties = {
	physical = false,
	collide_with_objects=false,
	pointable=false,
	visual = "mesh",
	mesh = "rudder.obj",
	textures = {"default_junglewood.png"},
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

minetest.register_on_chat_message(
	function(name, message)
		if message == 'doit' then
--			local plyr = minetest.get_player_by_name('singleplayer')
			local plyr = minetest.get_player_by_name(name)
			local pos = plyr:get_pos()
			pos.y = pos.y-0.01
			minetest.chat_send_all(minetest.get_biome_name(minetest.get_biome_data(pos).biome))
		end
	end
)