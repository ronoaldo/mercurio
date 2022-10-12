-- For translation collector script
local N = function(s) return s end

-----------------------------
-- DEFAULT CALENDAR CONFIG --
-----------------------------

-- Number of days in a month
calendar.MONTH_DAYS = 30

-- List of long month names
-- (also determines the number of months in a year)
calendar.month_names = {
	N('January'), N('February'), N('March'), N('April'),
	N('May'), N('June'), N('July'), N('August'),
	N('September'), N('October'), N('November'), N('December')
}
-- Short month names
-- (must have same length as `calendar.month.names`)
calendar.month_names_short = {
	N('Jan'), N('Feb'), N('Mar'), N('Apr'),
	N('May'), N('Jun'), N('Jul'), N('Aug'),
	N('Sep'), N('Oct'), N('Nov'), N('Dec')
}

-- Long week day names
-- (also determines the number of days in a week)
calendar.weekday_names = {
	N("Monday"), N("Tuesday"), N("Wednesday"),
	N("Thursday"), N("Friday"), N("Saturday"), N("Sunday")
}
-- Short week day names
-- (must have same length as `calendar.weekday_names`)
calendar.weekday_names_short = {
	N("Mo"), N("Tu"), N("We"), N("Th"), N("Fr"), N("Sa"), N("Su")
}

-- Cardinal number of the week day that marks the beginning of a week
calendar.FIRST_WEEK_DAY = 0
