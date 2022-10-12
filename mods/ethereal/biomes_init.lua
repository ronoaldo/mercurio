
--[[

	Apologies for any breakages to current biomes or mods, the following code was
	forced by wsor4035 so that Ethereal would be approved for contentdb inclusion

]]--


local old_biomes = {}
local old_decor = {}


-- backup registered biome data
for key, def in pairs(minetest.registered_biomes) do
	old_biomes[key] = def
end

for key, def in pairs(minetest.registered_decorations) do
	old_decor[key] = def
end


-- clear current biome data
minetest.clear_registered_biomes()
minetest.clear_registered_decorations()
-- minetest.clear_registered_ores()


-- create list of default biomes to remove
local def_biomes = {
	"rainforest_swamp", "grassland_dunes", "cold_desert", "taiga", "icesheet_ocean",
	"snowy_grassland_under", "desert", "deciduous_forest", "taiga_ocean", "desert_ocean",
	"tundra_ocean", "snowy_grassland_ocean", "sandstone_desert", "tundra_under",
	"coniferous_forest_ocean", "tundra", "sandstone_desert_under", "grassland",
	"rainforest", "grassland_ocean", "tundra_beach", "rainforest_under", "savanna_under",
	"icesheet", "savanna_ocean", "tundra_highland", "savanna", "cold_desert_under",
	"cold_desert_ocean", "desert_under", "taiga_under", "savanna_shore",
	"sandstone_desert_ocean", "snowy_grassland", "coniferous_forest_under",
	"deciduous_forest_ocean", "grassland_under", "icesheet_under", "rainforest_ocean",
	"deciduous_forest_shore", "deciduous_forest_under", "coniferous_forest_dunes",
	"coniferous_forest"
}


-- only re-register biomes that aren't on the list
for key, def in pairs(old_biomes) do

	local can_add = true

	for num, bio in pairs(def_biomes) do

		if key == bio then
			can_add = false
		end
	end

	if can_add == true then
		minetest.register_biome(def)
	end
end


-- only re-register decorations that don't appear in any of the above biomes
for key, def in pairs(old_decor) do

	local can_add = true

	if type(def.biomes) == "table" then

		for num, bio in pairs(def.biomes) do

			can_add = true

			for n, b in pairs(def_biomes) do

				if bio == b then
					can_add = false
				end
			end
		end
	else
		if def.biomes == key then
			can_add = false
		end
	end

	if can_add == true then
		minetest.register_decoration(def)
	end
end
