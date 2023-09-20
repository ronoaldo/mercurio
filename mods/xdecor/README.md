## X-Decor-libre [`xdecor`] ##

[![ContentDB](https://content.minetest.net/packages/Wuzzy/xdecor/shields/downloads/)](https://content.minetest.net/packages/Wuzzy/xdecor/)

X-Decor-libre is a libre Minetest mod which adds various decorative blocks
as well as simple gimmicks.

This is a libre version (free software, free media) of the X-Decor mod for Minetest.
It is the same as X-Decor, except with all the non-free files replaced and with
bugfixes. There are no new features.

## Special nodes

Most blocks in this mod are purely decorative, but there are also many special
blocks with special features:

* Workbench: Storage, crafting, cutting and repairing
    * Storage: 16 item slots for item storage
    * Craft: 3×3 crafting grid
    * Cut: Put a full cube-shaped block to create new shapes
    * Repair: Put a damaged tool and a hammer and wait for it to be repaired
* Enchanting table: Upgrade your tools with mese crystals
* Ender Chest: Interdimensional inventory that is the same no matter
               where you put the ender chest
* Mailbox: Lets you receive items from other players
* Item Frame: You can place an item into it to show it off
* Cushion: Reduces fall damage
* Cushion Block: Reduces fall damage even more
* Trampoline: Jump on it to bounce off. Very low fall damage
* Cauldron: For storing water and cooking soups
    * Recipe: Pour water in, light a fire below it and throw
      in some food items. Collect the soup with a bowl
* Lever: Pull the lever to activate doors next to it
* Pressure Plate: Step on it to activate doors next to it
* Chessboard: Play Chess against a player or the computer (see `CHESS_README.md`)

The radio and speaker are purely decorative and have no special functionality.

### X-Decor-libre vs X-Decor

X-Decor is a popular mod in Minetest but it is (as the time of writing this text)
non-free software, there are various files under proprietary licenses.

The purpose of this repository is to provide the community a fully-free fork of
X-Decor with clearly documented licenses and to fix bugs. No new features are
planned.

#### List of changes
The following bugs of X-Decor (as of 01/07/2023) are fixed:

* Changed packed ice recipe to avoid recipe collision with Ethereal
* Changed prison door recipe colliding with Minetest Game's Iron Bar Door
* Beehives no longer show that the bees are busy when they're not
* Fixed incorrect/incomplete node sounds
* Fix poorly placed buttons in enchantment screen
* Fix broken texture of cut Permafrost with Moss nodes
* Fix awkward lantern rotation
* Lanterns can no longer attach to sides
* Fix item stacking issues of curtains
* Cauldrons no longer turn river water to normal water
* Fix boiling water in cauldrons not reliably cooling down
* Fix boiling water sound not playing when rejoining
* Fix cauldron with soup boiling forever
* Fix cauldrons being heated up by fireflies
* Fix rope and painting not compatible with itemframe
* Fix itemframe, lever being offset when put into itemframe
* Fix storage formspecs not closing if exploded
* Show short item description in itemframe instead of itemstring
* Minor typo fixes
* Fix bad rope placement prediction
* Fixed the broken Chess game

Maintenance updates:
* HUGE rework of Chess to make it actually be like real Chess (more or less)
* New supported Chess rules (based on the FIDE Laws of Chess)
    * En passant
    * Choose your pawn promotion
    * Fixed incomplete enforcement of castling rule
    * 50-turn rule and 75-turn rule
    * Threefold repetition rule and fivefold repetition rule
    * Announce the winner or loser, or a drawn game
* Many technical improvements for Chess
* Renamed blocks:
    * "Empty Shelf" to "Plain Shelf"
    * "Slide Door" to "Paper Door"
    * "Rooster" to "Weathercock"
    * "Stone Tile" to "Polished Stone Block"
    * "Desert Stone Tile" to "Polished Desert Stone Block"
    * "Iron Light Box" to "Steel Lattice Light Box"
    * "Wooden Light Box" to "Wooden Cross Light Box"
    * "Wooden Light Box 2" to "Wooden Rhombus Light Box"
* Added fuel recipes for wooden-based things
* Changed a few confusing recipes to make more sense
* Improved textures for cut glass, obsidian glass, woodframed glass,
  permafrost with moss and permafrost with stones
* Improved side texture of wood frame and rusty bar
* Add honey and cushion block to creative inventory
* Doors now count as nodes in creative inventory
* Cobwebs are no longer considered (fake) liquids
* Storage blocks now drop their inventory when exploded
* Made several strings translatable
* Translation updates
* Add support for playerphysics mod
* Add description to every setting
* Add tooltip extensions for some interactive items (uses `tt` mod)
* Add crafting guide support for `unified_inventory` mod (honey)
* Rope no longer extends infinitely in Creative Mode
* Added manual for Chess in `CHESS_README.md`

#### List of replaced files

This is the list of non-free files in the original X-Decor mod
(as of commit 8b614b3513f2719d5975c883180c011cb7428c8d)
that X-Decor-libre replaces:

* `textures/xdecor_candle_hanging.png`
* `textures/xdecor_radio_back.png`
* `textures/xdecor_radio_front.png`
* `textures/xdecor_radio_side.png`
* `textures/xdecor_radio_top.png`
* `textures/xdecor_rooster.png`
* `textures/xdecor_speaker_back.png`
* `textures/xdecor_speaker_front.png`
* `textures/xdecor_speaker_side.png`
* `textures/xdecor_speaker_top.png`
* `sounds/xdecor_enchanting.ogg`

(see `LICENSE` file for licensing).

## Technical information
X-Decor-libre is a fork of X-Decor, from <https://github.com/minetest-mods/xdecor>,
forked at Git commit ID 8b614b3513f2719d5975c883180c011cb7428c8d.

Note the technical mod name of X-Decor-libre is the same as for X-Decor: `xdecor`.
This is because this mod is meant to be a drop-in-replacement.

The original readme of X-Decor can be found at `OLD_README.md`.
