-- dmobs by D00Med

-- mounts api by D00Med and lib_mount api by blert2112

dmobs = {dragon = {}}

local dpath = minetest.get_modpath("dmobs") .. "/"

dofile(dpath .. "api.lua")


-- Enable dragons (disable to remove tamed dragons and dragon bosses)
dmobs.dragons = minetest.settings:get_bool("dmobs.dragons", true)
dmobs.regulars = minetest.settings:get_bool("dmobs.regulars", true)

-- Enable NyanCat
dmobs.allow_nyanc = minetest.settings:get_bool("dmobs.allow_nyanc", true)

-- Enable fireballs/explosions
dmobs.destructive = minetest.settings:get_bool("dmobs.destructive", false)

-- Timer for the egg mechanics
dmobs.eggtimer = tonumber(minetest.settings:get("dmobs.eggtimer") ) or 100


-- Table cloning to reduce code repetition
-- deep-copy a table -- from https://gist.github.com/MihailJP/3931841
dmobs.deepclone = function(t)

	if type(t) ~= "table" then return t end

	local target = {}

	for k, v in pairs(t) do

		if k ~= "__index" and type(v) == "table" then -- omit circular reference
			target[k] = dmobs.deepclone(v)
		else
			target[k] = v
		end
	end

	return target
end


if dmobs.regulars then

	-- load friendly mobs
	dofile(dpath .. "mobs/pig.lua")
	dofile(dpath .. "mobs/panda.lua")
	dofile(dpath .. "mobs/tortoise.lua")
	dofile(dpath .. "mobs/golem_friendly.lua")

	if dmobs.allow_nyanc then
		dofile(dpath .. "mobs/nyan.lua")
	end

	dofile(dpath .. "mobs/gnorm.lua")
	dofile(dpath .. "mobs/hedgehog.lua")
	dofile(dpath .. "mobs/owl.lua")
	dofile(dpath .. "mobs/whale.lua")
	dofile(dpath .. "mobs/badger.lua")
	dofile(dpath .. "mobs/butterfly.lua")
	dofile(dpath .. "mobs/elephant.lua")

	-- load baddies
	dofile(dpath .. "mobs/pig_evil.lua")
	dofile(dpath .. "mobs/fox.lua")
	dofile(dpath .. "mobs/rat.lua")
	dofile(dpath .. "mobs/wasps.lua")
	dofile(dpath .. "mobs/treeman.lua")
	dofile(dpath .. "mobs/golem.lua")
	dofile(dpath .. "mobs/skeleton.lua")
	dofile(dpath .. "mobs/orc.lua")
	dofile(dpath .. "mobs/ogre.lua")
end

-- dragons!!
dofile(dpath .. "dragons/piloting.lua")
dofile(dpath .. "dragons/dragon_normal.lua")

if dmobs.dragons then
	dofile(dpath .. "dragons/main.lua")
	dofile(dpath .. "dragons/dragon1.lua")
	dofile(dpath .. "dragons/dragon2.lua")
	dofile(dpath .. "dragons/dragon3.lua")
	dofile(dpath .. "dragons/dragon4.lua")
	dofile(dpath .. "dragons/great_dragon.lua")
	dofile(dpath .. "dragons/water_dragon.lua")
	dofile(dpath .. "dragons/wyvern.lua")
	dofile(dpath .. "dragons/eggs.lua")
end

dofile(dpath .. "arrows/dragonfire.lua")
dofile(dpath .. "arrows/dragonarrows.lua")
dofile(dpath .. "arrows/sting.lua")

-- General arrow definitions
if dmobs.destructive == true then
	dofile(dpath .. "arrows/fire_explosive.lua")
else
	dofile(dpath .. "arrows/fire.lua")
end

dofile(dpath .. "nodes.lua")

-- Spawning
dofile(dpath .. "spawn.lua")


print("[MOD] Mobs Redo D00Med Mobs loaded")
