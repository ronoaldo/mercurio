# Calendar

This mod adds a simple and customizable calender system.

The calendar supports days, weeks, months and years.
Holidays are also supported.

To make things simpler, all months have the same length.

By default, a year has 12 months (January to December) with 30 days each.
There are 7 weekdays from Monday to Sunday, starting at Monday.
The calendar starts at Day 1, Month 1 (January), Year 1.

## Version
1.1.3

## Compability
This mod is designed for Minetest 5.3.0, but there's a compability
mode for version 0.4.17.

Due to a limited feature set, the calender form looks a bit differently
in 0.4.17. Fake buttons are used for the day boxes to allow the use of
tooltips.

## Customizing the calendar
If you want to customize the calendar (e.g. change the length of months),
read the text file `API.md`.

## Info for programmers
See `API.md`.

## Where is the date stored?
Minetest stores the number of elapsed days in the world files and it
can be queried in Lua via `minetest.get_day_count()`.
The day count is stored in the world directory under `env_meta.txt` as
`day_count`.

## License
This entire mod is licensed under the
GNU Lesser General Public License version 3 (LGPL-3.0).

This mod was created by Wuzzy. A small portion of the mod was adopted
from the [belfry] mod by sorcerykid, namely `calendar.get_date_string`,
based on `minetest.get_date_string` from the `belfry` mod.

Translation credits:

* German: Wuzzy
* French: syl
