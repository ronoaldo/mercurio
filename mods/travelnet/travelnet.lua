
local dye_compat = {
   yellow = "group:yellow",
   red = "group:red",
   orange = "group:orange",
   blue = "group:blue",
   cyan = "group:cyan",
   green = "group:green",
   dark_green = "group:dark_green",
   violet = "group:violet",
   pink = "group:pink",
   magenta = "group:magenta",
   brown = "group:brown",
   grey = "group:grey",
   dark_grey = "group:dark_grey",
   black = "group:black",
   white = "group:white",
}

if minetest.get_modpath("dye") then
   dye_compat.yellow = "dye:yellow"
   dye_compat.red = "dye:red"
   dye_compat.orange = "dye:orange"
   dye_compat.blue = "dye:blue"
   dye_compat.cyan = "dye:cyan"
   dye_compat.green = "dye:green"
   dye_compat.dark_green = "dye:dark_green"
   dye_compat.violet = "dye:violet"
   dye_compat.pink = "dye:pink"
   dye_compat.magenta = "dye:magenta"
   dye_compat.brown = "dye:brown"
   dye_compat.grey = "dye:grey"
   dye_compat.dark_grey = "dye:dark_grey"
   dye_compat.black = "dye:black"
   dye_compat.white = "dye:white"
end

if minetest.get_modpath("mcl_dye") then
   dye_compat.yellow = "mcl_dye:yellow"
   dye_compat.red = "mcl_dye:red"
   dye_compat.orange = "mcl_dye:orange"
   dye_compat.blue = "mcl_dye:blue"
   dye_compat.cyan = "mcl_dye:cyan"
   dye_compat.green = "mcl_dye:green"
   dye_compat.dark_green = "mcl_dye:dark_green"
   dye_compat.violet = "mcl_dye:violet"
   dye_compat.pink = "mcl_dye:pink"
   dye_compat.magenta = "mcl_dye:magenta"
   dye_compat.brown = "mcl_dye:brown"
   dye_compat.grey = "mcl_dye:grey"
   dye_compat.dark_grey = "mcl_dye:dark_grey"
   dye_compat.black = "mcl_dye:black"
   dye_compat.white = "mcl_dye:white"
end


local default_travelnets = {
	-- "default" travelnet box in yellow
	{ nodename="travelnet:travelnet", color="#e0bb2d", dye=dye_compat.yellow, recipe=travelnet.travelnet_recipe },
	{ nodename="travelnet:travelnet_red", color="#ce1a1a", dye=dye_compat.red },
	{ nodename="travelnet:travelnet_orange", color="#e2621b", dye=dye_compat.orange },
	{ nodename="travelnet:travelnet_blue", color="#0051c5", dye=dye_compat.blue },
	{ nodename="travelnet:travelnet_cyan", color="#00a6ae", dye=dye_compat.cyan },
	{ nodename="travelnet:travelnet_green", color="#53c41c", dye=dye_compat.green },
	{ nodename="travelnet:travelnet_dark_green", color="#2c7f00", dye=dye_compat.dark_green },
	{ nodename="travelnet:travelnet_violet", color="#660bb3", dye=dye_compat.violet },
	{ nodename="travelnet:travelnet_pink", color="#ff9494", dye=dye_compat.pink },
	{ nodename="travelnet:travelnet_magenta", color="#d10377", dye=dye_compat.magenta },
	{ nodename="travelnet:travelnet_brown", color="#572c00", dye=dye_compat.brown },
	{ nodename="travelnet:travelnet_grey", color="#a2a2a2", dye=dye_compat.grey },
	{ nodename="travelnet:travelnet_dark_grey", color="#3d3d3d", dye=dye_compat.dark_grey },
	{ nodename="travelnet:travelnet_black", color="#0f0f0f", dye=dye_compat.black, light_source=0 },
	{ nodename="travelnet:travelnet_white", color="#ffffff", dye=dye_compat.white, light_source=minetest.LIGHT_MAX },
}

for _, cfg in ipairs(default_travelnets) do
	travelnet.register_travelnet_box(cfg)
end
