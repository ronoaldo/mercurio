-- Nether check for Xanadu server
local nether_mod = minetest.get_modpath("nether") and minetest.get_modpath("xanadu")

-- Heights for skyboxes
local underground_low = nether_mod and -28000 or -31000
local underground_high = -50
local space_low = 5000
local space_high = 5999
local redsky_low = 6000
local redsky_high = 6999

-- Holds name of skybox showing for each player
local player_list = {}

-- Outerspace skybox
local spaceskybox = {
	"sky_pos_z.png",
	"sky_neg_z.png^[transformR180",
	"sky_neg_y.png^[transformR270",
	"sky_pos_y.png^[transformR270",
	"sky_pos_x.png^[transformR270",
	"sky_neg_x.png^[transformR90"
}

-- Redsky skybox
local redskybox = {
	"sky_pos_z.png^[colorize:#99000050",
	"sky_neg_z.png^[transformR180^[colorize:#99000050",
	"sky_neg_y.png^[transformR270^[colorize:#99000050",
	"sky_pos_y.png^[transformR270^[colorize:#99000050",
	"sky_pos_x.png^[transformR270^[colorize:#99000050",
	"sky_neg_x.png^[transformR90^[colorize:#99000050"
}

-- Darkest space skybox
local darkskybox = {
	"sky_pos_z.png^[colorize:#00005070",
	"sky_neg_z.png^[transformR180^[colorize:#00005070",
	"sky_neg_y.png^[transformR270^[colorize:#00005070",
	"sky_pos_y.png^[transformR270^[colorize:#00005070",
	"sky_pos_x.png^[transformR270^[colorize:#00005070",
	"sky_neg_x.png^[transformR90^[colorize:#00005070"
}


-- check for active pova mod
local pova = minetest.get_modpath("pova")

-- gravity helper function
local set_gravity = function(player, grav)

	if pova then
		pova.add_override(player:get_player_name(), "default", {gravity = grav})
	else
		player:set_physics_override({gravity = grav})
	end
end


local timer = 0

minetest.register_globalstep(function(dtime)

	timer = timer + dtime

	if timer < 2 then
		return
	end

	timer = 0

	local name, pos, current

	for _, player in pairs(minetest.get_connected_players()) do

		name = player:get_player_name()
		pos = player:get_pos()
		current = player_list[name] or ""

		-- this just adds nether background for xanadu server
		if nether_mod and pos.y < underground_low and current ~= "nether" then

			player:set_sky({
				type = "plain",
				base_color = "#1d1118",
				clouds = false,
				sky_color = {
					day_horizon = "#9bc1f0",
					dawn_horizon = "#bac1f0",
					fog_tint_type = "default",
					dawn_sky = "#b4bafa",
					day_sky = "#8cbafa",
					night_sky = "#006aff",
					indoors = "#646464",
					night_horizon = "#4090ff"
				}
			})

			player:set_moon({visible = false})
			player:set_stars({visible = false})
			player:set_sun({visible = false, sunrise_visible = false})

			player_list[name] = "nether"

			if otherworlds.settings.gravity.enable then
				set_gravity(player, 1.05)
			end

		-- Underground (above Nether limit)
		elseif pos.y >= underground_low and pos.y <= underground_high
		and current ~= "underground" then

			player:set_sky({
				type = "plain",
				clouds = false,
				base_color = "#101010"
			})

			player:set_moon({visible = false})
			player:set_stars({visible = false})
			player:set_sun({visible = false, sunrise_visible = false})

			player_list[name] = "underground"

			if otherworlds.settings.gravity.enable then
				set_gravity(player, 1.0)
			end

		-- Earth
		elseif pos.y > underground_high and pos.y < space_low
		and current ~= "earth" then

			player:set_sky({
				type = "regular",
				clouds = true
			})

			player:set_moon({visible = true})
			player:set_stars({visible = true})
			player:set_sun({visible = true, scale = 1.0, sunrise_visible = true})

			player_list[name] = "earth"

			if otherworlds.settings.gravity.enable then
				set_gravity(player, 1.0)
			end

		-- Outerspace
		elseif pos.y >= space_low and pos.y <= space_high
		and current ~= "space" then

			player:set_sky({
				type = "skybox",
				textures = spaceskybox,
				clouds = false
			})

			player:set_moon({visible = false})
			player:set_stars({visible = false})
			player:set_sun({visible = true, scale = 1.0, sunrise_visible = false})

			player_list[name] = "space"

			if otherworlds.settings.gravity.enable then
				set_gravity(player, 0.4)
			end

		-- Redsky
		elseif pos.y >= redsky_low and pos.y <= redsky_high
		and current ~= "redsky" then

			player:set_sky({
				type = "skybox",
				textures = redskybox,
				clouds = false
			})

			player:set_moon({visible = false})
			player:set_stars({visible = false})
			player:set_sun({visible = true, scale = 0.5, sunrise_visible = false})

			player_list[name] = "redsky"

			if otherworlds.settings.gravity.enable then
				set_gravity(player, 0.2)
			end

		-- Everything else above (the blackness)
		elseif pos.y > redsky_high and current ~= "blackness" then

			player:set_sky({
				type = "skybox",
				textures = darkskybox,
				clouds = false
			})

			player:set_moon({visible = false})
			player:set_stars({visible = true})
			player:set_sun({visible = true, scale = 0.1})

			player_list[name] = "blackness"

			if otherworlds.settings.gravity.enable then
				set_gravity(player, 0.1)
			end
		end
	end
end)


minetest.register_on_leaveplayer(function(player)
	player_list[player:get_player_name()] = nil
end)


print("[MOD] Other Worlds loaded")
