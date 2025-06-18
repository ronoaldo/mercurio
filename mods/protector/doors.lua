
-- doors code from an old client re-used

local S = core.get_translator("protector")

-- MineClone support

local mcl = core.get_modpath("mcl_core")

-- Are crafts enabled?

local protector_crafts = core.settings:get_bool("protector_crafts") ~= false

-- Registers a door

local function register_door(name, def)

	def.groups.not_in_creative_inventory = 1
	def.groups.handy = 1
	def.groups.prot_door = 1

	local box = {{-0.5, -0.5, -0.5, 0.5, 0.5, -0.5 + 1.5/16}}

	def.node_box_bottom = box
	def.node_box_top = box
	def.selection_box_bottom = box
	def.selection_box_top = box

	core.register_craftitem(name, {
		description = def.description,
		inventory_image = def.inventory_image,

		on_place = function(itemstack, placer, pointed_thing)

			if pointed_thing.type ~= "node" then return itemstack end

			local ptu = pointed_thing.under
			local nu = core.get_node(ptu)

			if core.registered_nodes[nu.name]
			and core.registered_nodes[nu.name].on_rightclick then
				return core.registered_nodes[nu.name].on_rightclick(
						ptu, nu, placer, itemstack)
			end

			local pt = pointed_thing.above
			local pt2 = {x = pt.x, y = pt.y, z = pt.z}

			pt2.y = pt2.y + 1

			if not core.registered_nodes[core.get_node(pt).name].buildable_to
			or not core.registered_nodes[core.get_node(pt2).name].buildable_to
			or not placer or not placer:is_player() then
				return itemstack
			end

			if core.is_protected(pt, placer:get_player_name())
			or core.is_protected(pt2, placer:get_player_name()) then
				core.record_protection_violation(pt, placer:get_player_name())
				return itemstack
			end

			local p2 = core.dir_to_facedir(placer:get_look_dir())
			local pt3 = {x = pt.x, y = pt.y, z = pt.z}

			if p2 == 0 then     pt3.x = pt3.x - 1
			elseif p2 == 1 then pt3.z = pt3.z + 1
			elseif p2 == 2 then pt3.x = pt3.x + 1
			elseif p2 == 3 then pt3.z = pt3.z - 1
			end

			if core.get_item_group(core.get_node(pt3).name, "prot_door") == 0 then
				core.set_node(pt, {name = name .. "_b_1", param2 = p2})
				core.set_node(pt2, {name = name .. "_t_1", param2 = p2})
			else
				core.set_node(pt, {name = name .. "_b_2", param2 = p2})
				core.set_node(pt2, {name = name .. "_t_2", param2 = p2})

				core.get_meta(pt):set_int("right", 1)
				core.get_meta(pt2):set_int("right", 1)
			end

			if not core.settings:get_bool("creative_mode") then
				itemstack:take_item()
			end

			core.sound_play(def.sounds.place, {pos = pt2}, true)

			return itemstack
		end
	})

	local tt = def.tiles_top
	local tb = def.tiles_bottom

	local function after_dig_node(pos, name, digger)

		local node = core.get_node(pos)

		if node.name == name then
			core.node_dig(pos, node, digger)
		end
	end

	local function on_rightclick(pos, dir, check_name, replace, replace_dir, params)

		pos.y = pos.y + dir

		if core.get_node(pos).name ~= check_name then return end

		local p2 = core.get_node(pos).param2

		p2 = params[p2 + 1]

		core.swap_node(pos, {name = replace_dir, param2 = p2})

		pos.y = pos.y - dir

		core.swap_node(pos, {name = replace, param2=p2})

		core.sound_play(def.open_sound,
				{pos = pos, gain = 0.3, max_hear_distance = 10}, true)
	end

	local function on_rotate(pos, node, dir, user, check_name, mode, new_param2)

		if mode ~= screwdriver.ROTATE_FACE then return false end

		pos.y = pos.y + dir

		if core.get_node(pos).name ~= check_name then return false end

		if core.is_protected(pos, user:get_player_name()) then
			core.record_protection_violation(pos, user:get_player_name())
			return false
		end

		local node2 = core.get_node(pos)

		node2.param2 = (node2.param2 + 1) % 4

		core.swap_node(pos, node2)

		pos.y = pos.y - dir

		node.param2 = (node.param2 + 1) % 4

		core.swap_node(pos, node)

		return true
	end

	core.register_node(name .. "_b_1", {
		tiles = {tb[2], tb[2], tb[2], tb[2], tb[1], tb[1] .. "^[transformfx"},
		paramtype = "light",
		paramtype2 = "facedir",
		use_texture_alpha = "clip",
		is_ground_content = false,
		node_dig_prediction = "",
		drop = name,
		drawtype = "nodebox",
		node_box = {type = "fixed", fixed = def.node_box_bottom},
		selection_box = {type = "fixed", fixed = def.selection_box_bottom},
		groups = def.groups,
		_mcl_hardness = 0.8,
		_mcl_blast_resistance = 1,

		after_dig_node = function(pos, oldnode, oldmetadata, digger)
			pos.y = pos.y + 1
			after_dig_node(pos, name.."_t_1", digger)
		end,

		on_rightclick = function(pos, node, clicker)

			if not core.is_protected(pos, clicker:get_player_name()) then
				on_rightclick(pos, 1, name .. "_t_1", name .. "_b_2",
						name .. "_t_2", {1,2,3,0})
			end
		end,

		on_rotate = function(pos, node, user, mode, new_param2)
			return on_rotate(pos, node, 1, user, name .. "_t_1", mode)
		end,

		sounds = def.sounds,
		sunlight_propagates = def.sunlight,
		on_blast = function() end
	})

	core.register_node(name .. "_t_1", {
		tiles = {tt[2], tt[2], tt[2], tt[2], tt[1], tt[1] .. "^[transformfx"},
		paramtype = "light",
		paramtype2 = "facedir",
		use_texture_alpha = "clip",
		is_ground_content = false,
		node_dig_prediction = "",
		drop = "",
		drawtype = "nodebox",
		node_box = {type = "fixed", fixed = def.node_box_top},
		selection_box = {type = "fixed", fixed = def.selection_box_top},
		groups = def.groups,
		_mcl_hardness = 0.8,
		_mcl_blast_resistance = 1,

		after_dig_node = function(pos, oldnode, oldmetadata, digger)
			pos.y = pos.y - 1
			after_dig_node(pos, name .. "_b_1", digger)
		end,

		on_rightclick = function(pos, node, clicker)
			if not core.is_protected(pos, clicker:get_player_name()) then
				on_rightclick(pos, -1, name .. "_b_1", name .. "_t_2",
						name .. "_b_2", {1,2,3,0})
			end
		end,

		on_rotate = function(pos, node, user, mode, new_param2)
			return on_rotate(pos, node, -1, user, name .. "_b_1", mode)
		end,

		sounds = def.sounds,
		sunlight_propagates = def.sunlight,
		on_blast = function() end
	})

	core.register_node(name .. "_b_2", {
		tiles = {tb[2], tb[2], tb[2], tb[2], tb[1] .. "^[transformfx", tb[1]},
		paramtype = "light",
		paramtype2 = "facedir",
		use_texture_alpha = "clip",
		is_ground_content = false,
		node_dig_prediction = "",
		drop = name,
		drawtype = "nodebox",
		node_box = {type = "fixed", fixed = def.node_box_bottom},
		selection_box = {type = "fixed", fixed = def.selection_box_bottom},
		groups = def.groups,
		_mcl_hardness = 0.8,
		_mcl_blast_resistance = 1,

		after_dig_node = function(pos, oldnode, oldmetadata, digger)
			pos.y = pos.y + 1
			after_dig_node(pos, name .. "_t_2", digger)
		end,

		on_rightclick = function(pos, node, clicker)
			if not core.is_protected(pos, clicker:get_player_name()) then
				on_rightclick(pos, 1, name .. "_t_2", name .. "_b_1",
						name .. "_t_1", {3,0,1,2})
			end
		end,

		on_rotate = function(pos, node, user, mode, new_param2)
			return on_rotate(pos, node, 1, user, name .. "_t_2", mode)
		end,

		sounds = def.sounds,
		sunlight_propagates = def.sunlight,
		on_blast = function() end
	})

	core.register_node(name .. "_t_2", {
		tiles = {tt[2], tt[2], tt[2], tt[2], tt[1] .. "^[transformfx", tt[1]},
		paramtype = "light",
		paramtype2 = "facedir",
		use_texture_alpha = "clip",
		is_ground_content = false,
		node_dig_prediction = "",
		drop = "",
		drawtype = "nodebox",
		node_box = {type = "fixed", fixed = def.node_box_top},
		selection_box = {type = "fixed", fixed = def.selection_box_top},
		groups = def.groups,
		_mcl_hardness = 0.8,
		_mcl_blast_resistance = 1,

		after_dig_node = function(pos, oldnode, oldmetadata, digger)
			pos.y = pos.y - 1
			after_dig_node(pos, name .. "_b_2", digger)
		end,

		on_rightclick = function(pos, node, clicker)
			if not core.is_protected(pos, clicker:get_player_name()) then
				on_rightclick(pos, -1, name .. "_b_2", name .. "_t_1",
						name .. "_b_1", {3,0,1,2})
			end
		end,

		on_rotate = function(pos, node, user, mode, new_param2)
			return on_rotate(pos, node, -1, user, name .. "_b_2", mode)
		end,

		sounds = def.sounds,
		sunlight_propagates = def.sunlight,
		on_blast = function() end
	})
