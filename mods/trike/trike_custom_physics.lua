local abs = math.abs

function trike.physics(self)
    local friction = 0.99
	local vel=self.object:get_velocity()
		-- dumb friction
	if self.isonground and not self.isinliquid then
        --minetest.chat_send_all('okay')
        vel = {x=vel.x*friction, y=vel.y, z=vel.z*friction}
		self.object:set_velocity(vel)
	end
	
	-- bounciness
	if self.springiness and self.springiness > 0 then
        vel=self.object:get_velocity()
		local vnew = vector.new(vel)
		
		if not self.collided then						-- ugly workaround for inconsistent collisions
			for _,k in ipairs({'y','z','x'}) do
				if vel[k]==0 and abs(self.lastvelocity[k])> 0.1 then
					vnew[k]=-self.lastvelocity[k]*self.springiness
				end
			end
		end
		
		if not vector.equals(vel,vnew) then
			self.collided = true
		else
			if self.collided then
				vnew = vector.new(self.lastvelocity)
			end
			self.collided = false
		end
		
		self.object:set_velocity(vnew)
	end
    
    --local accel = self._last_accell
    --self.object:set_acceleration(accel)
end
