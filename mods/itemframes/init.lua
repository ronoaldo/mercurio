
screwdriver = screwdriver or {}

local tmp = {}
local should_return_item = minetest.settings:get_bool("itemframes.return_item", false)

-- item entity

minetest.register_entity("itemframes:item",{
	hp_max = 1,
	visual = "wielditem",
	visual_size = {x = 0.33, y = 0.33},
	collisionbox = {0, 0, 0, 0, 0, 0},
	physical = false,
	textures = {"air"},
	static_save = false,

	on_activate = function(self, staticdata)

		if tmp.nodename ~= nil
		and tmp.texture ~= nil then

			self.nodename = tmp.nodename
			tmp.nodename = nil
			self.texture = tmp.texture
			tmp.texture = nil
			self.glow = tmp.glow
			tmp.glow = nil
		else
			if staticdata ~= nil
			and staticdata ~= "" then

				local data = staticdata:split(";")

				if data and data[1] and data[2] then

					self.nodename = data[1]
					self.texture = data[2]
					self.glow = data[3]
				end
			end
		end

		if self.texture ~= nil then
			self.object:set_properties({textures = {self.texture}})
		end

		if self.nodename == "itemframes:pedestal" then
			self.object:set_properties({automatic_rotate = 1})
		end

		if self.glow ~= nil then
			self.object:set_properties({glow = self.glow})
		end
	end,

	get_staticdata = function(self)

		if self.nodename ~= nil
		and self.texture ~= nil then
			return self.nodename .. ";" .. self.texture .. ";" .. (self.glow or "")
		end

		return ""
	end,

	on_blast = function(self, damage)
		return false, false, {}
	end
})

-- helper table

local facedir = {
	[0] = {x = 0, y = 0, z = 1},
	[12] = {x = 0, y = 0, z = 1},
	[16] = {x = 0, y = 0, z = 1},
	[20] = {x = 0, y = 0, z = 1},

	[1] = {x = 1, y = 0, z = 0},
	[5] = {x = 1, y = 0, z = 0},
	[9] = {x = 1, y = 0, z = 0},
	[23] = {x = 1, y = 0, z = 0},

	[2] = {x = 0, y = 0, z = -1},
	[14] = {x = 0, y = 0, z = -1},
	[18] = {x = 0, y = 0, z = -1},
	[22] = {x = 0, y = 0, z = -1},

	[3] = {x = -1, y = 0, z = 0},
	[7] = {x = -1, y = 0, z = 0},
	[11] = {x = -1, y = 0, z = 0},
	[21] = {x = -1, y = 0, z = 0},

	[4] = -0.4, -- flat frames
	[10] = -0.4,
	[13] = -0.4,
	[19] = -0.4,

	[8] = 0.4, -- upside down flat frames
	[6] = 0.4,
	[15] = 0.4,
	[17] = 0.4
}

-- remove entities

local remove_item = function(pos, nodename)

	local ypos = 0

	if nodename == "itemframes:pedestal" then
		ypos = 1
	end

	local objs = minetest.get_objects_inside_radius({
			x = pos.x, y = pos.y + ypos, z = pos.z}, 0.5)

	if objs then

		for _, obj in pairs(objs) do

			if obj and obj:get_luaentity()
			and obj:get_luaentity().name == "itemframes:item" then
				obj:remove()
			end
		end
	end
end

-- update entity

local update_item = function(pos, node)

	remove_item(pos, node.name)

	local meta = minetest.get_meta(pos)

	if not meta then return end

	local item = meta:get_string("item")

	if item == "" then return end

	local pitch = 0
	local p2 = node.param2

	if node.name == "itemframes:frame"
	or node.name == "itemframes:frame_invis" then

		local posad = facedir[p2]

		if not posad then return end

		if type(posad) == "table" then
			pos.x = pos.x + posad.x * 6.5 / 16
			pos.y = pos.y + posad.y * 6.5 / 16
			pos.z = pos.z + posad.z * 6.5 / 16
		else
			pitch = 4.7
			pos.y = pos.y + posad
		end

	elseif node.name == "itemframes:pedestal" then

		pos.y = pos.y + 12 / 16 + 0.33
	end

	tmp.nodename = node.name
	tmp.texture = ItemStack(item):get_name()

	local def = core.registered_items[item]

	tmp.glow = def and def.light_source

	local e = minetest.add_entity(pos,"itemframes:item")

	if node.name == "itemframes:frame"
	or node.name == "itemframes:frame_invis" then

		--local yaw = math.pi * 2 - node.param2 * math.pi / 2
		local yaw = 6.28 - p2 * 1.57

		e:set_rotation({
			x = pitch, -- pitch
			y = yaw, -- yaw
			z = 0 -- roll
		})
	end
end

-- remove entity and drop as item

