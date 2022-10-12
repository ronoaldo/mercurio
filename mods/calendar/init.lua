calendar = {}

-- Compability translator code to support MT 0.4, which doesn't support
-- translations for mods.
-- This adds two dummy or wrapper functions:
-- * minetest.translate ← calendar._translate
-- * minetest.get_translator ← calendar._get_translator

if not minetest.translate then
	-- No translation system available, use dummy functions
	function calendar._translate(textdomain, str, ...)
		local arg = {n=select('#', ...), ...}
		return str:gsub("@(.)", function(matched)
			local c = string.byte(matched)
			if string.byte("1") <= c and c <= string.byte("9") then
				return arg[c - string.byte("0")]
			else
				return matched
			end
		end)
	end

	function calendar._get_translator(textdomain)
		return function(str, ...) return calendar._translate(textdomain or "", str, ...) end
	end
else
	-- Translation system available, just user wrapper functions
	calendar._translate = minetest.translate
	calendar._get_translator = minetest.get_translator
end

local S = calendar._get_translator("calendar")

dofile(minetest.get_modpath("calendar").."/gameconfig.lua")

local function update_helper_vars()
	-- Number of months in a year
	calendar.MONTHS = #calendar.month_names
	-- Number of days in a week
	calendar.WEEK_DAYS = #calendar.weekday_names
	-- Number of days in a year
	calendar.YEAR_DAYS = calendar.MONTHS * calendar.MONTH_DAYS
end
update_helper_vars()

local holidays = {}

calendar.config = function(config)
	if config.MONTH_DAYS then
		calendar.MONTH_DAYS = config.MONTH_DAYS
	end
	if config.month_names then
		calendar.month_names = config.month_names
	end
	if config.month_names_short then
		calendar.month_names_short = config.month_names_short
	end
	if config.weekday_names then
		calendar.weekday_names = config.weekday_names
	end
	if config.weekday_names_short then
		calendar.weekday_names_short = config.weekday_names_short
	end
	if config.FIRST_WEEK_DAY then
		calendar.FIRST_WEEK_DAY = config.FIRST_WEEK_DAY
	end
	update_helper_vars()
end

calendar.register_holiday = function(def)
	table.insert(holidays, def)
end

calendar.get_holidays = function(total_days)
	if not total_days then
		total_days = minetest.get_day_count()
	end
	local days, months, years = calendar.get_date(total_days)
	local found_holidays = {}
	for h=1, #holidays do
		local holiday = holidays[h]
		if holiday.type == "monthday" then
			if holiday.days == days and holiday.months == months and (holiday.years == nil or holiday.years == years) then
				table.insert(found_holidays, holiday)
			end
		elseif holiday.type == "custom" then
			if holiday.is_holiday(total_days) == true then
				table.insert(found_holidays, holiday)
			end
		else
			minetest.log("error", "[calender] Invalid holiday type: "..tostring(holiday.type))
		end
	end
	return found_holidays
end

calendar.get_weekday = function(total_days)
	if not total_days then
		total_days = minetest.get_day_count()
	end
	return (total_days + calendar.FIRST_WEEK_DAY) % calendar.WEEK_DAYS
end

calendar.get_date = function(total_days, ordinal)
	if not total_days then
		total_days = minetest.get_day_count()
	end

	local y = math.floor(total_days / calendar.YEAR_DAYS) -- elapsed years in epoch
	local m = math.floor(total_days % calendar.YEAR_DAYS / calendar.MONTH_DAYS) -- elapsed months in year
	local d = math.floor(total_days % calendar.YEAR_DAYS % calendar.MONTH_DAYS) -- elapsed days in month
	local j = math.floor(total_days % calendar.YEAR_DAYS) -- elapsed days in year

	if ordinal == nil then
		ordinal = false
	end
	if ordinal then
		y = y + 1
		m = m + 1
		d = d + 1
		j = j + 1
	end
	return d, m, y, j
end

calendar.get_total_days_from_date = function(days, months, years, is_ordinal)
	if is_ordinal then
		days = days - 1
		months = months - 1
		years = years - 1
	end
	return years * calendar.YEAR_DAYS + months * calendar.MONTH_DAYS + days
end

calendar.get_date_string = function(format, total_days)
	if not total_days then
		total_days = minetest.get_day_count()
	end

	if format == nil then
		format = S("%D days, %M months, %Y years")
	end

	local y, m, d, j = calendar.get_date(total_days)
	local w = calendar.get_weekday(total_days)

	-- cardinal values
	format = string.gsub( format, "%%Y", y )	      -- elapsed years in epoch
	format = string.gsub( format, "%%M", m )	      -- elapsed months in year
	format = string.gsub( format, "%%D", d )	      -- elapsed days in month
	format = string.gsub( format, "%%J", j )	      -- elapsed days in year

	-- ordinal values
	format = string.gsub( format, "%%y", y + 1 )	  -- current year of epoch
	format = string.gsub( format, "%%m", m + 1 )	  -- current month of year
	format = string.gsub( format, "%%d", d + 1 )	  -- current day of month
	format = string.gsub( format, "%%j", j + 1 )	  -- current day of year

	format = string.gsub( format, "%%b", S(calendar.month_names[ m + 1 ]) )       -- current month long name
	format = string.gsub( format, "%%h", S(calendar.month_names_short[ m + 1 ]) )       -- current month short name

	format = string.gsub( format, "%%W", S(calendar.weekday_names[ w + 1 ]) )  -- current weekday long name
	format = string.gsub( format, "%%w", S(calendar.weekday_names_short[ w + 1 ]) ) -- current weekday short name

	format = string.gsub( format, "%%z", "%%" )

	return format
end

dofile(minetest.get_modpath("calendar").."/gui.lua")
