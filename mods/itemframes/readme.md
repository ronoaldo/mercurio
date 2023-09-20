Item Frames mod for minetest

This mod differs from Zeg's original and the one included in homedecor modpack in that no one person owns the itemframe or pedestals, they are protected with minetest.is_protected() so can have multiple owners or none at all...  Items that have a light source will glow when placed in frames/pedestals.

Right-click to add or remove an item from a frame or pedestal, please note that if an item already has on_rightclick registered then it cannot be added to either.  Punch frame or pedestal to force update if items do not appear.

Itemframes can be rotated with a screwdriver which includes sitting flat on a surface, punch to update item inside.  You can also hold sneak and punch to rotate item inside frame.

License was originally WTFPL although the codebase has changed so much I've reclassified as MIT License for simplicity and school use, and textures are CC-BY-3.0.


Settings
--------

Change 'itemframes.return_item' setting to true if you want items to drop back into player inventory when removed (thanks fluxionary).

Change 'itemframes.log_actions' setting to true if you want to log player actions when inserting or removing items from a frame or pedestal.

Itemframe items can be rotated by holding sneak and punching frame, but in a protected area this is limited to the owner unless "itemframes.allow_rotate" setting is true.


Texture Override
----------------

If a node has the _itemframe_texture string set then the itemframe will show that image instead of the item's own wielditem (mainly for 3d items that may not look good in frames) e.g.

This shows furnaces inside an itemframe as a flat image:

minetest.override_item("default:furnace", {
	_itemframe_texture = "default_furnace_front.png"
})

This shows furance inside an itemframe as a 3D styled flat image:

minetest.override_item("default:furnace", {
	_itemframe_texture = minetest.inventorycube(
		"default_furnace_top.png",
		"default_furnace_side.png",
		"default_furnace_front.png")
})
