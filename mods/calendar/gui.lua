local S = calendar._get_translator("calendar")
local F = minetest.formspec_escape

local player_current_calendars = {}

-- Colors
local COLOR_HOLIDAY = "#00FF00"
local COLOR_DAYBOX_HOLIDAY = "#00940FFF"
local COLOR_DAYBOX = "#1A1A1AFF"
local COLOR_DAYBOX_TODAY = "#FFF508FF"
local COLOR_TOOLTIP_TODAY = COLOR_DAYBOX_TODAY

-- Default settings
local ORDINAL = true
local SHOW_WEEKDAYS = true
local SHOW_TODAY = true
local SHOW_HOLIDAYS = true
local CHANGABLE = "full"
local TODAY_BUTTON = true
local DEFAULT_SETTINGS = {
	ordinal = ORDINAL,
	show_weekdays = SHOW_WEEKDAYS,
	show_today = SHOW_TODAY,
	show_holidays = SHOW_HOLIDAYS,
	changable = CHANGABLE,
	today_button = TODAY_BUTTON,
}

-- Offset between dayboxes
local DAYBOX_OFFSET
if minetest.features.formspec_version_element then
	DAYBOX_OFFSET = 0.1
else
	DAYBOX_OFFSET = 0
end

-- Check if area tooltips are supported.
-- minetest.features, doesn't tell us that directly, but
-- the formspec version element was added after area tooltips,
-- so if those are present, area tooltips have to be supported as well.
local SHOW_AREA_TOOLTIPS = minetest.features.formspec_version_element

function calendar.show_calendar(player_name, settings, wanted_months, wanted_years, caption_format)
	-- Get settings, use defaults if needed
	if not settings then
		settings = DEFAULT_SETTINGS
	end
	for k,v in pairs(DEFAULT_SETTINGS) do
		if settings[k] == nil then
			settings[k] = v
		end
	end

	local days, months, years = calendar.get_date()
	local total_days = minetest.get_day_count()
	local wanted_dyears
	if not wanted_months then
		wanted_months = months
	end
	if not wanted_years then
		wanted_years = years
	end
	wanted_dyears = wanted_years
	if settings.ordinal then
		wanted_dyears = wanted_dyears + 1
	end
	local tdays = 0
	tdays = tdays + wanted_years * (calendar.MONTHS * calendar.MONTH_DAYS)
	tdays = tdays + wanted_months * calendar.MONTH_DAYS

	-- Render caption
	local formspec = ""
	local caption = ""
	if caption_format then
		local args = {}
		if caption_format[3] then
			for a=3, #caption_format do
				table.insert(args, calendar.get_date_string(caption_format[a], tdays))
			end
		end
		caption = calendar._translate(caption_format[2], caption_format[1], unpack(args))
	else
		if settings.ordinal then
			caption = S("@1, year @2", S(calendar.month_names[wanted_months+1]), wanted_dyears)
		else
			caption = S("@1, @2 years", S(calendar.month_names[wanted_months+1]), wanted_dyears)
		end
	end
	if caption ~= "" then
		formspec = formspec .. "label[0.5,0.5;"..F(caption).."]"
	end

	-- Render weekday names
	local tdays_start = tdays
	local weekday, x, y
	if settings.show_weekdays then
		weekday = calendar.get_weekday(tdays)
		x, y = 0.75, 1.2
		for w=1, #calendar.weekday_names_short do
			formspec = formspec .. "label["..x..","..y..";"..F(S(calendar.weekday_names_short[w])).."]"
			x = x + 1 + DAYBOX_OFFSET
		end
	else
		weekday = 0
	end

	-- Render day boxes, day numbers and highlights
	x, y = 0.5, 1.7
	for iday=0, calendar.MONTH_DAYS - 1 do
		weekday = weekday + 1
		if weekday > calendar.WEEK_DAYS then
			weekday = 1
			y = y + 1 + DAYBOX_OFFSET
		end
		x = (weekday * (1 + DAYBOX_OFFSET)) - 0.5
		local pday = iday
		if settings.ordinal then
			pday = iday + 1
		end
		local day_str = tostring(pday)
		local holiday_color
		local box_color = COLOR_DAYBOX
		local holidays = calendar.get_holidays(tdays)
		local tooltip_lines = {}
		-- Highlight holiday
		local is_holiday = false
		if settings.show_holidays and #holidays > 0 then
			is_holiday = true
			local text_color = COLOR_HOLIDAY
			for h=1, #holidays do
				if holidays[h].text_color then
					text_color = holidays[h].text_color
				else
					text_color = COLOR_HOLIDAY
				end
				table.insert(tooltip_lines, minetest.colorize(text_color, holidays[h].name))
                        end
			holiday_color = holidays[1].text_color or COLOR_HOLIDAY
			day_str = minetest.colorize(holiday_color, day_str)
			box_color = holidays[1].daybox_color or COLOR_DAYBOX_HOLIDAY
		end
		day_str = F(day_str)
		-- Highlight today
		if settings.show_today and tdays == total_days then
			if SHOW_AREA_TOOLTIPS then
				formspec = formspec .. "box["..(x-0.05)..","..(y-0.05)..";1.1,1.1;"..COLOR_DAYBOX_TODAY.."]"
			else
				formspec = formspec .. "box["..(x-0.075)..","..(y-0.075)..";0.95,1.05;"..COLOR_DAYBOX_TODAY.."]"
			end
			table.insert(tooltip_lines, minetest.colorize(COLOR_TOOLTIP_TODAY, S("Today")))
		end
		if SHOW_AREA_TOOLTIPS then
			formspec = formspec .. "box["..x..","..y..";1,1;"..box_color.."]"
				.. "label["..(x+0.15)..","..(y+0.075)..";"..day_str.."]"
		else
			local day_num = pday
			if is_holiday and settings.show_holidays then
				day_num = minetest.colorize(holiday_color, pday)
			end
			-- Fake button to display the day box. Clicking has no effect, this
			-- fake button is only used to support tooltips as a workaround
			-- for lacking support of area tooltips
			formspec = formspec .. "image_button["..x..","..y..";1,1;"..
				F("calendar_legacy_daybox.png^[colorize:"..box_color..":255]")..
				";day"..iday..";"..F(day_num).."]"
		end
		if #tooltip_lines > 0 then
			local tooltips = F(table.concat(tooltip_lines, "\n"))
			if SHOW_AREA_TOOLTIPS then
				formspec = formspec .. "tooltip["..x..","..y..";1,1;"..F(tooltips).."]"
			else
				formspec = formspec .. "tooltip[day"..iday..";"..F(tooltips).."]"
			end
		end
		tdays = tdays + 1
	end
	y = y + 1 + DAYBOX_OFFSET
	if settings.show_weekdays and calendar.get_weekday(tdays_start) <= calendar.get_weekday(tdays - 1) then
		y = y + 1 + DAYBOX_OFFSET
	end
	y = y + DAYBOX_OFFSET
	local chg_months = settings.changable == "full" or settings.changable == "months"
	local chg_years = settings.changable == "full"
	-- Add controls
	if chg_months then

		if wanted_months > 0 or wanted_years > 0 then
			if (chg_years or wanted_months > 0) or (not chg_years and wanted_months > 0) then
				formspec = formspec .. "button[1.5,"..y..";1,1;prev_month;<]"
					.. "tooltip[prev_month;"..F(S("Previous month")).."]"
			end
			if chg_years then
				formspec = formspec .. "button[0.5,"..y..";1,1;prev_year;<<]"
					.. "tooltip[prev_year;"..F(S("Previous year")).."]"
			end
		end
		if settings.today_button then
			formspec = formspec .. "button[2.5,"..y..";2,1;today;"..F(S("Today")).."]"
		end

		if (chg_years or wanted_months < calendar.MONTHS - 1) or (not chg_years and wanted_months < calendar.MONTHS - 1) then
			formspec = formspec .. "button[4.5,"..y..";1,1;next_month;>]"
				.. "tooltip[next_month;"..F(S("Next month")).."]"
		end
		if chg_years then
			formspec = formspec .. "button[5.5,"..y..";1,1;next_year;>>]"
				.. "tooltip[next_year;"..F(S("Next year")).."]"
		end
	end
	local size_x = math.max(calendar.WEEK_DAYS+2, 7)
	local size_y = y+1.5

	-- Formspec config
	if minetest.features.formspec_version_element then
		formspec = "formspec_version[3]" .. formspec
	end
	formspec = "size["..size_x..","..size_y.."]" .. formspec
	minetest.show_formspec(player_name, "calendar:calendar", formspec)

	player_current_calendars[player_name] =
		{ years = wanted_years, months = wanted_months, settings = settings, caption_format = caption_format }
