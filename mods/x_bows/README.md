# Bow and Arrows [x_bows]

Adds bow and arrows with API. The goal of this Mod is to make most complete single bow with arrow what will work with MTG damage system, time from last punch as simple as possible. Eventually due to the damage tiers in MTG additional arrows were added.

![screenshot](screenshot.png)

Video: https://youtu.be/pItpltmUoa8

## Features

* bow will force you sneak when loaded (optional dep. playerphysics)
* loaded bow will slightly adjust the player FOV
* bow uses minetest tool capabilities - if the bow is not loaded for long enough (time from last puch) the arrow will fly shorter range
* charged bow in inventory will discharge and give back the arrow when not selected
* arrow uses raycast
* arrow has chance of critical shots/hits (only on full punch interval)
* arrow uses minetest damage calculation (including 3d_armor) for making damage (no hardcoded values)
* arrows stick to nodes, players and entitites
* arrows remove them self from the world after some time
* arrows remove them self if there are already too many arrows attached to node, player, entity
* arrow continues to fly downwards when attached node is dug
* arrow flies under water for short period of time and then sinks
* arrows adjusts pitch when flying
* arrows can be picked up again after stuck in solid nodes
* registers only one entity reused for all arrows
* target block reduces fall damage by -30
* quiver for more arrow storage (can hold only arrows)
* quiver perks when in inventory (faster arrows, more arrow damage...)
* quiver shows temporarily its inventory in HUD overlay when loading or shooting (quickview)
* quiver item shows its content in infotext (hover over the item)
* X Bows API for creating custom shooters and projectiles
* 3d quiver shown in 3rd person view (compatible with 3d armor)
* x_enchanting support

## How To

### Bow

With the bow selected in hotbar and in your hand, press right click on mouse (PC) or the same action as when placing blocks, to load the bow.
For bow to be loaded you have to have arrows in the arrow/quiver inventory - there should be extra tab in your inventory MOD to show arrow and quiver inventory slots.
Arrows and quivers in the players main inventory don't count and will not be used.
You have to have arrows and/or quiver in dedicated arrow/quiver inventory slots in order to charge the bow.
Charging bow will have slight sound effect and can be fired at any time with left click (PC)
or the same action as when you are digging a block. Waiting for full charge of the bow is recommended
as it will give the arrow full speed (maximum shooting distance) and chance for critical arrow (double damage).

There are few indications on how to know when the bow is fully charged:

* there is a distinct "click" sound
* each arrow has "charge time" in the description
* after shooting, arrow will have particle trail

There are few indications on how to know when the arrow is a critical arrow:

* there is a distinct arrow flying sound
* after shooting, arrow will have red particle trail

If you shoot the arrow before the bow is fully charged the speed/distance will be lower and no arrow particle trail will be shown (also no chance for critical arrow).
Changing the selection in hotbar will unload the bow and give you back arrow from the unloaded bow - this applies also when login in to the game (bow will be discharged and arrow will be returned to inventory) and also when you drop the charged arrow (discharged bow will be dropped with arrow item).
If you have `playerphysics` or `player_monoids` mod installed, charged bow will slow you down until you release the arrow.

### Quiver

Quiver item can hold inventory of arrows. When player has quiver in his/hers quiver inventory slot - there should be extra tab in your inventory MOD to show arrow and quiver inventory slots, bow can take arrows from quiver, otherwise arrows outside of the quiver are used to load the bow.
Though, if arrows from quiver are used to load the bow, the arrows have additional speed and damage.
If we are loading/shooting arrows from quiver, there is temporary quickview HUD overlay shown, peeking in to the quivers inventory from which the arrow was taken. Arrows used from quiver will be faster only when the bow is fully charged - see "How To - Bow" for more information on how to know when bow is fully charged.

There are few indications on how to know when the bow shot arrow from quiver:

* there is temporary HUD overview shown peeking in to the quiver inventory
* after shooting, arrow will have blue/purple particle trail (if bow was fully charged)

