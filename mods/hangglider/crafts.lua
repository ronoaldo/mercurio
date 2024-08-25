
local S = hangglider.translator

local has_unifieddyes = minetest.get_modpath("unifieddyes")

local dye_colors = {
	white      = "ffffff",
	grey       = "888888",
	dark_grey  = "444444",
	black      = "111111",
	violet     = "8000ff",
	blue       = "0000ff",
	cyan       = "00ffff",
	dark_green = "005900",
	green      = "00ff00",
	yellow     = "ffff00",
	brown      = "592c00",
	orange     = "ff7f00",
	red        = "ff0000",
	magenta    = "ff00ff",
	pink       = "ff7f9f",
}

local translated_colors = {
	white      = S("White"),
	grey       = S("Grey"),
	dark_grey  = S("Dark_grey"),
	black      = S("Black"),
	violet     = S("Violet"),
	blue       = S("Blue"),
	cyan       = S("Cyan"),
	dark_green = S("Dark_green"),
	green      = S("Green"),
	yellow     = S("Yellow"),
	brown      = S("Brown"),
	orange     = S("Orange"),
	red        = S("Red"),
	magenta    = S("Magenta"),
	pink       = S("Pink"),
}

local function get_dye_color(name)
	local color
	if has_unifieddyes then
		color = unifieddyes.get_color_from_dye_name(name)
	end
	if not color then
		color = string.match(name, "^dye:(.+)$")
		if color then
			color = dye_colors[color]
		end
	end
	return color
end

local function get_color_name(name)
	name = string.gsub(name, "^dye:", "")
	return translated_colors[name]
end

local function get_color_name_from_color(color)
	for name, color_hex in pairs(dye_colors) do
		if color == color_hex then
			return translated_colors[name]
		end
	end
end

-- This recipe is just a placeholder
do
	local item = ItemStack("hangglider:hangglider")
	item:get_meta():set_string("description", S("Colored Glider"))
	minetest.register_craft({
		output = item:to_string(),
		recipe = {"hangglider:hangglider", "group:dye"},
		type = "shapeless",
	})
end

-- This is what actually creates the colored hangglider
minetest.register_on_craft(function(crafted_item, _, old_craft_grid)
	if crafted_item:get_name() ~= "hangglider:hangglider" then
		return
	end
	local wear, color, color_name
	for _,stack in ipairs(old_craft_grid) do
		local name = stack:get_name()
		if name == "hangglider:hangglider" then
			wear = stack:get_wear()
			color = stack:get_meta():get("hangglider_color")
			color_name = get_color_name_from_color(color)
		elseif minetest.get_item_group(name, "dye") ~= 0 then
			color = get_dye_color(name)
			color_name = get_color_name(name)
		elseif "wool:white" == stack:get_name()
			or "default:paper" == stack:get_name()
		then
			wear = 0
		end
	end
	if wear and color and color_name then
		if color == "ffffff" then
			return ItemStack({name = "hangglider:hangglider", wear = wear})
		end
		local meta = crafted_item:get_meta()
		meta:set_string("description", S("@1 Glider", color_name))
		meta:set_string("inventory_image", "hangglider_item.png^(hangglider_color.png^[multiply:#"..color..")")
		meta:set_string("hangglider_color", color)
		crafted_item:set_wear(wear)
		return crafted_item
	end
end)

-- Repairing
minetest.register_craft({
	output = "hangglider:hangglider",
	recipe = {
		{"default:paper", "default:paper", "default:paper"},
		{"default:paper", "hangglider:hangglider", "default:paper"},
		{"default:paper", "default:paper", "default:paper"},
	},
})
minetest.register_craft({
	output = "hangglider:hangglider",
	recipe = {
		{"hangglider:hangglider", "wool:white"},
	},
})

-- Main craft
minetest.register_craft({
	output = "hangglider:hangglider",
	recipe = {
		{"wool:white", "wool:white", "wool:white"},
		{"default:stick", "", "default:stick"},
		{"", "default:stick", ""},
	}
})
