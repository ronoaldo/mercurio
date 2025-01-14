
-- Heights for skyboxes

local underground_low = -31000
local underground_high = -50
local space_low = 5000
local space_high = 5999
local redsky_low = 6000
local redsky_high = 6999
local nether_low = -32000
local nether_high = -31000

-- Nether check

local mod_nether = minetest.get_modpath("nether")

if mod_nether then

	nether_low = nether.DEPTH_FLOOR or -32000
	nether_high = nether.DEPTH_CEILING or -31000
	underground_low = nether_high

	if minetest.get_modpath("climate_api") then
		mod_nether = nil -- remove nether skybox for climate_api version
	end
end

-- Holds name of skybox showing for each player

local player_list = {}

-- Outerspace skybox

local spaceskybox = {
	"sky_pos_z.png",
	"sky_neg_z.png^[transformR180",
	"sky_neg_y.png^[transformR270",
	"sky_pos_y.png^[transformR270",
	"sky_pos_x.png^[transformR270",
	"sky_neg_x.png^[transformR90"}

-- Redsky skybox

local redskybox = {
	"sky_pos_z.png^[colorize:#99000050",
	"sky_neg_z.png^[transformR180^[colorize:#99000050",
	"sky_neg_y.png^[transformR270^[colorize:#99000050",
	"sky_pos_y.png^[transformR270^[colorize:#99000050",
	"sky_pos_x.png^[transformR270^[colorize:#99000050",
	"sky_neg_x.png^[transformR90^[colorize:#99000050"}

-- Darkest space skybox

local darkskybox = {
	"sky_pos_z.png^[colorize:#00005070",
	"sky_neg_z.png^[transformR180^[colorize:#00005070",
	"sky_neg_y.png^[transformR270^[colorize:#00005070",
	"sky_pos_y.png^[transformR270^[colorize:#00005070",
	"sky_pos_x.png^[transformR270^[colorize:#00005070",
	"sky_neg_x.png^[transformR90^[colorize:#00005070"}

-- check for active pova mod

local mod_pova = minetest.get_modpath("pova")

-- gravity helper function

local function set_gravity(player, grav)

	if mod_pova then
		pova.add_override(player:get_player_name(), "default", {gravity = grav})
	else
		player:set_physics_override({gravity = grav})
	end
end

-- globalstep function runs every 2 seconds to show appropriate skybox

local timer, timer2 = 0, 0

minetest.register_globalstep(function(dtime)

	timer = timer + dtime ; if timer < 2 then return end ; timer = 0
	timer2 = timer2 + 2

	local name, pos, current

	for _, player in pairs(minetest.get_connected_players()) do

		name = player:get_player_name()
		pos = player:get_pos()
		current = player_list[name] or ""

		-- this just adds nether background outwith climate_api mod

		if mod_nether and pos.y >= nether_low and pos.y <= nether_high
		and (current ~= "nether" or (current == "nether" and timer2 > 6)) then

			timer2 = 0 -- reset nether layer timer (every 10 seconds)

			local base_col = current ~= "nether" and "#1D0504"
			local ps, cn = minetest.find_nodes_in_area(
					{x = pos.x - 6, y = pos.y - 6, z = pos.z - 6},
					{x = pos.x + 6, y = pos.y + 6, z = pos.z + 6},
					{"nether:rack", "nether:rack_deep", "nether:geode", "nether:geodelite"})

			-- easy find nether layer via quick node count

			if (cn["nether:rack"] or 0) > 100 then
				base_col = "#1D0504"
			elseif (cn["nether:rack_deep"] or 0) > 100 then
				base_col = "#070916"
			elseif (cn["nether:geode"] or 0) + (cn["nether:geodelite"] or 0)> 100 then
				base_col = "#300530"
			end

			if base_col then
				player:set_sky({type = "plain", base_color = base_col, clouds = false})
			end

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

			player:set_sky({type = "plain", clouds = false, base_color = "#101010"})
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

			player:set_sky({type = "regular", clouds = true})
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

			player:set_sky({type = "skybox", textures = spaceskybox, clouds = false,
					base_color = "#000000"})
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

			player:set_sky({type = "skybox", textures = redskybox, clouds = false,
					base_color = "#000000"})
			player:set_moon({visible = false})
			player:set_stars({visible = false})
			player:set_sun({visible = true, scale = 0.5, sunrise_visible = false})

			player_list[name] = "redsky"

			if otherworlds.settings.gravity.enable then
				set_gravity(player, 0.2)
			end

		-- Everything else above (the blackness)

		elseif pos.y > redsky_high and current ~= "blackness" then

			player:set_sky({type = "skybox", textures = darkskybox, clouds = false,
					base_color = "#000000"})
			player:set_moon({visible = false})
			player:set_stars({visible = true})
			player:set_sun({visible = true, scale = 0.1, sunrise_visible = false})

			player_list[name] = "blackness"

			if otherworlds.settings.gravity.enable then
				set_gravity(player, 0.1)
			end
		end
	end
end)

-- remove player from list when they leave

minetest.register_on_leaveplayer(function(player)
	player_list[player:get_player_name()] = nil
end)
