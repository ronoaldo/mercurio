
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
	name = string.gsub(name, "_", " ")
	name = string.gsub(name, "(%l)(%w*)", function(a, b) return string.upper(a)..b end)
	return name
end

-- This recipe is just a placeholder
do
	local item = ItemStack("hangglider:hangglider")
	item:get_meta():set_string("description", "Colored Glider")
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
		elseif minetest.get_item_group(name, "dye") ~= 0 then
			color = get_dye_color(name)
			color_name = get_color_name(name)
		end
	end
	if wear and color and color_name then
		if color == "ffffff" then
			return ItemStack({name = "hangglider:hangglider", wear = wear})
		end
		local meta = crafted_item:get_meta()
		meta:set_string("description", color_name.." Glider")
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