local drop_item = function(pos, nodename, metadata)

	local meta = metadata or minetest.get_meta(pos)

	if not meta then return end

	local item = meta:get_string("item")

	meta:set_string("item", "")

	if item ~= "" then

		remove_item(pos, nodename)

		if nodename == "itemframes:pedestal" then
			pos.y = pos.y + 1
		end

		minetest.add_item(pos, item)
	end
end

-- return item to a player's inventory

local return_item = function(pos, nodename, metadata, clicker, itemstack)

	local meta = metadata or minetest.get_meta(pos)

	if not meta then return end

	local item = meta:get_string("item")

	if item == "" then return end

	local remaining = itemstack:add_item(item)

	if remaining:is_empty() then

		meta:set_string("item", "")

		remove_item(pos, nodename)

		return itemstack
	end

	local inv = clicker:get_inventory()

	if not inv then

		drop_item(pos, nodename, metadata)

		return
	end

	remaining = inv:add_item("main", remaining)

	if remaining:is_empty() then

		meta:set_string("item", "")

		remove_item(pos, nodename)
	else
		drop_item(pos, nodename, metadata)
	end
end

-- on_place helper function

local frame_place = function(itemstack, placer, pointed_thing)

	if pointed_thing.type ~= "node" then return end

	local above = pointed_thing.above
	local under = pointed_thing.under
	local dir = {
		x = under.x - above.x,
		y = under.y - above.y,
		z = under.z - above.z
	}

	local wdir = minetest.dir_to_wallmounted(dir)
	local placer_pos = placer:get_pos()

	if placer_pos then
		dir = {
			x = above.x - placer_pos.x,
			y = above.y - placer_pos.y,
			z = above.z - placer_pos.z
		}
	end

	local fdir = minetest.dir_to_facedir(dir)
	local p2 = fdir

	if wdir == 0 then
		p2 = 8
	elseif wdir == 1 then
		p2 = 4
	end

	return minetest.item_place(itemstack, placer, pointed_thing, p2)
end

-- itemframe node and recipe

minetest.register_node("itemframes:frame",{
	description = "Item frame",
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {-0.5, -0.5, 7/16, 0.5, 0.5, 0.5}
	},
	selection_box = {
		type = "fixed",
		fixed = {-0.5, -0.5, 7/16, 0.5, 0.5, 0.5}
	},
	tiles = {"itemframes_frame.png"},
	inventory_image = "itemframes_frame.png",
	wield_image = "itemframes_frame.png",
	paramtype = "light",
	paramtype2 = "facedir",
	sunlight_propagates = true,
	groups = {choppy = 2, dig_immediate = 2, flammable = 2},
	sounds = default.node_sound_defaults(),

	on_place = frame_place,

	after_place_node = function(pos, placer, itemstack)

		local meta = minetest.get_meta(pos)

		meta:set_string("infotext","Item frame (right-click to add or remove item)")
	end,

	on_rightclick = function(pos, node, clicker, itemstack)

		if not itemstack
		or minetest.is_protected(pos, clicker:get_player_name()) then
			return
		end

		local meta = minetest.get_meta(pos)

		if not meta then return end

		if meta:get_string("item") ~= "" then

			if should_return_item then
				return return_item(pos, node.name, meta, clicker, itemstack)
			else
				drop_item(pos, node.name, meta)
			end
		else
			local s = itemstack:take_item()

			meta:set_string("item", s:to_string())

			update_item(pos, node)

			return itemstack
		end
	end,

	on_destruct = function(pos)
		drop_item(pos, "itemframes:frame")
	end,

	on_punch = function(pos, node, puncher)
		update_item(pos, node)
	end,

	on_blast = function(pos, intensity)

		drop_item(pos, "itemframes:frame")

		minetest.add_item(pos, {name = "itemframes:frame"})

		minetest.remove_node(pos)
	end,

	on_burn = function(pos)

		drop_item(pos, "itemframes:frame")

		minetest.remove_node(pos)
	end
})

minetest.register_craft({
	output = "itemframes:frame",
	recipe = {
		{"default:stick", "default:stick", "default:stick"},
		{"default:stick", "default:paper", "default:stick"},
		{"default:stick", "default:stick", "default:stick"}
	}
})

-- invisible itemframe node and recipe

