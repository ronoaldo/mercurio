# Lumberjack

A Mod for tree harvesting and planting!  
Chop down the entire tree by removing the bottom piece of the tree trunk.

This mod fulfils several aspects:

- New players are trained to always fell trees completely and replace them with
  saplings (education for sustainability)
- Trained players get lumberjack "skills" to fell trees more efficiently
  (based on ideas from TreeCapitator and several Timber mods)
- No parts of trees hanging in the air any more
  

This mod allows to completely fell trees by destroying only one block.
The whole tree is harvested and moved to the player's inventory or
alternatively, the tree trunk items are dropped. See 'settingtypes.txt'
for configuration options.
But therefore, some lumberjack skills are needed. New player normally will
not get the necessary skills immediately, they have to harvest the tree from
the top, block by block "to improve their skills".

There are two configuration possibilities:

1. All players get directly lumberjack skills
2. Players have to collect points to get lumberjack skills

Points have to be collected by harvesting tree blocks *AND* planting saplings.
The default setting is 400 which means, you have to harvest more then 400 tree
blocks and plant more then 66 (400/6) saplings to get lumberjack skills.

The configuration can be changed directly in the file 'settingtypes.txt' or
by means of the Minetest GUI.

The mod provides two chat commands:

- `/lumberjack` to retrieve your lumberjack skill status. This command can be used
  by each player.
- `/set_lumberjack_points <name> <points>` to set the lumberjack points of
  a player. You need `server` privs to be able to use this command.
  Ex1: `/set_lumberjack_points Tom 400` sets Tom back to starting conditions
  Ex2: `/set_lumberjack_points Susan 0` gives Susan all lumberjack skills

Some technical aspects:

- `param1` of the nodes data is used to distinguish between grown trees and
  placed tree blocks so that this mod will not have any impact to buildings
  or other objects based on tree blocks
- an API function allows to register additional trees from other mods,
  which is quite simple


## Dependencies
optional: moretrees, ethereal, default

# License
Copyright (C) 2018-2022 Joachim Stolberg
Code: Licensed under the GNU LGPL version 2.1 or later.
See LICENSE.txt and http://www.gnu.org/licenses/lgpl-2.1.txt
Sound is taken from Hybrid Dog (TreeCapitator)

# History
v0.1 - 07/Apr/2018 - Mod initial created  
v0.2 - 08/Apr/2018 - Priv 'lumberjack' added, digging of trees from the top only added, tool wearing added  
v0.3 - 09/Apr/2018 - Harvesting points for placing saplings and destroying tree blocks added to reach lumberjack privs  
v0.4 - 16/Apr/2018 - Stem steps added  
v0.5 - 17/Apr/2018 - protection bug fixed, further improvements  
v0.6 - 07/Jan/2020 - screwdriver bugfix  
v0.7 - 27/May/2020 - ethereal bugfix  
v0.8 - 29/Jul/2020 - fake player bugfix  
v1.0 - 19/Mar/2021 - remove the lumberjack privs due to minetest engine issues  
v1.1 - 29/Jan/2022 - Add DE translation and "drop item" option  