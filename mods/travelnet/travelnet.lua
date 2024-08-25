local materials = xcompat.materials

local default_travelnets = {
	-- "default" travelnet box in yellow
	{ nodename="travelnet:travelnet", color="#e0bb2d", dye=materials.dye_yellow, recipe=travelnet.travelnet_recipe },
	{ nodename="travelnet:travelnet_red", color="#ce1a1a", dye=materials.dye_red },
	{ nodename="travelnet:travelnet_orange", color="#e2621b", dye=materials.dye_orange },
	{ nodename="travelnet:travelnet_blue", color="#0051c5", dye=materials.dye_blue },
	{ nodename="travelnet:travelnet_cyan", color="#00a6ae", dye=materials.dye_cyan },
	{ nodename="travelnet:travelnet_green", color="#53c41c", dye=materials.dye_green },
	{ nodename="travelnet:travelnet_dark_green", color="#2c7f00", dye=materials.dye_dark_green },
	{ nodename="travelnet:travelnet_violet", color="#660bb3", dye=materials.dye_violet },
	{ nodename="travelnet:travelnet_pink", color="#ff9494", dye=materials.dye_pink },
	{ nodename="travelnet:travelnet_magenta", color="#d10377", dye=materials.dye_magenta },
	{ nodename="travelnet:travelnet_brown", color="#572c00", dye=materials.dye_brown },
	{ nodename="travelnet:travelnet_grey", color="#a2a2a2", dye=materials.dye_grey },
	{ nodename="travelnet:travelnet_dark_grey", color="#3d3d3d", dye=materials.dye_dark_grey },
	{ nodename="travelnet:travelnet_black", color="#0f0f0f", dye=materials.dye_black, light_source=0 },
	{ nodename="travelnet:travelnet_white", color="#ffffff", dye=materials.dye_white, light_source=minetest.LIGHT_MAX },
}

for _, cfg in ipairs(default_travelnets) do
	travelnet.register_travelnet_box(cfg)
end
