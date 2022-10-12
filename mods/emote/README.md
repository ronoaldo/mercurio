Emote - a player emote API
##########################

This mod aims to provide an API for player model animations such
as sitting, waving, lying down, as well as some providing chat
commands for the player to use these "emotes".

## API

The emote API consists of several functions that allow mods to
manipulate the emote state of each player.

`bool emote.start(player, emotestring)`

Start the named emote for the named player. Returns false if
the emote is unknown or the emote could not be started. Returns
true otherwise.

`emote.stop(player)`

Stops any emote for the named player.

`emote.list()`

Lists known emotestring values.

`emote.attach_to_node(player, pos, locked)`

Attach the player to the node at pos. The attachment will be made using the
parameters provided in the `emote` table in the nodedef:
```
nodedef.emote = {
	emotestring = "sit",
	eye_offset = {x = 0, y = 0, z = 0},
	player_offset = {x = 0, y = 1/2, z = 0},
	look_horizontal_offset = 0,
}
```

if `locked` is `true`, then the player is fixed to the node and can only
move until he presses `jump`. While sitting the player can look around but
his character does not turn.

The player offset vector will be rotated to account for the node facedir.

## Commands

The emotes are all usable by players using chat commands:
/lay, /sleep, /sit, /point, /freeze, etc.

## TODO

The API currently only allows unattached emotes (ones where the
player can just move and cancel the emote). The API needs to
provide an additional function to allow attached emotes with
rotation and offset so that players can easily sit on chairs,
lie on beds or emote-interact with machines (e.g. point emote
when interacting with a node).

## Can I sit on stair blocks with this?

The patch file `sit-on-stairs.patch` in this project is an example
patch for minetest_game that will allow a player to right-click stair
nodes and sit on them as if they were seats.

## License

Copyright (C) 2016 - Auke Kok <sofar@foo-projects.org>
LGPL-2.1
