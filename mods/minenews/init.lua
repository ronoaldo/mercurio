-- Register bypass priv
minetest.register_privilege("news_bypass", {
	description = "Skip the news display on login.",
	give_to_singleplayer = false
})

-- Create formspec from text file
local function get_formspec(name)
	-- Lookup player language preference
	local player_info = minetest.get_player_information(name)
	local lang = player_info.lang_code
	if lang == "" then
		lang = "en"
	end
	-- Lookup news file to display, trying by language first, with a default news.md
	-- fallback.
	local news_filename = minetest.get_worldpath().."/news_"..lang..".md"
	local news_file = io.open(news_filename, "r")
	if not news_file then
		news_filename = minetest.get_worldpath().."/news.md"
		news_file = io.open(news_filename, "r")
	end
	minetest.log("verbose", "Displaying news to player "..name.." in "..lang.." from file "..news_filename)

	-- Settings
	local fg_color = minetest.settings:get("minenews.fg_color") or "#AFAFAF"
	local bg_color = minetest.settings:get("minenews.bg_color") or "#34343400"
	local header_color = minetest.settings:get("minenews.header_color") or "#CFCFCF"
	local mono_color = minetest.settings:get("minenews.mono_color") or "#6ED2CF"
	local discord_link = minetest.settings:get("minenews.discord_invite") or ""

	-- Display the formspec for the server news
	local news_fs = "formspec_version[5]"..
		"size[24,16]"..
		"noprepend[]"..
		"bgcolor["..bg_color.."]"..
		"button_exit[20.8,14.8;3,1;close;OK]"

	if discord_link ~= "" then
		news_fs = news_fs..
			"image[0.2,14.8;1,1;minenews_icon_chat_white.png]"..
			"field[1.3,14.8;19.2,1;discord_invite;;"..discord_link.."]"
	end

	local news = "No news for today."
	if news_file then
		news = news_file:read("*a")
		news_file:close()
	end

	-- Render the file as markdown
	local settings = {
		background_color = bg_color,
		font_color = fg_color,
		heading_1_color = header_color,
		heading_2_color = header_color,
		heading_3_color = header_color,
		heading_4_color = header_color,
		heading_5_color = header_color,
		heading_6_color = header_color,
		heading_1_size = "26",
		heading_2_size = "22",
		heading_3_size = "18",
		heading_4_size = "18",
		heading_5_size = "18",
		heading_6_size = "18",
		code_block_mono_color = mono_color,
		code_block_font_size = 14,
		mono_color = mono_color,
		block_quote_color = mono_color,
	}
	news_fs = news_fs..md2f.md2f(0.2, 0.5, 23.6, 13.8, news, "news", settings)
	minetest.log("verbose", "Formspec => "..news_fs)
	return news_fs
end

-- Show news formspec on player join, unless player has bypass priv
local function on_joinplayer(player)
	local name = player:get_player_name()
	if player:get_hp() <= 0 then
		return
	elseif minetest.get_player_privs(name).news_bypass then
		return
	else
		minetest.show_formspec(name, "news", get_formspec(name))
	end
end
-- Register callback
minetest.register_on_joinplayer(on_joinplayer)

-- Command to display server news at any time
minetest.register_chatcommand("news", {
	description = "Shows server news to the player",
	func = function (name)
		minetest.show_formspec(name, "news", get_formspec(name))
	end
})

-- Exported API
minenews = {}
minenews.on_joinplayer = on_joinplayer