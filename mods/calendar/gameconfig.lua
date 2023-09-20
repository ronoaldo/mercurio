-- For translation collector script
local NS = function(s) return s end

-----------------------------
-- DEFAULT CALENDAR CONFIG --
-----------------------------

-- Number of days in a month
calendar.MONTH_DAYS = 30

-- List of long month names
-- (also determines the number of months in a year)
calendar.month_names = {
	NS('January'), NS('February'), NS('March'), NS('April'),
	NS('May'), NS('June'), NS('July'), NS('August'),
	NS('September'), NS('October'), NS('November'), NS('December')
}
-- Short month names
-- (must have same length as `calendar.month.names`)
calendar.month_names_short = {
	NS('Jan'), NS('Feb'), NS('Mar'), NS('Apr'),
	NS('May'), NS('Jun'), NS('Jul'), NS('Aug'),
	NS('Sep'), NS('Oct'), NS('Nov'), NS('Dec')
}

-- Long week day names
-- (also determines the number of days in a week)
calendar.weekday_names = {
	NS("Monday"), NS("Tuesday"), NS("Wednesday"),
	NS("Thursday"), NS("Friday"), NS("Saturday"), NS("Sunday")
}
-- Short week day names
-- (must have same length as `calendar.weekday_names`)
calendar.weekday_names_short = {
	NS("Mo"), NS("Tu"), NS("We"), NS("Th"), NS("Fr"), NS("Sa"), NS("Su")
}

-- Cardinal number of the week day that marks the beginning of a week
calendar.FIRST_WEEK_DAY = 0
