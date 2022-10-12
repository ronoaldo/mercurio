

## Respawn

-- Manage respawn points, interesting places, teleportation and death records


### Features

* Create/manage as many respawn points you want, to be used randomly (e.g. on player death or first connection)
* Create/manage global map place
* Each player can have its own personal places (stored and used separately from the global places)
* Each place and respawn retains not only the position, **but also a direction where to look**,
  ideal for creating great spot on the map where you already look at the right thing once teleported
* Place have a short name (i.e. an ID, without space) and a full name (that can have space)
* Check close to which place you are
* Powerful teleport command
	* teleport self or teleport other (with different privileges)
	* teleport to a respawn point, a global place, an own place, a coordinate, your last death place, or next to a player
* Every death are logged, with the reason and the place it happened (if closed to a known global place)
* List any type of places
* List any player death
* Have a setting allowing player to respawn to their personal own place named "home" instead of using a regular respawn point
  (disabled by default)



### Commands overview

For the complete syntax, see the in-game help.

* /list_teams: list all teams with their members
* /get_team: display the team of a player
* /set_team: set a team to a player
* /list_respawns: List all respawn points.
* /reset_respawns: Reset respawn points. Require the "server" privilege.
* /set_respawn: Create a respawn point on your current player position. Require the "server" privilege.
* /list_places: List all (global) places.
* /reset_places: Reset (global) places, i.e. remove all places at once. Require the "server" and "place" privileges.
* /set_place: Create a (global) place on your current player position, also accept a full name for tasteful place names.
  Require the "place" privilege.
* /remove_place: Remove one of the (global) place. Require the "place" privilege.
* /list_own_places: List all your personal own places.
* /reset_own_places: Reset all your personal own places, i.e. remove them all at once.
* /set_own_place: Create a personal own place on your current player position, also accept a full name for tasteful place names.
* /remove_own_place: Remove one of your personal own place.
* /reset_all_player_places: Remove all personal places of all players at once. Require the "server" and "place" privileges.
* /where: Tell you where you are, i.e. close to which place you are, if there is anyone close to you.
  Search on both your own places list and the global places list. Require no privileges, but with the "locate" privilege
  you can also see your coordinate and you can also locate any player.
* /teleport: teleport yourself to a respawn point, a global place, a personal own place, your last death place, a coordinate,
  or a player. Require the "teleport" privilege.
* /teleport_other: teleport anyone to a respawn point, a global place, one of your personal own place (not their),
  their last death place, a coordinate, close to you or any player. Require the "teleport" and "teleport_other" privileges.
* /teleport_teams: teleport teams to their respective team respawn.
* /list_deaths: list your or any player deaths with the cause and the place it occurs.



### Privileges

* teleport: Can use /teleport to self teleport to a registered respawn point, global place, own place, last death place.
  Can teleport to xyz coordinates or close to another player in conjunction with the "locate" privilege.
* teleport_other: Can use /teleport_other to teleport any player to a registered respawn point, global place, own place (yours),
  last death place (their), or close to self.
  Can teleport to xyz coordinates or close to another player in conjunction with the "locate" privilege.
* place: Can use /set_place, /remove_place, /reset_places and /reset_all_player_places  to manage global places.
* locate: Can use advanced /where command to locate other player and output coordinate, extend /teleport and /teleport_other
  to support xyz coordinates and teleporting close to another player.
* team: Can use /set_team to assign a player to a team.



### Settings

* enable_team_respawn: If enabled (default: disabled), players use their respective team respawn (if any).
  Note: This have greater priority than home respawn (if set).

* enable_home_respawn: if enabled (default: disabled), the player can respawn at their home instead of a regular respawn point.
  Note: should not be confused with the *sethome* mod's home, the player should have typed the command `set_own_place home`
  for this to work.

