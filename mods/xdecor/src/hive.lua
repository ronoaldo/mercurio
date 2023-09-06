local hive = {}
local S = minetest.get_translator("xdecor")
local FS = function(...) return minetest.formspec_escape(S(...)) end
local HONEY_MAX = 16
local NEEDED_FLOWERS = 3
local TIMER_MIN = 64
local TIMER_MAX = 128

local text_busy = FS("The bees are busy making honey.")
local text_noflowers = FS("The bees are looking for flowers.")
local text_fewflowers = FS("The bees want to pollinate more flowers.")
local text_idle = FS("The bees are idle.")
local text_sleep = FS("The bees are resting.")

function hive.set_formspec(meta, status)
	local statustext
	if status == "busy" then
		statustext = text_busy
	elseif status == "noflowers" then
		statustext = text_noflowers
	elseif status == "fewflowers" then
		statustext = text_fewflowers
	elseif status == "idle" then
		statustext = text_idle
	elseif status == "sleep" then
		statustext = text_sleep
	end

	local formspec = "size[8,6;]"
			.."label[0.5,0;"..statustext.."]"
			..[[ image[6,1;1,1;hive_bee.png]
			image[5,1;1,1;hive_layout.png]
			list[context;honey;5,1;1,1;]
			list[current_player;main;0,2.35;8,4;]
			listring[current_player;main]
			listring[context;honey] ]] ..
			xdecor.xbg .. default.get_hotbar_bg(0,2.35)
	meta:set_string("formspec", formspec)
end

local function count_flowers(pos)
	local radius = 4
	local minp = vector.add(pos, -radius)
	local maxp = vector.add(pos, radius)
	local flowers = minetest.find_nodes_in_area_under_air(minp, maxp, "group:flower")
	return #flowers
end

local function is_sleeptime()
	local time = (minetest.get_timeofday() or 0) * 24000
	if time < 5500 or time > 18500 then
		return true
	else
		return false
	end
end

function hive.construct(pos)
	local meta = minetest.get_meta(pos)
	local inv = meta:get_inventory()

	local status = "idle"
	local flowers = count_flowers(pos)
	if is_sleeptime() then
		status = "sleep"
	elseif flowers >= NEEDED_FLOWERS then
		status = "busy"
	elseif flowers > 0 then
		status = "fewflowers"
	else
		status = "noflowers"
	end
	hive.set_formspec(meta, status)
	meta:set_string("infotext", S("Artificial Hive"))
	inv:set_size("honey", 1)

	local timer = minetest.get_node_timer(pos)
	timer:start(math.random(TIMER_MIN, TIMER_MAX))
end

function hive.timer(pos)
	local meta = minetest.get_meta(pos)
	if is_sleeptime() then
		hive.set_formspec(meta, "sleep")
		return true
	end

	local inv = minetest.get_meta(pos):get_inventory()
	local honeystack = inv:get_stack("honey", 1)
	local honey = honeystack:get_count()

	local flowers = count_flowers(pos)

	if flowers >= NEEDED_FLOWERS and honey < HONEY_MAX then
		if honey == HONEY_MAX - 1 then
			hive.set_formspec(meta, "idle")
		else
			hive.set_formspec(meta, "busy")
		end
		inv:add_item("honey", "xdecor:honey")
	elseif honey == HONEY_MAX then
		hive.set_formspec(meta, "idle")
		local timer = minetest.get_node_timer(pos)
		timer:stop()
		return true
	end
	if flowers == 0 then
		hive.set_formspec(meta, "noflowers")
	elseif flowers < NEEDED_FLOWERS then
		hive.set_formspec(meta, "fewflowers")
	end

	return true
end

function hive.blast(pos)
	local drops = xdecor.get_inventory_drops(pos, {"honey"})
	minetest.remove_node(pos)
	return drops
end

xdecor.register("hive", {
	description = S("Artificial Hive"),
	_tt_help = S("Bees live here and produce honey"),
	tiles = {"xdecor_hive_top.png", "xdecor_hive_top.png",
		 "xdecor_hive_side.png", "xdecor_hive_side.png",
		 "xdecor_hive_side.png", "xdecor_hive_front.png"},
	groups = {choppy=3, oddly_breakable_by_hand=2, flammable=1},
	is_ground_content = false,
	sounds = default.node_sound_wood_defaults(),
	on_construct = hive.construct,
	on_timer = hive.timer,
	on_blast = hive.blast,

	can_dig = function(pos)
		local inv = minetest.get_meta(pos):get_inventory()
		return inv:is_empty("honey")
	end,

	on_punch = function(_, _, puncher)
		puncher:set_hp(puncher:get_hp() - 2)
	end,

	allow_metadata_inventory_put = function()
		return 0
	end,

	on_metadata_inventory_take = function(pos, list, index, stack)
		local inv = minetest.get_inventory({type="node", pos=pos})
		local remainstack = inv:get_stack(list, index)
		-- Trigger if taking anything from full honey slot
		if remainstack:get_count() + stack:get_count() >= HONEY_MAX then
			local timer = minetest.get_node_timer(pos)
			timer:start(math.random(TIMER_MIN, TIMER_MAX))
			if not is_sleeptime() and count_flowers(pos) >= NEEDED_FLOWERS then
				local meta = minetest.get_meta(pos)
				hive.set_formspec(meta, "busy")
			end
		end
	end
})

-- Craft items

minetest.register_craftitem("xdecor:honey", {
	description = S("Honey"),
	inventory_image = "xdecor_honey.png",
	wield_image = "xdecor_honey.png",
	on_use = minetest.item_eat(2),
	groups = {
		food_honey = 1,
		food_sugar = 1,
		flammable = 2,
	},
})

-- Recipes

minetest.register_craft({
	output = "xdecor:hive",
	recipe = {
		{"group:stick", "group:stick", "group:stick"},
		{"default:paper", "default:paper", "default:paper"},
		{"group:stick", "group:stick", "group:stick"}
	}
})

if minetest.get_modpath("unified_inventory") then
	unified_inventory.register_craft_type("xdecor:hive", {
		description = S("Made by bees"),
		icon = "hive_bee.png",
		width = 1,
		height = 1,
		uses_crafting_grid = false
	})

	unified_inventory.register_craft({
		output = "xdecor:honey",
		type = "xdecor:hive",
		items = {"xdecor:hive"},
		width = 1
	})
end
