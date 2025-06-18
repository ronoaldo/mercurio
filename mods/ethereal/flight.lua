
-- translation and settings

local S = core.get_translator("ethereal")
local flight_secs = core.settings:get("ethereal.flightpotion_duration") or (5 * 60)
local timer_check = 5 -- seconds per check

-- get player timer

local function get_timer(user)

	if not user then return end

	local meta = user:get_meta() ; if not meta then return "" end

	return meta:get_string("ethereal:fly_timer") or ""
end

-- do we have fly privs

local function has_fly(name)
	return core.get_player_privs(name).fly
end

-- set player timer

local function set_timer(user, timer)

	local meta = user:get_meta() ; if not meta then return end

	meta:set_string("ethereal:fly_timer", timer)
end

-- give or revoke fly priv

local function set_flight(user, set)

	local name = user and user:get_player_name() ; if not name then return end
	local privs = core.get_player_privs(name)

	privs.fly = set

	core.set_player_privs(name, privs)

	-- when flight removed set timer to temp position
	if set ~= true then set_timer(user, "-99") end
end

-- after function

local function ethereal_set_flight(user)

	local name = user and user:get_player_name() ; if not name then return end

	local timer = tonumber(get_timer(user)) or 0

	-- if timer ran out then remove 'fly' privelage
	if timer <= 0 and timer ~= -99 then

		set_flight(user, nil)

		return
	end

	local privs = core.get_player_privs(name)

	-- have we already applied 'fly' privelage?
	if not privs.fly then set_flight(user, true) end

	-- handle timer
	timer = timer - timer_check

	-- show expiration message and play sound
	if timer <= 10 then

		core.chat_send_player(name, core.get_color_escape_sequence("#ff5500")
				.. S("Flight timer about to expire!"))

		core.sound_play("default_dig_dig_immediate",
				{to_player = name, gain = 1.0}, true)
	end

	set_timer(user, timer) -- set update timer

	-- restart checks
	core.after(timer_check, function()
		ethereal_set_flight(user)
	end)
end

-- on join / leave

core.register_on_joinplayer(function(player)

	-- wait 2 seconds before doing flight checks on player
	core.after(2.0, function(player)

		-- get player name and timer
		local name = player and player:get_player_name() ; if not name then return end
		local timer = get_timer(player)

		-- if timer is blank and player can already fly then default and return
		if timer == "" and has_fly(name) then

			set_timer(player, "-99")

			return
		end

		timer = tonumber(timer) or 0

		-- if timer is set to default then return
		if timer == -99 then return end

		-- if we got this far and player is flying then start countdown check
		if has_fly(name) then

			core.after(timer_check, function()
				ethereal_set_flight(player)
			end)
		end

	end, player)
end)

-- potion item

core.register_node("ethereal:flight_potion", {
	description = S("Flight Potion"),
	drawtype = "plantlike",
	tiles = {"ethereal_flight_potion.png"},
	inventory_image = "ethereal_flight_potion.png",
	wield_image = "ethereal_flight_potion.png",
	paramtype = "light",
	sunlight_propagates = true,
	walkable = false,
	selection_box = {
		type = "fixed", fixed = {-0.2, -0.37, -0.2, 0.2, 0.31, 0.2}
	},
	groups = {dig_immediate = 3, vessel = 1},
	sounds = default.node_sound_glass_defaults(),

	on_use = function(itemstack, user, pointed_thing)

		if user.is_fake_player then return end

		-- get info
		local name = user:get_player_name()
		local privs = core.get_player_privs(name)
		local timer = get_timer(user)

		if privs.fly then

			local msg = timer

			if timer == "" or timer == "-99" then msg = S("unlimited") end

			core.chat_send_player(name, core.get_color_escape_sequence("#ffff00")
					.. S("Flight already granted, @1 seconds left!", msg))

			return
		end

		set_timer(user, flight_secs) -- set flight timer

		-- show time remaining
		core.chat_send_player(name,
				core.get_color_escape_sequence("#1eff00")
				.. S("Flight granted, you have @1 seconds!", flight_secs))

		ethereal_set_flight(user) -- start check

		itemstack:take_item() -- take item

		-- return empty bottle
		local inv = user:get_inventory()

		if inv:room_for_item("main", {name = "vessels:glass_bottle"}) then
			user:get_inventory():add_item("main", "vessels:glass_bottle")
		else
			core.add_item(user:get_pos(), {name = "vessels:glass_bottle"})
		end

		return itemstack
	end
})

-- recipe

core.register_craft({
	output = "ethereal:flight_potion",
	recipe = {
		{"ethereal:etherium_dust", "ethereal:etherium_dust", "ethereal:etherium_dust"},
		{"ethereal:etherium_dust", "ethereal:fire_dust", "ethereal:etherium_dust"},
		{"ethereal:etherium_dust", "vessels:glass_bottle", "ethereal:etherium_dust"}
	}
})
