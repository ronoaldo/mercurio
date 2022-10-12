--thanks to diriel, blert2112 and taikedz

local tamed_dragons = {}

--items and tools

minetest.register_craftitem("dmobs:dragon_gem_lightning", {
	description = "Lightning Gem",
	inventory_image = "dmobs_gem_lightning.png"
})

minetest.register_craftitem("dmobs:dragon_gem_ice", {
	description = "Ice Gem",
	inventory_image = "dmobs_gem_ice.png"
})

minetest.register_craftitem("dmobs:dragon_gem_fire", {
	description = "Fire Gem",
	inventory_image = "dmobs_gem_fire.png"
})

minetest.register_craftitem("dmobs:dragon_gem_poison", {
	description = "Poison Gem",
	inventory_image = "dmobs_gem_poison.png"
})

minetest.register_craftitem("dmobs:dragon_gem", {
	description = "Dragon Gem",
	inventory_image = "dmobs_gem.png"
})


----------
-- Eggs --
----------

-- Wild dragons
mobs:register_egg("dmobs:dragon", "Minor Dragon", "default_apple.png", 1)
mobs:register_egg("dmobs:dragon1", "Wild Fire Dragon", "default_apple.png", 1)
mobs:register_egg("dmobs:dragon2", "Wild Lightning Dragon", "dmobs_lightning.png", 1)
mobs:register_egg("dmobs:dragon3", "Wild Poison Dragon", "dmobs_poison.png", 1)
mobs:register_egg("dmobs:dragon4", "Wild Ice Dragon", "default_ice.png", 1)
mobs:register_egg("dmobs:dragon_great", "Boss Dragon", "dmobs_egg1.png", 1)
mobs:register_egg("dmobs:waterdragon", "Boss Waterdragon", "dmobs_egg4.png", 1)
mobs:register_egg("dmobs:wyvern", "Boss Wyvern", "dmobs_egg3.png", 1)

-- Tamed dragons
mobs:register_egg("dmobs:dragon_red", "Tamed Fire Dragon", "default_apple.png", 1)
mobs:register_egg("dmobs:dragon_black", "Tamed Lightning Dragon", "dmobs_lightning.png", 1)
mobs:register_egg("dmobs:dragon_green", "Tamed Poison Dragon", "dmobs_poison.png", 1)
mobs:register_egg("dmobs:dragon_blue", "Tamed Ice Dragon", "default_ice.png", 1)
mobs:register_egg("dmobs:dragon_great_tame", "Tamed Great Dragon",
		"default_lava_source_animated.png", 1)
