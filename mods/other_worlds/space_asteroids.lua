
-- Approximate realm limits

local YMIN = otherworlds.settings.space_asteroids.YMIN or 5000
local YMAX = otherworlds.settings.space_asteroids.YMAX or 6000

-- Register on_generated function for this layer

core.register_on_generated(
		otherworlds.asteroids.create_on_generated(YMIN, YMAX, {

	c_air = core.get_content_id("air"),
	c_obsidian = core.get_content_id("default:obsidian"),
	c_stone = core.get_content_id("asteroid:stone"),
	c_cobble = core.get_content_id("asteroid:cobble"),
	c_gravel = core.get_content_id("asteroid:gravel"),
	c_dust = core.get_content_id("asteroid:dust"),
	c_ironore = core.get_content_id("default:stone_with_iron"),
	c_copperore = core.get_content_id("default:stone_with_copper"),
	c_goldore = core.get_content_id("default:stone_with_gold"),
	c_diamondore = core.get_content_id("default:stone_with_diamond"),
	c_meseore = core.get_content_id("default:stone_with_mese"),
	c_waterice = core.get_content_id("default:ice"),
	c_atmos = core.get_content_id("asteroid:atmos"),
	c_snowblock = core.get_content_id("default:snowblock")
}))
