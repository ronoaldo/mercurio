Item Frames mod for minetest

This mod differs from Zeg's original and the one included in homedecor modpack in that no one person owns the itemframe or pedestals, they are protected with minetest.is_protected() so can have multiple owners or none at all...  Items that have a light source will glow when placed in frames/pedestals.

Right-click to add or remove an item from a frame or pedestal, please note that if an item already has on_rightclick registered then it cannot be added to either.  Punch frame or pedestal to force update if items do not appear.

Itemframes can be rotated with a screwdriver which includes sitting flat on a surface, punch to update item inside.

License was originally WTFPL although the codebase has changed so much I've reclassified as MIT License for simplicity and school use, and textures are CC-BY-3.0.

Settings
--------

Change 'itemframes.return_item' setting to true if you want items to drop back into player inventory when removed (thanks fluxionary).

Change 'itemframes.log_actions' setting to true if you want to log player actions when inserting or removing items from a frame or pedestal.