end

minetest.register_on_player_receive_fields(function(player, formname, fields)
	if formname ~= "calendar:calendar" then
		return
	end
	if not player:is_player() then
		return
	end
	local name = player:get_player_name()
	local cur_years, cur_months
	if not player_current_calendars then
		return
	end
	local show = false
	cur_years = player_current_calendars[name].years
	cur_months = player_current_calendars[name].months
	local settings = player_current_calendars[name].settings
	if fields.today then
		cur_years, cur_months = nil, nil
		show = true
	end
	if settings.changable == "full" then
		if fields.next_year then
			cur_years = cur_years + 1
			show = true
		elseif fields.prev_year then
			if cur_years == 0 then
				cur_months = 0
			else
				cur_years = cur_years - 1
			end
			show = true
		end
	end
	if fields.next_month then
		cur_months = cur_months + 1
		if cur_months > calendar.MONTHS - 1 then
			if settings.changable == "full" then
				cur_months = 0
				cur_years = cur_years + 1
			else
				cur_months = calendar.MONTHS - 1
			end
		end
		show = true
	elseif fields.prev_month then
		cur_months = cur_months - 1
		if cur_months < 0 and cur_years > 0 then
			if settings.changable == "full" then
				cur_months = calendar.MONTHS - 1
				cur_years = cur_years - 1
			else
				cur_months = 0
			end
		end
		show = true
	end
	if show then
		calendar.show_calendar(name,
			settings,
			cur_months, cur_years,
			player_current_calendars[name].caption_format
		)
	end
end)

minetest.register_on_leaveplayer(function(player)
	local name = player:get_player_name()
	player_current_calendars[name] = nil
end)

