
-- register craft recipes when enabled

if otherworlds.settings.crafting.enable then

	core.register_craft({
		output = "asteroid:cobble",
		recipe = {{"asteroid:stone"}}
	})

	core.register_craft({
		output = "asteroid:gravel",
		recipe = {{"asteroid:cobble"}}
	})

	core.register_craft({
		output = "asteroid:dust",
		recipe = {{"asteroid:gravel"}}
	})

	core.register_craft({
		type = "cooking",
		output = "asteroid:stone",
		recipe = "asteroid:cobble"
	})

	core.register_craft({
		output = "asteroid:redcobble",
		recipe = {{"asteroid:redstone"}}
	})

	core.register_craft({
		output = "asteroid:redgravel",
		recipe = {{"asteroid:redcobble"}}
	})

	core.register_craft({
		output = "asteroid:reddust",
		recipe = {{"asteroid:redgravel"}}
	})

	core.register_craft({
		type = "cooking",
		output = "asteroid:redstone",
		recipe = "asteroid:redcobble"
	})
end
