-- Register enchanted tools.

local S = minetest.get_translator("xdecor")

-- Number of uses for the (normal) steel hoe from Minetest Game (as of 01/12/20224)
-- This is technically redundant because we cannot access that number
-- directly, but it's unlikely to change in future because Minetest Game is
-- unlikely to change.
local STEEL_HOE_USES = 500

-- Modifier of the steel hoe uses for the enchanted steel hoe
local STEEL_HOE_USES_MODIFIER = 2.2

-- Modifier of the bug net uses for the enchanted bug net
local BUG_NET_USES_MODIFIER = 4

-- Multiplies by much faster the fast hammer repairs
local HAMMER_FAST_MODIFIER = 1.3

-- Reduces the wear taken by the hammer for a single repair step
-- (absolute value)
local HAMMER_DURABLE_MODIFIER = 100

-- Register enchantments for default tools from Minetest Game
local materials = {"steel", "bronze", "mese", "diamond"}
local tooltypes = {
	{ "axe", { "durable", "fast" }, "choppy" },
	{ "pick", { "durable", "fast" }, "cracky" },
	{ "shovel", { "durable", "fast" }, "crumbly" },
	{ "sword", { "sharp" }, nil },
}
for t=1, #tooltypes do
for m=1, #materials do
	local tooltype = tooltypes[t][1]
	local enchants = tooltypes[t][2]
	local dig_group = tooltypes[t][3]
	local material = materials[m]
	xdecor.register_enchantable_tool("default:"..tooltype.."_"..material, {
		enchants = enchants,
		dig_group = dig_group,
	})
end
end

-- Register enchantment for bug net
xdecor.register_enchantable_tool("fireflies:bug_net", {
	enchants = { "durable" },
	dig_group = "catchable",
	bonuses = {
		uses = BUG_NET_USES_MODIFIER,
	}
})

-- Register enchanted steel hoe (more durability)
if farming.register_hoe then
	local percent = math.round((STEEL_HOE_USES_MODIFIER - 1) * 100)
	local hitem = ItemStack("farming:hoe_steel")
	local hdesc = hitem:get_short_description() or "farming:hoe_steel"
	local ehdesc, ehsdesc = xdecor.enchant_description(hdesc, "durable", percent)
	farming.register_hoe(":farming:enchanted_hoe_steel_durable", {
		description = ehdesc,
		short_description = ehsdesc,
		inventory_image = xdecor.enchant_texture("farming_tool_steelhoe.png"),
		max_uses = STEEL_HOE_USES * STEEL_HOE_USES_MODIFIER,
		groups = {hoe = 1, not_in_creative_inventory = 1}
	})

	xdecor.register_custom_enchantable_tool("farming:hoe_steel", {
		durable = "farming:enchanted_hoe_steel_durable",
	})
end

-- Register enchanted hammer (more durbility and efficiency)
local hammerdef = minetest.registered_items["xdecor:hammer"]
if hammerdef then
	local hitem = ItemStack("xdecor:hammer")
	local hdesc = hitem:get_short_description() or "xdecor:hammer"
	local repair = hammerdef._xdecor_hammer_repair
	local repair_cost = hammerdef._xdecor_hammer_repair_cost

	-- Durable hammer (reduces wear taken by each repair step)
	local d_repair_cost_modified = repair_cost - HAMMER_DURABLE_MODIFIER
	local d_percent = math.round(100 - d_repair_cost_modified/repair_cost * 100)
	local d_ehdesc, d_ehsdesc = xdecor.enchant_description(hdesc, "durable", d_percent)

	xdecor.register_hammer("xdecor:enchanted_hammer_durable", {
		description = d_ehdesc,
		short_description = d_ehsdesc,
		image = xdecor.enchant_texture("xdecor_hammer.png"),
		repair_cost = d_repair_cost_modified,
		groups = {repair_hammer = 1, not_in_creative_inventory = 1}
	})

	-- Fast hammer (increases both repair amount and repair cost per
	-- repair step by an equal amount)
	local f_repair_modified = math.round(repair * HAMMER_FAST_MODIFIER)
	local repair_diff = f_repair_modified - repair
	local f_repair_cost_modified = repair_cost + repair_diff
	local f_percent = math.round(HAMMER_FAST_MODIFIER * 100 - 100)
	local f_ehdesc, f_ehsdesc = xdecor.enchant_description(hdesc, "fast", f_percent)

	xdecor.register_hammer("xdecor:enchanted_hammer_fast", {
		description = f_ehdesc,
		short_description = f_ehsdesc,
		image = xdecor.enchant_texture("xdecor_hammer.png"),
		repair = f_repair_modified,
		repair_cost = f_repair_cost_modified,
		groups = {repair_hammer = 1, not_in_creative_inventory = 1}
	})

	xdecor.register_custom_enchantable_tool("xdecor:hammer", {
		durable = "xdecor:enchanted_hammer_durable",
		fast = "xdecor:enchanted_hammer_fast",
	})
end
