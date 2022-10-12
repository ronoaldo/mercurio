# Calendar API
This is the API documentation for the Calendar mod.

## Concepts
### Total days
Most functions use `total_days` to query the current date. This number is the
number of total elapsed days. You can get the 'elapsed days' number for today
in Minetest with `minetest.get_day_count()`.

### Ordinal and cardinal numbers
Cardinal number basically means the counting starts at 0.
Think of it as counting the number of elapsed days/months/years.

There are also ordinal numbers, which means the counting starts at 1.
This is for expressions like “1st January”.

Real calendars usually use ordinal numbers.

The calendar mod uses cardinal numbers internally to store the date internally,
this is only done to make calculations a bit simpler.
`total_days` is also a cardinal number.

## Calendar configuration
Before calling any other function, you probably want to configure the calendar first.
Call `calendar.config` to do so. This is not required, however, the calendar
has a default configuration:

By default, ayear has 12 months with 30 days each,
the months are January to December,
the week has 7 weekdays from Monday to Sunday, starting at Monday.

### `calendar.config(config)`
Configure calendar. Call this function before any other function.

`config` is a table with the following fields (all fields are optional):

* `MONTH_DAYS`: Days in a month
* `month_names`: List of month names (also determines number of months)
* `month_names_short`: List of short month names
* `weekday_names`: List of weekday names (also determines number of weekdays)
* `weekday_names_short`: List of short weekday names
* `FIRST_WEEK_DAY`: Cardinal number of the weekday that
                    marks the beginning of a week
                    and the calendar

Fields that were `nil` won't change. You can access each of the calender settings
later with `calender.<field name>`, e.g. `calendar.MONTH_DAYS`. Note this is
read-only access, you must never write to these fields directly. Only
use `calendar.config` to change these fields.

### Convenience variables
For convenience, there are also these shortcuts that are automatically set,
derived from the other values:

* `calendar.MONTHS`: Number of months in a year
* `calendar.WEEK_DAYS`: Number of days in a week
* `calendar.YEAR_DAYS`: Number of days in a year

## Functions

### `calendar.get_date(total_days, ordinal)`
Returns 4 values: days, months, years and days in year (in that order)

* `total_days`: Number of elapsed days (default: today)
* `ordinal`: if `true`, use ordinal numbers
             if `false`, use cardinal numbers
             default: false

### `calendar.get_total_days_from_date(days, months, years, is_ordinal)`
Given a date, returns the total number of elapsed days (cardinal number).

* `days`/`months`/`years`: Date
* `is_ordinal`: If `true`, date is interpreted as ordinal numbers, otherwise
                it is interpreted as cardinal numbers (default: `false`)

## `calendar.get_weekday(total_days)`
Returns cardinal weekday number for given day.

* `total_days`: Number of elapsed days (default: today)

### `calendar.get_date_string(format, total_days)`
Returns the game date as a human-readable string

* `format`: Optional tokenized string to represent the game date
            Default: `"%Y years, %M months, %D days"`
* `total_days`: Number of elapsed days (default: today)

The tokenized string may include one or more date specifiers:

Cardinal values:
* `%Y`: Elapsed years in epoch
* `%M`: Elapsed months in year
* `%D`: Elapsed days in month
* `%J`: Elapsed days in year

Ordinal values:
* `%y`: Current year of epoch
* `%m`: Current month of year
* `%d`: Current day of month
* `%j`: Current day of year

Other:
* `%b`: Full name of current month
* `%h`: Short name of current month
* `%W`: Full name of current weekday
* `%w`: Short name of current weekday
* `%z`: Literal percent sign

### `calendar.register_holiday(def)`

Register a holiday. A holiday is just a special named day in a calender and
can be used for whatever you like: Actual holidays, special events, reminders,
whatever.
By default, holidays will be marked in the graphical calendar.
Holidays can be queried with `calendar.get_holidays`.

* `def`: Holiday definition. A table with these fields:
    * `name`: Human-readable holiday name
    * `text_color` (optional): Custom text color of day/tooltip text
    * `daybox_color` (optional): Custom text color of day box
    * `type`: type of holiday, determines other arguments
    * Arguments when `type=="monthday"`:
        * `days`: Cardinal month day on which the holiday occurs
        * `months`: Cardinal month on which the holiday occurs
        * `years`: (optional) Cardinal year on which the holiday occurs. If not set, occurs every year
    * Arguments when `type=="custom"`:
        * `is_holiday`: Function that takes total days as parameter and must
                        return true if it's a holiday and false if not.
                        Try to keep your calculations as simple as possible

When no colors are specified, a default green color is used. When multiple holidays fall
on the same day and the holidays use different colors, the day box will assume the color
of the first registered holiday (the order is not predictable).

#### Examples
```
-- First day of every year
calendar.register_holiday({
	name = "New Year's Eve",
	type = "monthday",
	days = 0,
	months = 0
})

-- First Sunday in May
calendar.register_holiday({
	name = "Mother's Day",
	type = "custom",
	is_holiday = function(total_days)
		local d, m, y = calendar.get_date(total_days)
		local wday = calendar.get_weekday(total_days)
		return wday == 6 and m == 4 and d <= 6
	end,
})
```

### `calendar.get_holidays(total_days)`
Returns table of all holidays for the given day.

Each table value returns a reference to holiday definition that was
used in `calendar.register_holiday`.

* `total_days`: Number of elapsed days (default: today)



### `calendar.show_calendar(player_name, settings, wanted_months, wanted_years)`
Display a graphical calendar to player. It shows the days of a single month
with one numbered box per day. Also, holidays and the current day can be marked and
get a tooltip.

* `player_name`: Named of player
* `settings`: Table to customize calendar:
    * `ordinal`: If `true`, use ordinal numbers, otherwise, use cardinal numbers (default: `false`)
    * `show_weekdays`: If `true`, show weekdays and arrange the day boxes to weekdays (default: `true`)
    * `show_today`: If `true`, mark today (default: `true`)
    * `show_holiday`: If `true`, mark holidays (default: `true`)
    * `changable`: Which controls are available:
        * `"full"`: Can change year and month (default)
        * `"months"`: Can change month within selected year only
        * `"none"`: Can't change anything
    * `today_button`: Whether to show the 'Today' button (default: `true`)
                      Note: If `changable=="none"`, the 'Today' button is never shown
* `wanted_months`: Which cardinal calendar month to show (default: current one)
* `wanted_years`: Which cardinal calendar year to show (default: current one)
* `caption_format`: Optional format information to change the calendar caption.
                    Is a table with the following fields:
                    [1]: Format string with `minetest.translate`-style placeholders (from Minetest 5.0.0)
                    [2]: Translator domain for `minetest.translate`
                    [3]: and further: Parameters for the format string. For each parameter, use
                         a placeholder from `calender.get_date_string`.

Example for `caption_format`:

    { N("@1, year @2"), "mymod", "%b", "%Y" }

Will resolve to e.g. "January, Year 1".
`N` is a dummy function `function(s) return s end` that is used for the translation collector
script.