end

-- Protected Wooden Door

local name = "protector:door_wood"

register_door(name, {
	description = S("Protected Wooden Door"),
	inventory_image = "doors_wood.png^protector_logo.png",
	groups = {
		snappy = 1, choppy = 2, dig_immediate = 2, unbreakable = 1, axey = 1, handy = 1
	},
	tiles_bottom = {"doors_wood_b.png^protector_logo.png", "doors_brown.png"},
	tiles_top = {"doors_wood_a.png", "doors_brown.png"},
	sounds = default.node_sound_wood_defaults(),
	open_sound = "default_dug_node",
	sunlight = false
})

if protector_crafts then

	if mcl then

		core.register_craft({
			output = name,
			recipe = { {"mcl_doors:wooden_door", "mcl_core:gold_ingot"} }
		})
	else
		core.register_craft({
			output = name,
			recipe = {
				{"group:wood", "group:wood"},
				{"group:wood", "default:copper_ingot"},
				{"group:wood", "group:wood"}
			}
		})

		core.register_craft({
			output = name,
			recipe = { {"doors:door_wood", "default:copper_ingot"} }
		})
	end
end

-- Protected Steel Door

local name = "protector:door_steel"

register_door(name, {
	description = S("Protected Steel Door"),
	inventory_image = "doors_steel.png^protector_logo.png",
	groups = {
		snappy = 1, cracky = 1, handy = 1,
		level = (mcl and 0 or 2), pickaxey = 2, unbreakable = 1
	},
	tiles_bottom = {"doors_steel_b.png^protector_logo.png", "doors_grey.png"},
	tiles_top = {"doors_steel_a.png", "doors_grey.png"},
	sounds = default.node_sound_metal_defaults(),
	open_sound = "default_place_node_metal",
	sunlight = false,
})

