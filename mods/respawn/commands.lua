
local S = respawn.S



minetest.register_privilege( "teleport", {
	description = S("Can use /teleport to self teleport to a registered respawn point, global place, own place, last death place. Can teleport to xyz coordinates or close to another player in conjunction with the \"locate\" privilege.") ,
	give_to_singleplayer = false
} )



minetest.register_privilege( "teleport_other", {
	description = S("Can use /teleport_other to teleport any player to a registered respawn point, global place, own place (yours), last death place (their), or close to self. Can teleport to xyz coordinates or close to another player in conjunction with the \"locate\" privilege.") ,
	give_to_singleplayer = false
} )



minetest.register_privilege( "place", {
	description = S("Can use /set_place, /remove_place, /reset_places and /reset_all_player_places  to manage global places.") ,
	give_to_singleplayer = false
} )



minetest.register_privilege( "locate", {
	description = S("Can use advanced /where command to locate other player and output coordinate, extend /teleport and /teleport_other to support xyz coordinates and teleporting close to another player.") ,
	give_to_singleplayer = false
} )



minetest.register_privilege( "team", {
	description = S("Can use /set_team to assign a player to a team.") ,
	give_to_singleplayer = false
} )



-- Join an array of string
function join( tab , delimiter , last_delimiter , first , last )
	if not delimiter then delimiter = "" end
	
	if type( last_delimiter ) ~= "string" then
		last = first
		first = last_delimiter
		last_delimiter = delimiter
	end
	
	if not first then first = 1 end
	if not last then last = #tab end

	local str = tab[ first ] or ""
	
	for i = first + 1, last - 1 , 1 do
		str = str .. delimiter .. tab[ i ]
	end
	
	if #tab > 1 then
		str = str .. last_delimiter .. tab[ #tab ]
	end
	
	return str
end



minetest.register_chatcommand( "list_teams", {
	description = S("List all teams with their members."),
	func = function( player_name , param )
		local player = minetest.get_player_by_name( player_name )
		
		if not player then
			return false, S("Player not found!")
		end

		return respawn.output_teams( player )
	end
} )



minetest.register_chatcommand( "get_team", {
	description = S("Display the team of a player."),
	params = S("[<player name>]"),
	func = function( chat_player_name , param )
		local parts = string.split( param , " " )
		local player_name = parts[1] or nil
		
		if not player_name then
			player_name = chat_player_name
		end
		
		local player = minetest.get_player_by_name( player_name )
		
		if not player then
			return false, S("Player not found!")
		end
		
		local meta = player:get_meta()
		local team_name = meta:get_string( "team" )
		
		if team_name and team_name ~= "" then
			return true, S("@1 is in team @2.", player_name , team_name)
		else
			return true, S("@1 is not in any team.", player_name)
		end
	end
} )



minetest.register_chatcommand( "set_team", {
	description = S("Set the team of a player."),
	params = S("[<player name>] <team name>"),
	privs = { team = true },
	func = function( chat_player_name , param )
		local player_name , team_name
		local parts = string.split( param , " " )
		
		if #parts == 0 then
			return false, S("Missing arguments!")
		elseif #parts == 1 then
			team_name = parts[1]
		else
			player_name = parts[1]
			team_name = parts[2]
		end
		
		if not player_name then
			player_name = chat_player_name
		end
		
		local player = minetest.get_player_by_name( player_name )
		
		if not player then
			return false, S("Player not found!")
		end
		
		local meta = player:get_meta()
		
		if team_name and team_name ~= "" then
			meta:set_string( "team" , team_name )
			return true, S("Now @1 is in team @2.", player_name, team_name)
		else
			meta:set_string( "team" , "" )
			return true, S("Now @1 is removed from any team.", player_name)
		end
	end
} )



minetest.register_chatcommand( "list_respawns", {
	description = S("List all respawn points."),
	func = function( player_name , param )
		local player = minetest.get_player_by_name( player_name )
		
		if not player then
			return false, S("Player not found!")
		end

		return respawn.output_respawn_points( player )
	end
} )



minetest.register_chatcommand( "reset_respawns", {
	description = S("Reset respawn points."),
	privs = { server = true },
	func = function( player_name , param )
		if respawn.reset_respawns() then
			return true, S("Respawn points reset." )
		end
		
		return false, S("Something went wrong...")
	end
} )



minetest.register_chatcommand( "set_respawn", {
	description = S("Create a respawn point on your current player position. Without argument it set the first respawn point, with 'new' it appends a new respawn point."),
	params = S("[<spawn number>|new]"),
	privs = { server = true },
	func = function( player_name , param )
		local player = minetest.get_player_by_name( player_name )

		if not player then
			return false, S("Player not found!")
		end

		local parts = string.split( param , " " )
		local spawn_id
		
		if parts[1] == "new" then
			spawn_id = #respawn.respawn_points + 1
		else
			spawn_id = tonumber( parts[1] ) or 1
		end
		
		if respawn.set_respawn( spawn_id , {
			pos = player:get_pos() ,
			look = { h = player:get_look_horizontal() , v = player:get_look_vertical() }
		} ) then
			return true, S("Respawn point @1 set!", spawn_id)
		end
		
		return false, S("Something went wrong...")
	end
} )



minetest.register_chatcommand( "list_team_respawns", {
	description = S("List all team respawn points."),
	params = S("[<team name>]"),
	func = function( player_name , param )
		local player = minetest.get_player_by_name( player_name )
		
		if not player then
			return false, S("Player not found!")
		end

		local parts = string.split( param , " " )
		local team_name = parts[1] or nil

		return respawn.output_team_respawn_points( player , team_name )
	end
} )



minetest.register_chatcommand( "reset_team_respawns", {
	description = S("Reset team respawn points."),
	privs = { server = true },
	func = function( player_name , param )
		if respawn.reset_team_respawns() then
			return true, S("Team respawn points reset." )
		end
		
		return false, S("Something went wrong...")
	end
} )



minetest.register_chatcommand( "set_team_respawn", {
	description = S("Create a team respawn point on your current player position. Without argument it set the first respawn point, with 'new' it appends a new team respawn point."),
	params = S("<team name> [<spawn number>|new]"),
	privs = { server = true },
	func = function( player_name , param )
		local player = minetest.get_player_by_name( player_name )

		if not player then
			return false, S("Player not found!")
		end

		local parts = string.split( param , " " )
		local team_name = parts[1] or nil
		
		if not team_name then
			return false, S("Missing team name!")
		end
		
		local spawn_id
		
		if parts[2] == "new" then
			if respawn.team_respawn_points[ team_name ] then
				spawn_id = #respawn.team_respawn_points[ team_name ] + 1
			else
				spawn_id = 1
			end
		else
			spawn_id = tonumber( parts[2] ) or 1
		end
		
		if respawn.set_team_respawn( team_name , spawn_id , {
			pos = player:get_pos() ,
			look = { h = player:get_look_horizontal() , v = player:get_look_vertical() }
		} ) then
			return true, S("Team @1 respawn point @2 set!", team_name , spawn_id)
		end
		
		return false, S("Something went wrong...")
	end
} )



minetest.register_chatcommand( "list_places", {
	description = S("List all global places."),
	func = function( player_name , param )
		local player = minetest.get_player_by_name( player_name )
		
		if not player then
			return false, S("Player not found!")
		end

		return respawn.output_places( player )
	end
} )



minetest.register_chatcommand( "reset_places", {
	description = S("Reset all global places."),
	privs = { server = true , place = true },
	func = function( player_name , param )
		if respawn.reset_places() then
			return true, S("All global places removed." )
		end
		
		return false, S("Something went wrong...")
	end
} )



minetest.register_chatcommand( "set_place", {
	description = S("Create a new global named place on your current player position."),
	params = S("<place name ID> [<place full name with spaces>]"),
	privs = { place = true },
	func = function( player_name , param )
		local player = minetest.get_player_by_name( player_name )

		if not player then
			return false, S("Player not found!")
		end

		local parts = string.split( param , " " )
		local place_name = parts[1]
		local full_name = join( parts , " " , 2 )
		if full_name == "" then full_name = nil end

		if not place_name or place_name == "" then
			return false, S("Missing place name!")
		end

		if respawn.set_place( place_name , {
			pos = player:get_pos() ,
			look = { h = player:get_look_horizontal() , v = player:get_look_vertical() } ,
			full_name = full_name
		} ) then
			return true, S("Place \"@1\" set!", full_name or place_name )
		end

		return false, S("Something went wrong...")
	end
} )



minetest.register_chatcommand( "remove_place", {
	description = S("Remove a global place."),
	params = S("<place name>"),
	privs = { place = true },
	func = function( player_name , param )
		local parts = string.split( param , " " )
		local place_name = parts[1]

		if not place_name or place_name == "" then
			return false, S("Missing place name!")
		end

		if respawn.remove_place( place_name ) then
			return true, S("Place removed.")
		end

		return false, S("Something went wrong...")
	end
} )



minetest.register_chatcommand( "list_own_places", {
	description = S("List all personal places."),
	func = function( player_name , param )
		local player = minetest.get_player_by_name( player_name )
		
		if not player then
			return false, S("Player not found!")
		end

		return respawn.output_player_places( player )
	end
} )



minetest.register_chatcommand( "reset_all_players_places", {
	description = S("Reset all players' places."),
	privs = { server = true , place = true },
	func = function( player_name , param )
		if respawn.reset_all_players_places() then
			return true, S("All players' places removed." )
		end
		
		return false, S("Something went wrong...")
	end
} )



minetest.register_chatcommand( "reset_own_places", {
	description = S("Reset your personal places."),
	func = function( player_name , param )
		local player = minetest.get_player_by_name( player_name )

		if not player then
			return false, S("Player not found!")
		end

		if respawn.reset_player_places( player ) then
			return true, S("All your personal places removed." )
		end
		
		return false, S("Something went wrong...")
	end
} )



minetest.register_chatcommand( "set_own_place", {
	description = S("Create a new personal named place on your current player position. Without argument, it set your home."),
	params = S("<place name ID> [<place full name with spaces>]"),
	func = function( player_name , param )
		local player = minetest.get_player_by_name( player_name )

		if not player then
			return false, S("Player not found!")
		end

		local parts = string.split( param , " " )
		local place_name = parts[1]
		local full_name = join( parts , " " , 2 )
		if full_name == "" then full_name = nil end

		if not place_name or place_name == "" then
			place_name = "home"
		end

		if respawn.set_player_place( player , place_name , {
			pos = player:get_pos() ,
			look = { h = player:get_look_horizontal() , v = player:get_look_vertical() } ,
			full_name = full_name
		} ) then
			return true, S("Personal place \"@1\"set!", full_name or place_name )
		end

		return false, S("Something went wrong...")
	end
} )



minetest.register_chatcommand( "remove_own_place", {
	description = S("Remove a personal place."),
	params = S("<place name>"),
	func = function( player_name , param )
		local player = minetest.get_player_by_name( player_name )

		if not player then
			return false, S("Player not found!")
		end

		local parts = string.split( param , " " )
		local place_name = parts[1]

		if not place_name or place_name == "" then
			return false, S("Missing place!")
		end

		if respawn.remove_player_place( player , place_name ) then
			return true, S("Personal place removed.")
		end

		return false, S("Something went wrong...")
	end
} )



minetest.register_chatcommand( "where", {
	description = S("Find the place where you are, if there is one close enough. If you have the \"locate\" privilege you can also see coordinate and other people location."),
	params = S("[<player>]"),
	func = function( chat_player_name , param )
		local parts = string.split( param , " " )
		local player_name = parts[1] or chat_player_name
		
		local player = minetest.get_player_by_name( player_name )
		
		if not player or not chat_player_name then
			return false, S("Player not found!")
		end

		local has_locate = minetest.check_player_privs( chat_player_name, { locate = true } )
		
		if not has_locate and player_name ~= chat_player_name then
			return false, S("You can't locate other player (missing the \"locate\" privilege)!")
		end
		
		local pos = player:get_pos()
		local max_dist = 80
		
		-- Use the chat player for player place, it makes more sense
		place_name , place = respawn.closest_place_or_player_place( chat_player_name , pos , max_dist )

		if place_name then
			if has_locate then
				return true, S("@1 is near @2 (@3, @4, @5).", player_name, place.full_name or place_name, pos.x , pos.y, pos.z)
			end
			
			return true, S("@1 is near @2.", player_name, place.full_name or place_name)
		end

		if has_locate then
			return true, S("@1 is at (@2, @3, @4).", player_name, pos.x , pos.y, pos.z)
		end

		return false, S("No place found near you.")
	end
} )



minetest.register_chatcommand( "teleport", {
	description = S("Teleport to a map respawn point, a place or more. First argument can be respawn/spawn, team/team_respawn (for the respawn of the team of the player), place/global, own_place/own/home, death (for last death place), xyz (for coordinates), player (teleport close to another player), if omitted it searches for own place first, then for global place. Last argument can be avoided: for respawn it would move to a random respawn point, for own place it would go to the home."),
	params = S("<type> [<ID>] | xyz <x> <y> <z>"),
	privs = { teleport = true },
	func = function( player_name , param )
		local player = minetest.get_player_by_name( player_name )
		
		if not player then
			return false, S("Player not found!")
		end

		local parts = string.split( param , " " )
		local type = parts[1] or nil

		if not type then
			return false, S("Missing type!")
		end

		local id = parts[2] or nil

		if type == "respawn" or type =="spawn" then
			if respawn.teleport_to_respawn( player , tonumber( id ) , true ) then
				if id then
					return true, S("Teleported to the respawn n°@1.", id)
				else
					return true, S("Teleported to a random respawn point.")
				end
			end
		elseif type == "team_respawn" or type =="team" then
			if respawn.teleport_to_team_respawn( player , tonumber( id ) , true ) then
				if id then
					return true, S("Teleported to the team respawn n°@1.", id)
				else
					return true, S("Teleported to a random team respawn point.")
				end
			end
		elseif type == "place" or type == "global" then
			if respawn.teleport_to_place( player , id ) then
				return true, S("Teleported to @1.", respawn.places[ id ].full_name or id)
			end
		elseif type == "own" or type == "own_place" then
			if respawn.teleport_to_player_place( player , id ) then
				return true, S("Teleported to @1.", respawn.player_places[ player_name ][ id ].full_name or id)
			end
		elseif type == "death" then
			if respawn.teleport_to_player_last_death_place( player ) then
				return true, S("Teleported to last death place.")
			end
		elseif type == "xyz" then
			if not minetest.check_player_privs( player_name, { locate = true } ) then
				return false, S("You can't teleport to coordinate (missing the \"locate\" privilege)!")
			end
			
			if #parts < 4 then
				return false, S("Missing x y z arguments")
			end

			local pos = {
				x = tonumber( parts[2] ) ,
				y = tonumber( parts[3] ) ,
				z = tonumber( parts[4] )
			}
			
			if pos.x and pos.y and pos.z then
				if respawn.teleport( player , { pos = pos } ) then
					return true, S("Teleported to (@1, @2, @3).", pos.x , pos.y , pos.z)
				end
			end
		elseif type == "player" then
			if not minetest.check_player_privs( player_name, { locate = true } ) then
				return false, S("You can't teleport to a player (missing the \"locate\" privilege)!")
			end
			
			if not id then
				return false, S("Missing the other player name argument")
			end
			
			local other_player = minetest.get_player_by_name( id )
			
			if not other_player then
				return false, S("Player \"@1\" not found!", id)
			end

			if respawn.teleport_to_other_player( player , other_player ) then
				return true, S("Teleported close to @1.", id)
			end
		elseif respawn.teleport_to_player_place( player , type ) then
			return true, S("Teleported to @1.", respawn.player_places[ player_name ][ type ].full_name or type)
		elseif respawn.teleport_to_place( player , type ) then
			return true, S("Teleported to @1.", respawn.places[ type ].full_name or type)
		end
		
		return false, S("Respawn point or place not found!")
	end
} )



-- Mostly a copy/paste of /teleport command
minetest.register_chatcommand( "teleport_other", {
	description = S("Teleport another player to a map respawn point, a place or more. First argument is the player name, second argument can be respawn/spawn, team/team_respawn (for the respawn of the team of the player), place/global, own_place/own, death (for last death place), xyz (for coordinates), player (teleport close to another player), here (teleport close to you), if omitted it will search for global place. Last argument can be avoided: for respawn it would move to a random respawn point."),
	params = S("<player> [<type>] [<ID>] | <player> xyz <x> <y> <z>"),
	privs = { teleport = true , teleport_other = true },
	func = function( performer_name , param )
		local performer = minetest.get_player_by_name( performer_name )
		
		local parts = string.split( param , " " )
		local player_name = parts[1] or nil
		
		local player = minetest.get_player_by_name( player_name )
		
		if not player then
			return false, S("Player not found!")
		end

		local type = parts[2] or nil

		if not type then
			return false, S("Missing type!")
		end

		local id = parts[3] or nil

		if type == "respawn" or type =="spawn" then
			if respawn.teleport_to_respawn( player , tonumber( id ) , true ) then
				if id then
					minetest.chat_send_all( S("@1 teleported @2 to the respawn n°@3.", performer_name , player_name , id) )
					return true
				else
					minetest.chat_send_all( S("@1 teleported @2 to a random respawn point.", performer_name , player_name) )
					return true
				end
			end
		elseif type == "team_respawn" or type =="team" then
			if respawn.teleport_to_team_respawn( player , tonumber( id ) , true ) then
				if id then
					minetest.chat_send_all( S("@1 teleported @2 to the team respawn n°@3.", performer_name , player_name , id) )
					return true
				else
					minetest.chat_send_all( S("@1 teleported @2 to a random team respawn point.", performer_name , player_name) )
					return true
				end
			end
		elseif type == "place" or type == "global" then
			if respawn.teleport_to_place( player , id ) then
				minetest.chat_send_all( S("@1 teleported @2 to @3.", performer_name , player_name , respawn.places[ id ].full_name or id) )
				return true
			end
		elseif type == "own" or type == "own_place" then
			if not performer then
				return false, S("Player not found!")
			end

			if respawn.teleport_to_other_player_place( player , performer , id ) then
				minetest.chat_send_all( S("@1 teleported @2 to @3.", performer_name , player_name , respawn.player_places[ performer_name ][ id ].full_name or id) )
				return true
			end
		elseif type == "death" then
			if respawn.teleport_to_player_last_death_place( player ) then
				minetest.chat_send_all( S("@1 teleported @2 to the last death place.", performer_name , player_name ) )
				return true
			end
		elseif type == "xyz" then
			if not minetest.check_player_privs( performer_name, { locate = true } ) then
				return false, S("You can't teleport other to coordinate (missing the \"locate\" privilege)!")
			end
			
			if #parts < 5 then
				return false, S("Missing x y z arguments")
			end

			local pos = {
				x = tonumber( parts[3] ) ,
				y = tonumber( parts[4] ) ,
				z = tonumber( parts[5] )
			}
			
			if pos.x and pos.y and pos.z then
				if respawn.teleport( player , { pos = pos } ) then
					minetest.chat_send_all( S("@1 teleported @2 to (@3, @4, @5).", performer_name , player_name , pos.x , pos.y , pos.z ) )
					return true
				end
			end
		elseif type == "player" then
			if not minetest.check_player_privs( performer_name, { locate = true } ) then
				return false, S("You can't teleport to a player (missing the \"locate\" privilege)!")
			end
			
			if not id then
				return false, S("Missing the other player name argument")
			end
			
			local other_player = minetest.get_player_by_name( id )
			
			if not other_player then
				return false, S("Player \"@1\" not found!", id)
			end

			if respawn.teleport_to_other_player( player , other_player ) then
				minetest.chat_send_all( S("@1 teleported @2 close to @3.", performer_name , player_name , id ) )
				return true
			end
		elseif type == "here" then
			if not performer then
				return false, S("Player not found!")
			end

			if respawn.teleport_to_other_player( player , performer ) then
				minetest.chat_send_all( S("@1 teleported @2 close to @3.", performer_name , player_name , performer_name ) )
				return true
			end
		elseif respawn.teleport_to_other_player_place( player , performer , type ) then
			minetest.chat_send_all( S("@1 teleported @2 to @3.", performer_name , player_name , respawn.player_places[ performer_name ][ type ].full_name or type) )
			return true
		elseif respawn.teleport_to_place( player , type ) then
			minetest.chat_send_all( S("@1 teleported @2 to @3.", performer_name , player_name , respawn.places[ type ].full_name or type) )
			return true
		end
		
		return false, S("Respawn point or place not found!")
	end
} )



minetest.register_chatcommand( "teleport_teams", {
	description = S("Teleport teams to their respective team respawn."),
	params = S("[<team1> [<team2> [...]]"),
	privs = { teleport = true , teleport_other = true },
	func = function( performer_name , param )
		local teams = string.split( param , " " )
		local teams_hash
		
		if #teams > 0 then
			teams_hash = {}
			
			for k, team_name in ipairs( teams ) do
				teams_hash[ team_name ] = true
			end
		end
		
		if respawn.teleport_teams_to_team_respawn( teams_hash ) then
			if #teams >= 2 then
				minetest.chat_send_all( S("@1 teleported @2 teams to their respawn.", performer_name , join( teams , S(", ") , S( " and " ) ) ) )
			elseif #teams >= 1 then
				minetest.chat_send_all( S("@1 teleported @2 team to its respawn.", performer_name , teams[1] ) )
			else
				minetest.chat_send_all( S("@1 teleported all teams to their respective respawn.", performer_name ) )
			end
			return true
		end
		
		return false, S("Respawn point or place not found!")
	end
} )



minetest.register_chatcommand( "list_deaths", {
	description = S("List all deaths of a player. Without argument it applies to the current player."),
	params = S("[<player name>]"),
	func = function( chat_player_name , param )
		local chat_player = minetest.get_player_by_name( chat_player_name )
		
		if not chat_player then
			return false, S("Player (chat) not found!")
		end

		local parts = string.split( param , " " )
		local player_name = parts[1] or nil

		return respawn.output_deaths( chat_player , player_name )
	end
} )

