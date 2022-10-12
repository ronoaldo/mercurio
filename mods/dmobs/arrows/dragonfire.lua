--function to register tamed dragon attacks

function dmobs.register_fire(fname, texture, dmg, replace_node, explode,
		ice, variance, size)

	minetest.register_entity(fname, {
		textures = {texture},
		velocity = 0.1,
		damage = dmg,
		collisionbox = {0, 0, 0, 0, 0, 0},
		on_step = function(self, obj, pos)

			local remove = minetest.after(2, function()
				self.object:remove()
			end)

			local pos = self.object:get_pos()
			local objs = minetest.get_objects_inside_radius({x=pos.x,y=pos.y,z=pos.z}, 2)

				for k, obj in pairs(objs) do

					if obj:get_luaentity() ~= nil then

						if obj:get_luaentity().name ~= fname
						and obj:get_luaentity().name ~= "dmobs:dragon_red"
						and obj:get_luaentity().name ~= "dmobs:dragon_blue"
						and obj:get_luaentity().name ~= "dmobs:dragon_black"
						and obj:get_luaentity().name ~= "dmobs:dragon_green"
						and obj:get_luaentity().name ~= "dmobs:dragon_great_tame"
						and obj:get_luaentity().name ~= "__builtin:item" then

							obj:punch(self.launcher, 1.0, {
								full_punch_interval = 1.0,
								damage_groups={fleshy = 3},
							}, nil)

							self.object:remove()
						end
					end
				end

				for dx = 0, 1 do
					for dy = 0, 1 do
						for dz = 0, 1 do

							local p = {x=pos.x+dx, y=pos.y, z=pos.z+dz}
							local t = {x=pos.x+dx, y=pos.y+dy, z=pos.z+dz}
							local n = minetest.get_node(p).name

							if n ~= fname and n ~="default:dirt_with_grass"
							and n ~="default:dirt_with_dry_grass"
							and n ~="default:stone" then

								if minetest.registered_nodes[n].groups.flammable then

									minetest.set_node(t, {name=replace_node})
									self.object:remove()
									return
								end

								if ice and n == "default:water_source" then
									minetest.set_node(t, {name="default:ice"})
									self.object:remove()
								end
							end
						end
					end
				end

				local apos = self.object:get_pos()

				if not apos then return end

				minetest.add_particlespawner({
					amount = 6,
					time = 0.3,
					minpos = {x=apos.x-variance, y=apos.y-variance, z=apos.z-variance},
					maxpos = {x=apos.x+variance, y=apos.y+variance, z=apos.z+variance},
					minvel = {x=-0, y=-0, z=-0},
					maxvel = {x=0, y=0, z=0},
					minacc = {x=variance,y=-0.5-variance,z=variance},
					maxacc = {x=0.5+variance,y=0.5+variance,z=0.5+variance},
					minexptime = 0.1,
					maxexptime = 0.3,
					minsize = size,
					maxsize = size+2,
					collisiondetection = false,
					texture = texture
				})
		end
	})
end

dmobs.register_fire("dmobs:fire_plyr", "dmobs_fire.png", 2,
		"fire:basic_flame", true, false, 0.3, 1)

dmobs.register_fire("dmobs:ice_plyr", "dmobs_ice.png", 2,
		"default:ice", false, true, 0.5, 10)

dmobs.register_fire("dmobs:poison_plyr", "dmobs_poison.png", 2,
		"air", false, false, 0.3, 1)

dmobs.register_fire("dmobs:lightning_plyr", "dmobs_lightning.png", 2,
		"air", true, false, 0, 0.5)