if protector_crafts then

	if mcl then

		core.register_craft({
			output = name,
			recipe = { {"mcl_doors:iron_door", "mcl_core:gold_ingot"} }
		})
	else
		core.register_craft({
			output = name,
			recipe = {
				{"default:steel_ingot", "default:steel_ingot"},
				{"default:steel_ingot", "default:copper_ingot"},
				{"default:steel_ingot", "default:steel_ingot"}
			}
		})

		core.register_craft({
			output = name,
			recipe = { {"doors:door_steel", "default:copper_ingot"} }
		})
	end
end

----trapdoor----

local function register_trapdoor(name, def)

	local name_closed = name
	local name_opened = name .. "_open"

	def.on_rightclick = function (pos, node, clicker, itemstack, pointed_thing)

		if core.is_protected(pos, clicker:get_player_name()) then return end

		local newname = node.name == name_closed and name_opened or name_closed

		core.sound_play(def.open_sound,
				{pos = pos, gain = 0.3, max_hear_distance = 10}, true)

		core.swap_node(pos,
				{name = newname, param1 = node.param1, param2 = node.param2})
	end

	-- Common trapdoor configuration
	def.drawtype = "nodebox"
	def.paramtype = "light"
	def.paramtype2 = "facedir"
	def.use_texture_alpha = "clip"
	def.is_ground_content = false
	def.node_dig_prediction = ""

	local def_opened = table.copy(def)
	local def_closed = table.copy(def)

	def_closed.node_box = {
		type = "fixed", fixed = {-0.5, -0.5, -0.5, 0.5, -6/16, 0.5}
	}
	def_closed.selection_box = {
		type = "fixed", fixed = {-0.5, -0.5, -0.5, 0.5, -6/16, 0.5}
	}
	def_closed.tiles = { def.tile_front, def.tile_front, def.tile_side, def.tile_side,
		def.tile_side, def.tile_side }

	def_opened.node_box = {
		type = "fixed", fixed = {-0.5, -0.5, 6/16, 0.5, 0.5, 0.5}
	}
	def_opened.selection_box = {
		type = "fixed", fixed = {-0.5, -0.5, 6/16, 0.5, 0.5, 0.5}
	}
	def_opened.tiles = { def.tile_side, def.tile_side,
			def.tile_side .. "^[transform3",
			def.tile_side .. "^[transform1",
			def.tile_front, def.tile_front }

	def_opened.drop = name_closed
	def_opened.groups.not_in_creative_inventory = 1

	core.register_node(name_opened, def_opened)
	core.register_node(name_closed, def_closed)