minetest.register_node("itemframes:frame_invis",{
	description = "Invisible Item frame",
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {-0.5, -0.5, 7/16, 0.5, 0.5, 0.5}
	},
	selection_box = {
		type = "fixed",
		fixed = {-0.5, -0.5, 7/16, 0.5, 0.5, 0.5}
	},
	tiles = {"itemframes_clear.png"},
	inventory_image = "itemframes_frame_invis.png",
	wield_image = "itemframes_frame_invis.png",
	paramtype = "light",
	paramtype2 = "facedir",
	sunlight_propagates = true,
	use_texture_alpha = "clip",
	groups = {choppy = 2, dig_immediate = 2, flammable = 2},
	sounds = default.node_sound_defaults(),

	on_place = frame_place,

	after_place_node = function(pos, placer, itemstack)

		local meta = minetest.get_meta(pos)

		meta:set_string("infotext","Item frame (right-click to add or remove item)")
	end,

	on_rightclick = function(pos, node, clicker, itemstack)

		if not itemstack
		or minetest.is_protected(pos, clicker:get_player_name()) then
			return
		end

		local meta = minetest.get_meta(pos)

		if not meta then return end

		if meta:get_string("item") ~= "" then

			if should_return_item then
				return return_item(pos, node.name, meta, clicker, itemstack)
			else
				drop_item(pos, node.name, meta)
			end
		else
			local s = itemstack:take_item()

			meta:set_string("item", s:to_string())

			update_item(pos, node)

			return itemstack
		end
	end,

	on_destruct = function(pos)
		drop_item(pos, "itemframes:frame_invis")
	end,

	on_punch = function(pos, node, puncher)
		update_item(pos, node)
	end,

	on_blast = function(pos, intensity)

		drop_item(pos, "itemframes:frame_invis")

		minetest.add_item(pos, {name = "itemframes:frame"})

		minetest.remove_node(pos)
	end,

	on_burn = function(pos)

		drop_item(pos, "itemframes:frame_invis")

		minetest.remove_node(pos)
	end
})

minetest.register_craft({
	output = "itemframes:frame_invis",
	recipe = {
		{"default:glass", "default:glass", "default:glass"},
		{"default:glass", "default:paper", "default:glass"},
		{"default:glass", "default:glass", "default:glass"}
	}
})

-- pedestal node and recipe

minetest.register_node("itemframes:pedestal",{
	description = "Pedestal",
	drawtype = "nodebox",
	node_box = {
		type = "fixed", fixed = {
			{-7/16, -8/16, -7/16, 7/16, -7/16, 7/16}, -- bottom plate
			{-6/16, -7/16, -6/16, 6/16, -6/16, 6/16}, -- bottom plate (upper)
			{-0.25, -6/16, -0.25, 0.25, 11/16, 0.25}, -- pillar
			{-7/16, 11/16, -7/16, 7/16, 12/16, 7/16}, -- top plate
		}
	},
	selection_box = {
		type = "fixed",
		fixed = {-7/16, -0.5, -7/16, 7/16, 12/16, 7/16}
	},
	tiles = {"itemframes_pedestal.png"},
	paramtype = "light",
	groups = {cracky = 3},
	sounds = default.node_sound_defaults(),
	on_rotate = screwdriver.disallow,

	after_place_node = function(pos, placer, itemstack)

		local meta = minetest.get_meta(pos)

		meta:set_string("infotext","Pedestal (right-click to add or remove item)")
	end,

	on_rightclick = function(pos, node, clicker, itemstack)

		if not itemstack
		or minetest.is_protected(pos, clicker:get_player_name()) then
			return
		end

		local meta = minetest.get_meta(pos)

		if not meta then return end

		if meta:get_string("item") ~= "" then

			if should_return_item then
				return return_item(pos, node.name, meta, clicker, itemstack)
			else
				drop_item(pos, node.name, meta)
			end
		else

			local s = itemstack:take_item()

			meta:set_string("item", s:to_string())

			update_item(pos, node)

			return itemstack
		end
	end,

	on_destruct = function(pos)
		drop_item(pos, "itemframes:pedestal")
	end,

	on_punch = function(pos, node, puncher)
		update_item(pos, node)
	end,

	on_blast = function(pos, intensity)

		drop_item(pos, "itemframes:pedestal")

		minetest.add_item(pos, {name = "itemframes:pedestal"})

		minetest.remove_node(pos)
	end
})

minetest.register_craft({
	output = "itemframes:pedestal",
	recipe = {
		{"default:stone", "default:stone", "default:stone"},
		{"", "default:stone", ""},
		{"default:stone", "default:stone", "default:stone"}
	}
})

-- automatically restore entities lost from frames/pedestals
-- due to /clearobjects or similar

minetest.register_lbm({
	label = "Restore itemframe entities",
	name = "itemframes:restore_entities",
	nodenames = {"itemframes:frame", "itemframes:pedestal", "itemframes:frame_invis"},
	run_at_every_load = true,

	action = function(pos, node)

		local ypos = 0

		if node.name == "itemframes:pedestal" then
			ypos = 1
		end

		pos.y = pos.y + ypos

		local objs = minetest.get_objects_inside_radius(pos, 0.5)

		for _, obj in ipairs(objs) do

			local e = obj:get_luaentity()

			if e and e.name == "itemframes:item" then
				return
			end
		end

		pos.y = pos.y - ypos

		update_item(pos, node)
	end
})

-- stop mesecon pistons from pushing itemframe and pedestals

if minetest.get_modpath("mesecons_mvps") then
	mesecon.register_mvps_stopper("itemframes:frame")
	mesecon.register_mvps_stopper("itemframes:frame_invis")
	mesecon.register_mvps_stopper("itemframes:pedestal")
end