## Dependencies

- none

## Optional Dependencies

- default (recipes)
- farming (bow and target recipes)
- 3d_armor (calculates damage including the armor)
- mesecons (target can be used to trigger mesecon signal)
- playerphysics (force sneak when holding charged bow)
- player_monoids (force sneak when holding charged bow)
- wool (quiver recipe)
- i3
- unified_inventory
- simple_skins
- u_skins
- wardrobe
- sfinv
- skinsdb
- player_api (shows 3d quiver)

## License:

### Code

GNU Lesser General Public License v2.1 or later (see included LICENSE file)

### Textures

**CC BY-SA 4.0, Pixel Perfection by XSSheep**, https://minecraft.curseforge.com/projects/pixel-perfection-freshly-updated

- x_bows_bow_wood.png
- x_bows_bow_wood_charged.png
- x_bows_arrow_wood.png
- x_bows_arrow_particle.png
- x_bows_bubble.png
- x_bows_target.png

Modified by SaKeL:

- x_bows_arrow_stone.png
- x_bows_arrow_bronze.png
- x_bows_arrow_steel.png
- x_bows_arrow_mese.png
- x_bows_arrow_diamond.png

**CC-BY-SA-3.0, by paramat**

- x_bows_hotbar_selected.png
- x_bows_quiver_hotbar.png
- x_bows_single_hotbar.png

**LGPL-2.1-or-later, by SaKeL**

- x_bows_quiver.png
- x_bows_quiver_open.png
- x_bows_arrow_slot.png
- x_bows_arrow_mesh.png
- x_bows_quiver_mesh.png
- x_bows_quiver_empty_mesh.png
- x_bows_quiver_blank_mesh.png
- x_bows_quiver_slot.png
- x_bows_dmg_0.png
- x_bows_dmg_1.png
- x_bows_dmg_2.png
- x_bows_dmg_3.png
- x_bows_dmg_4.png
- x_bows_dmg_5.png
- x_bows_dmg_6.png
- x_bows_dmg_7.png
- x_bows_dmg_8.png
- x_bows_dmg_9.png

### Sounds

**Creative Commons License, EminYILDIRIM**, https://freesound.org

- x_bows_bow_load.1.ogg
- x_bows_bow_load.2.ogg
- x_bows_bow_load.3.ogg

**Creative Commons License, bay_area_bob**, https://freesound.org

- x_bows_bow_loaded.ogg

**Creative Commons License**, https://freesound.org

- x_bows_bow_shoot_crit.ogg

**Creative Commons License, robinhood76**, https://freesound.org

- x_bows_arrow_hit.1.ogg
- x_bows_arrow_hit.2.ogg
- x_bows_arrow_hit.3.ogg

**Creative Commons License, brendan89**, https://freesound.org

- x_bows_bow_shoot.1.ogg

**Creative Commons License, natty23**, https://freesound.org

- x_bows_arrow_successful_hit.ogg

**Creative Commons License, Shamewap**, https://freesound.org

- x_bows_quiver.1.ogg
- x_bows_quiver.2.ogg
- x_bows_quiver.3.ogg
- x_bows_quiver.4.ogg
- x_bows_quiver.5.ogg
- x_bows_quiver.6.ogg
- x_bows_quiver.7.ogg
- x_bows_quiver.8.ogg
- x_bows_quiver.9.ogg

### Models

**LGPL-2.1-or-later, by SaKeL**

- x_bows_arrow.obj
- x_bows_arrow.blend

**Original model by MirceaKitsune (CC BY-SA 3.0).**
**Various alterations and fixes by kilbith, sofar, xunto, Rogier-5, TeTpaAka, Desour, stujones11, An0n3m0us (CC BY-SA 3.0):**

Modified by SaKeL (added quiver):

- x_bows_3d_armor_character.b3d
- x_bows_3d_armor_character.blend
- x_bows_character.b3d
- x_bows_character.blend

## Installation

see: https://wiki.minetest.net/Installing_Mods
