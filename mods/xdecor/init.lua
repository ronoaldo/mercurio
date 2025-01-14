--local t = os.clock()

xdecor = {}
local modpath = minetest.get_modpath("xdecor")

dofile(modpath .. "/handlers/glasscut.lua")
dofile(modpath .. "/handlers/animations.lua")
dofile(modpath .. "/handlers/helpers.lua")
dofile(modpath .. "/handlers/nodeboxes.lua")
dofile(modpath .. "/handlers/registration.lua")

dofile(modpath .. "/src/nodes.lua")
dofile(modpath .. "/src/recipes.lua")

-- Load modules that can be enabled and disabled by settings
local subpart = {
	"chess",
	"cooking",
	"enchanting",
	"hive",
	"itemframe",
	"mailbox",
	"mechanisms",
	"rope",
	-- Workbench MUST be loaded after all other subparts that register nodes
	-- last for the default 'cut node' registrations to work
	"workbench",
}

for _, name in ipairs(subpart) do
	local enable = minetest.settings:get_bool("enable_xdecor_" .. name, true)
	if enable then
		dofile(modpath .. "/src/" .. name .. ".lua")
	end
end

-- Special case: enchanted tools. This code is split from enchanting to
-- deal with loading order.
-- Enchanted tools registered last because they depend on previous
-- subparts
local enable_enchanting = minetest.settings:get_bool("enable_xdecor_enchanting", true)
if enable_enchanting then
	dofile(modpath .. "/src/enchanted_tools.lua")
end