end

-- Protected Wooden Trapdoor

register_trapdoor("protector:trapdoor", {
	description = S("Protected Trapdoor"),
	inventory_image = "doors_trapdoor.png^protector_logo.png",
	wield_image = "doors_trapdoor.png^protector_logo.png",
	tile_front = "doors_trapdoor.png^protector_logo.png",
	tile_side = "doors_trapdoor_side.png",
	groups = {snappy = 1, choppy = 2, dig_immediate = 2, unbreakable = 1, axey = 1},
	_mcl_hardness = 0.8,
	_mcl_blast_resistance = 1,
	sounds = default.node_sound_wood_defaults(),
	open_sound = "default_dug_node"
})

if protector_crafts then

	if mcl then

		core.register_craft({
			output = "protector:trapdoor",
			recipe = { {"mcl_doors:trapdoor", "mcl_core:gold_ingot"} }
		})
	else
		core.register_craft({
			output = "protector:trapdoor 2",
			recipe = {
				{"group:wood", "default:copper_ingot", "group:wood"},
				{"group:wood", "group:wood", "group:wood"}
			}
		})

		core.register_craft({
			output = "protector:trapdoor",
			recipe = { {"doors:trapdoor", "default:copper_ingot"} }
		})
	end
end

-- Protected Steel Trapdoor

register_trapdoor("protector:trapdoor_steel", {
	description = S("Protected Steel Trapdoor"),
	inventory_image = "doors_trapdoor_steel.png^protector_logo.png",
	wield_image = "doors_trapdoor_steel.png^protector_logo.png",
	tile_front = "doors_trapdoor_steel.png^protector_logo.png",
	tile_side = "doors_trapdoor_steel_side.png",
	groups = {
		snappy = 1, bendy = 2, cracky = 1, level = (mcl and 0 or 2),
		unbreakable = 1, pickaxey = 2, handy = 1
	},
	_mcl_hardness = 1,
	_mcl_blast_resistance = 1,
	sounds = default.node_sound_metal_defaults(),
	open_sound = "default_place_node_metal"
})

if protector_crafts then

	if mcl then

		core.register_craft({
			output = "protector:trapdoor_steel",
			recipe = { {"mcl_doors:iron_trapdoor", "mcl_core:gold_ingot"} }
		})
	else
		core.register_craft({
			output = "protector:trapdoor_steel",
			recipe = {
				{"default:copper_ingot", "default:steel_ingot"},
				{"default:steel_ingot", "default:steel_ingot"}
			}
		})

		core.register_craft({
			output = "protector:trapdoor_steel",
			recipe = { {"doors:trapdoor_steel", "default:copper_ingot"} }
		})
	end
end
