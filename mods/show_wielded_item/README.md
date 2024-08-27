# Show Wielded Item [`show_wielded_item`]
This Minetest mod displays the name of the wielded item above the hotbar and
statbars.

This mod is compatible with the HUD Bars [`hudbars`] mod.
This mod *disables* itself if Unified Inventory is detected to show item names.
Compatibility with other HUD-related mods is possible, but not guaranteed.

Version: 1.2.1

## A note for Unified Inventory users

The mod Unified Inventory adds its own wielded item display (as of 16/08/2024).
So if you use that mod and have the item names features of that mod
enabled, then Unified Inventory takes precedence.

If the Unified Inventory mod was detected, and the setting
`unified_inventory_item_names` is set to `true`, then
`show_wielded_item` won’t do anything and let Unified Inventory
display the wielded item instead. A message will appear in
the debug log if this happens.

## Credits
Released by Wuzzy.
The original mod code was taken from the file “`item_names.lua`”
found in the Unified Inventory mod maintained by VanessaE. This code
has been later modified.
Original author: 4aiman

## License
This mod is licensed under GNU LGPLv2 or later
(see <https://www.gnu.org/licenses/lgpl-2.1.html>).
