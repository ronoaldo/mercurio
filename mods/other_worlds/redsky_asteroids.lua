
-- Approximate realm limits

local YMIN = otherworlds.settings.redsky_asteroids.YMIN or 6000
local YMAX = otherworlds.settings.redsky_asteroids.YMAX or 7000

-- Register on_generated function for this layer

core.register_on_generated(
		otherworlds.asteroids.create_on_generated(YMIN, YMAX, {

	c_air = core.get_content_id("air"),
	c_obsidian = core.get_content_id("default:obsidian"),
	c_stone = core.get_content_id("asteroid:redstone"),
	c_cobble = core.get_content_id("air"),
	c_gravel = core.get_content_id("asteroid:redgravel"),
	c_dust = core.get_content_id("asteroid:reddust"),
	c_ironore = core.get_content_id("asteroid:ironore"),
	c_copperore = core.get_content_id("asteroid:copperore"),
	c_goldore = core.get_content_id("asteroid:goldore"),
	c_diamondore = core.get_content_id("asteroid:diamondore"),
	c_meseore = core.get_content_id("asteroid:meseore"),
	c_waterice = core.get_content_id("default:ice"),
	c_atmos = core.get_content_id("asteroid:atmos"),
	c_snowblock = core.get_content_id("default:snowblock")
}))

-- Deco code for grass and crystal

local TOPDECO = 500 -- how often deco appears on top of asteroid cobble

local grass = {
	"mars:grass_1", "mars:grass_2", "mars:grass_3", "mars:grass_4", "mars:grass_5"}

local flower = {"mars:moss", "mars:redweed", "mars:redgrass"}

local crystal = {
	"crystals:ghost_crystal_1", "crystals:ghost_crystal_2",
	"crystals:red_crystal_1", "crystals:red_crystal_2",
	"crystals:rose_quartz_1", "crystals:rose_quartz_2"}

local random = math.random

-- Add surface decoration

core.register_on_generated(function(minp, maxp)

	if minp.y < YMIN or maxp.y > YMAX then return end

	local bpos, ran
	local coal = core.find_nodes_in_area_under_air(minp, maxp, {"asteroid:redgravel"})

	for n = 1, #coal do

		bpos = {x = coal[n].x, y = coal[n].y + 1, z = coal[n].z}

		ran = random(TOPDECO)

		if ran < 100 then -- grass

			core.swap_node(bpos, {name = grass[random(#grass)]})

		elseif ran >= 180 and ran <= 200 then -- other plants

			core.swap_node(bpos, {name = flower[random(#flower)]})

		elseif ran == TOPDECO then -- crystals

			core.swap_node(bpos, {name = crystal[random(#crystal)]})
		end
	end
end)
