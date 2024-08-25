local screwdriver = screwdriver or {}
local tmp = {}
local should_return_item = minetest.settings:get_bool("itemframes.return_item", false)
local log_actions = minetest.settings:get_bool("itemframes.log_actions", false)
local allow_rotate = minetest.settings:get_bool("itemframes.allow_rotate", false)

-- voxelibre/mineclonia support
local mcl = minetest.get_modpath("mcl_sounds")
local a = {
	paper = mcl and "mcl_core:paper" or "default:paper",
	glass = mcl and "mcl_core:glass" or "default:glass",
	stick = "group:stick",
	stone = "group:stone"
}

local sounds = nil

if minetest.get_modpath("default") then
	sounds = default.node_sound_defaults()
elseif mcl then
	sounds = mcl_sounds.node_sound_defaults()
end

-- translation support

local S = minetest.get_translator("itemframes")

-- item entity

minetest.register_entity("itemframes:item", {

	initial_properties = {
		hp_max = 1,
		visual = "wielditem",
		visual_size = {x = 0.33, y = 0.33},
		collisionbox = {0, 0, 0, 0, 0, 0},
		physical = false,
		textures = {"air"}
	},

	on_activate = function(self, staticdata)

		local pos = self.object:get_pos() ; if not pos then return end
		local objs = minetest.get_objects_inside_radius(pos, 0.5)
--		local found_any = false

		for _, obj in ipairs(objs) do

			if obj ~= self.object then

				local e = obj:get_luaentity()

				if e and e.name == "itemframes:item" then

--					if found_any then
						obj:remove() -- remove duplicates
--					else
--						found_any = true
--					end
				end
			end
		end

--		if found_any then
--			self.object:remove()
--			return
--		end

		if tmp.nodename and tmp.texture then

			self.nodename = tmp.nodename ; 	tmp.nodename = nil
			self.texture = tmp.texture ; tmp.texture = nil
			self.glow = tmp.glow ; tmp.glow = nil
		else
			if staticdata and staticdata ~= "" then

				local data = staticdata:split(";")

				if data and data[1] and data[2] then

					self.nodename = data[1]
					self.texture = data[2]
					self.glow = data[3]
				end
			end
		end

		if self.texture then

			local def = minetest.registered_items[self.texture]

			if def and def._itemframe_texture
			and self.nodename ~= "itemframes:pedestal" then

				self.object:set_properties({
					textures = {def._itemframe_texture},
					visual = "upright_sprite",
					visual_size = {x = 0.6, y = 0.6}
				})
			else
				self.object:set_properties({textures = {self.texture}})
			end
		end

		if self.nodename == "itemframes:pedestal" then
			self.object:set_properties({automatic_rotate = 1})
		end

		if self.glow then
			self.object:set_properties({glow = self.glow})
		end
	end,

	get_staticdata = function(self)

		if self.nodename and self.texture then
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
	[0] = {x = 0, y = 0, z = 1, pitch = 0, yaw = 0, roll = 0, nx = 12},
	[12] = {x = 0, y = 0, z = 1, pitch = 0, yaw = 0, roll = 3, nx = 16},
	[16] = {x = 0, y = 0, z = 1, pitch = 0, yaw = 0, roll = 1, nx = 20},
	[20] = {x = 0, y = 0, z = 1, pitch = 0, yaw = 0, roll = 2, nx = 0},

	[1] = {x = 1, y = 0, z = 0, pitch = 0, yaw = 1, roll = 0, nx = 5},
	[5] = {x = 1, y = 0, z = 0, pitch = 0, yaw = 1, roll = 1, nx = 9},
	[9] = {x = 1, y = 0, z = 0, pitch = 0, yaw = 1, roll = 3, nx = 23},
	[23] = {x = 1, y = 0, z = 0, pitch = 0, yaw = 1, roll = 2, nx = 1},

	[2] = {x = 0, y = 0, z = -1, pitch = 0, yaw = 2, roll = 0, nx = 14},
	[14] = {x = 0, y = 0, z = -1, pitch = 0, yaw = 2, roll = 1, nx = 18},
	[18] = {x = 0, y = 0, z = -1, pitch = 0, yaw = 2, roll = 3, nx = 22},
	[22] = {x = 0, y = 0, z = -1, pitch = 0, yaw = 2, roll = 2, nx = 2},

	[3] = {x = -1, y = 0, z = 0, pitch = 0, yaw = 3, roll = 0, nx = 7},
	[7] = {x = -1, y = 0, z = 0, pitch = 0, yaw = 3, roll = 3, nx = 11},
	[11] = {x = -1, y = 0, z = 0, pitch = 0, yaw = 3, roll = 1, nx = 21},
	[21] = {x = -1, y = 0, z = 0, pitch = 0, yaw = 3, roll = 2, nx = 3},

	[4] = {x = 0, y = -1, z = 0, pitch = -4.7, yaw = 0, roll = 0, nx = 10},
	[10] = {x = 0, y = -1, z = 0, pitch = -4.7, yaw = 2, roll = 0, nx = 13},
	[13] = {x = 0, y = -1, z = 0, pitch = -4.7, yaw = 1, roll = 0, nx = 19},
	[19] = {x = 0, y = -1, z = 0, pitch = -4.7, yaw = 3, roll = 0, nx = 4},

	[8] = {x = 0, y = 1, z = 0, pitch = -4.7, yaw = 0, roll = 0, nx = 6},
	[6] = {x = 0, y = 1, z = 0, pitch = -4.7, yaw = 2, roll = 0, nx = 15},
	[15] = {x = 0, y = 1, z = 0, pitch = -4.7, yaw = 3, roll = 0, nx = 17},
	[17] = {x = 0, y = 1, z = 0, pitch = -4.7, yaw = 1, roll = 0, nx = 8},
}

-- remove entities

local remove_item = function(pos, ntype)

	local ypos = 0

	if ntype == "pedestal" then
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

local update_item = function(pos, ntype, node)

	remove_item(pos, ntype)

	local meta = minetest.get_meta(pos)

	if not meta then return end

	local item = meta:get_string("item")

	if item == "" then return end

	local pitch, yaw, roll = 0, 0, 0

	if ntype == "frame" then

		local p2 = node.param2
		local adjust = facedir[p2]

		if not adjust then return end

		local raise = 6.5 / 16 -- itemframe default

		if node and node.name == "itemframes:frame_invis" then
			raise = 6.5 / 14 -- stops floating effect
		end

		pos.x = pos.x + adjust.x * raise
		pos.y = pos.y + adjust.y * raise
		pos.z = pos.z + adjust.z * raise

		pitch = adjust.pitch
		yaw = 6.28 - adjust.yaw * 1.57 -- math.pi/2
		roll = 6.28 - adjust.roll * 1.57

	elseif ntype == "pedestal" then

		pos.y = pos.y + 1.08
	end

	tmp.nodename = node.name
	tmp.texture = ItemStack(item):get_name()

	local def = core.registered_items[item]

	tmp.glow = def and def.light_source

	local e = minetest.add_entity(pos, "itemframes:item")

	if not e then
		tmp.nodename = nil
		tmp.texture = nil
		tmp.glow = nil
		return
	end

	if ntype == "frame" then

		e:set_rotation({x = pitch, y = yaw, z = roll})
	end
end

-- remove entity and drop as item

local drop_item = function(pos, ntype, metadata)

	local meta = metadata or minetest.get_meta(pos)

	if not meta then return end

	local item = meta:get_string("item")

	meta:set_string("item", "")

	if item ~= "" then

		remove_item(pos, ntype)

		if ntype == "pedestal" then
			pos.y = pos.y + 1
		end

		minetest.add_item(pos, item)
	end
end

-- return item to a player's inventory

local return_item = function(pos, ntype, metadata, clicker, itemstack)

	local meta = metadata or minetest.get_meta(pos)

	if not meta then return end

	local item = meta:get_string("item")

	if item == "" then return end

	local remaining = itemstack:add_item(item)

	if remaining:is_empty() then

		meta:set_string("item", "")

		remove_item(pos, ntype)

		return itemstack
	end

	local inv = clicker:get_inventory()

	if not inv then

		drop_item(pos, ntype, metadata)

		return
	end

	remaining = inv:add_item("main", remaining)

	if remaining:is_empty() then

		meta:set_string("item", "")

		remove_item(pos, ntype)
	else
		drop_item(pos, ntype, metadata)
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

-- action logging helper
local function show_msg(message)

	if log_actions then
		minetest.log("action", message)
	end
end

-- itemframe node and recipe

minetest.register_node("itemframes:frame",{
	description = S("Item frame"),
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
	groups = {choppy = 2, dig_immediate = 2, flammable = 2, handy = 1, axey = 1},
	sounds = sounds,
	_mcl_hardness = 0.5,

	on_place = frame_place,

	after_place_node = function(pos, placer, itemstack)

		local meta = minetest.get_meta(pos)

		meta:set_string("infotext", S("Right-click to add or remove item"))
	end,

	on_rightclick = function(pos, node, clicker, itemstack)

		if not itemstack
		or minetest.is_protected(pos, clicker:get_player_name()) then
			return
		end

		local meta = minetest.get_meta(pos)

		if not meta then return end

		if meta:get_string("item") ~= "" then

			show_msg(clicker:get_player_name()
				.. " removed " .. meta:get_string("item")
				.. " from Itemframe at " .. minetest.pos_to_string(pos))

			if should_return_item then
				return return_item(pos, "frame", meta, clicker, itemstack)
			else
				drop_item(pos, "frame", meta)
			end

		else
			local s = itemstack:take_item()

			meta:set_string("item", s:to_string())

			update_item(pos, "frame", node)

			show_msg(clicker:get_player_name()
				.. " inserted " .. meta:get_string("item")
				.. " into Itemframe at " .. minetest.pos_to_string(pos))

			return itemstack
		end
	end,

	on_destruct = function(pos)
		drop_item(pos, "frame")
	end,

	on_punch = function(pos, node, puncher)

		-- rotate item inside frame when holding sneak and punching
		if puncher and puncher:get_player_control().sneak
		and (allow_rotate or not minetest.is_protected(pos, puncher:get_player_name())) then

			local p2 = node.param2
			local nx = facedir[p2].nx

			minetest.swap_node(pos, {name = node.name, param2 = nx})
			node.param2 = nx
		end

		update_item(pos, "frame", node)
	end,

	on_blast = function(pos, intensity)

		drop_item(pos, "frame")

		minetest.add_item(pos, {name = "itemframes:frame"})

		minetest.remove_node(pos)
	end,

	on_burn = function(pos)

		drop_item(pos, "frame")

		minetest.remove_node(pos)
	end
})

minetest.register_craft({
	output = "itemframes:frame",
	recipe = {
		{ a.stick, a.stick, a.stick },
		{ a.stick, a.paper, a.stick },
		{ a.stick, a.stick, a.stick }
	}
})

-- invisible itemframe node and recipe

minetest.register_node("itemframes:frame_invis",{
	description = S("Invisible Item frame"),
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
	groups = {choppy = 2, dig_immediate = 2, flammable = 2, handy = 1, axey = 1},
	sounds = sounds,
	_mcl_hardness = 0.5,

	on_place = frame_place,

	after_place_node = function(pos, placer, itemstack)

		local meta = minetest.get_meta(pos)

		meta:set_string("infotext", S("Right-click to add or remove item"))
	end,

	on_rightclick = function(pos, node, clicker, itemstack)

		if not itemstack
		or minetest.is_protected(pos, clicker:get_player_name()) then
			return
		end

		local meta = minetest.get_meta(pos)

		if not meta then return end

		if meta:get_string("item") ~= "" then

			show_msg(clicker:get_player_name()
				.. " removed " .. meta:get_string("item")
				.. " from Itemframe at " .. minetest.pos_to_string(pos))

			if should_return_item then
				return return_item(pos, "frame", meta, clicker, itemstack)
			else
				drop_item(pos, "frame", meta)
			end
		else
			local s = itemstack:take_item()

			meta:set_string("item", s:to_string())

			update_item(pos, "frame", node)

			show_msg(clicker:get_player_name()
				.. " inserted " .. meta:get_string("item")
				.. " into Itemframe at " .. minetest.pos_to_string(pos))

			return itemstack
		end
	end,

	on_destruct = function(pos)
		drop_item(pos, "frame")
	end,

	on_punch = function(pos, node, puncher)

		-- rotate item inside frame when holding sneak and punching
		if puncher and puncher:get_player_control().sneak
		and (allow_rotate or not minetest.is_protected(pos, puncher:get_player_name())) then

			local p2 = node.param2
			local nx = facedir[p2].nx

			minetest.swap_node(pos, {name = node.name, param2 = nx})
			node.param2 = nx
		end

		update_item(pos, "frame", node)
	end,

	on_blast = function(pos, intensity)

		drop_item(pos, "frame")

		minetest.add_item(pos, {name = "itemframes:frame_invis"})

		minetest.remove_node(pos)
	end,

	on_burn = function(pos)

		drop_item(pos, "frame")

		minetest.remove_node(pos)
	end
})

minetest.register_craft({
	output = "itemframes:frame_invis",
	recipe = {
		{ a.glass, a.glass, a.glass },
		{ a.glass, a.paper, a.glass },
		{ a.glass, a.glass, a.glass }
	}
})

-- pedestal node and recipe

minetest.register_node("itemframes:pedestal",{
	description = S("Pedestal"),
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
	tiles = {
		"itemframes_pedestal_top.png",
		"itemframes_pedestal_btm.png",
		"itemframes_pedestal.png"
	},
	paramtype = "light",
	groups = {cracky = 3, pickaxey = 1},
	sounds = sounds,
	on_rotate = screwdriver.disallow,
	_mcl_hardness = 1.5,

	after_place_node = function(pos, placer, itemstack)

		local meta = minetest.get_meta(pos)

		meta:set_string("infotext", S("Right-click to add or remove item"))
	end,

	on_rightclick = function(pos, node, clicker, itemstack)

		if not itemstack
		or minetest.is_protected(pos, clicker:get_player_name()) then
			return
		end

		local meta = minetest.get_meta(pos)

		if not meta then return end

		if meta:get_string("item") ~= "" then

			show_msg(clicker:get_player_name()
				.. " removed " .. meta:get_string("item")
				.. " from Pedestal at " .. minetest.pos_to_string(pos))

			if should_return_item then
				return return_item(pos, "pedestal", meta, clicker, itemstack)
			else
				drop_item(pos, "pedestal", meta)
			end
		else

			local s = itemstack:take_item()

			meta:set_string("item", s:to_string())

			update_item(pos, "pedestal", node)

			show_msg(clicker:get_player_name()
				.. " inserted " .. meta:get_string("item")
				.. " into Pedestal at " .. minetest.pos_to_string(pos))

			return itemstack
		end
	end,

	on_destruct = function(pos)
		drop_item(pos, "pedestal")
	end,

	on_punch = function(pos, node, puncher)
		update_item(pos, "pedestal", node)
	end,

	on_blast = function(pos, intensity)

		local pos2 = {x = pos.x, y = pos.y, z = pos.z}

		drop_item(pos, "pedestal")

		minetest.add_item(pos2, {name = "itemframes:pedestal"})

		minetest.remove_node(pos2)
	end
})

minetest.register_craft({
	output = "itemframes:pedestal",
	recipe = {
		{ a.stone, a.stone, a.stone },
		{ "", a.stone, "" },
		{ a.stone, a.stone, a.stone }
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
		local ntype = "frame"

		if node.name == "itemframes:pedestal" then
			ypos = 1
			ntype = "pedestal"
		end

		pos.y = pos.y + ypos

		local objs = minetest.get_objects_inside_radius(pos, 0.5)
--		local found_any = false

		for _, obj in ipairs(objs) do

			local e = obj:get_luaentity()

			if e and e.name == "itemframes:item" then

--				if found_any then
					obj:remove() -- remove duplicates
--				else
--					found_any = true
--				end
			end
		end

--		if found_any then return end

		pos.y = pos.y - ypos

		update_item(pos, ntype, node)
	end
})

-- stop mesecon pistons from pushing itemframe and pedestals

if minetest.get_modpath("mesecons_mvps") then
	mesecon.register_mvps_stopper("itemframes:frame")
	mesecon.register_mvps_stopper("itemframes:frame_invis")
	mesecon.register_mvps_stopper("itemframes:pedestal")
end


print("[MOD] Itemframes loaded")
