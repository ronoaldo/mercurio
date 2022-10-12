
local S = respawn.S



-- Load from storage or config
respawn.load = function()
	-- Respawn points
	respawn.respawn_points = respawn.load_db( "respawn" )
	
	if respawn.respawn_points == nil then
		-- If not found, then try to default to some values
		respawn.reset_respawns()
	end
	
	-- Per team respawn
	respawn.team_respawn_points = respawn.load_db( "team_respawn" ) or {}
	
	-- Server global named places/fine points of view
	respawn.places = respawn.load_db( "places" ) or {}
	
	-- Per player named places/fine points of view
	respawn.player_places = respawn.load_db( "player_places" ) or {}
	
	-- Per player death
	respawn.player_deaths = respawn.load_db( "player_deaths" ) or {}
end



-- Reset respawn to default value
respawn.reset_respawns = function()
	respawn.respawn_points = {}
	respawn.save_db( "respawn" , respawn.respawn_points )
	return true
end



-- data contains pos and look
respawn.set_respawn = function( spawn_id , data )
	spawn_id = spawn_id or 1
	respawn.respawn_points[ spawn_id ] = data
	respawn.save_db( "respawn" , respawn.respawn_points )
	return true
end



-- Remove all teams' respawns
respawn.reset_team_respawns = function()
	respawn.team_respawns = {}
	respawn.save_db( "team_respawns" , respawn.team_respawns )
	return true
end



respawn.set_team_respawn = function( team_name , spawn_id , data )
	spawn_id = spawn_id or 1
	if not team_name or type( team_name ) ~= "string" or team_name == "" then return false end
	if not respawn.team_respawn_points[ team_name ] then respawn.team_respawn_points[ team_name ] = {} end
	respawn.team_respawn_points[ team_name ][ spawn_id ] = data
	respawn.save_db( "team_respawn" , respawn.team_respawn_points )
	return true
end



respawn.reset_places = function()
	respawn.places = {}
	respawn.save_db( "places" , respawn.places )
	return true
end



respawn.set_place = function( place_name , data )
	if not place_name or type( place_name ) ~= "string" or place_name == "" then return false end
	respawn.places[ place_name ] = data
	respawn.save_db( "places" , respawn.places )
	return true
end



respawn.remove_place = function( place_name )
	if not place_name or type( place_name ) ~= "string" or place_name == "" then return false end
	respawn.places[ place_name ] = nil
	respawn.save_db( "places" , respawn.places )
	return true
end



-- Remove all players' places
respawn.reset_all_players_places = function()
	respawn.player_places = {}
	respawn.save_db( "player_places" , respawn.player_places )
	return true
end



-- Reset personal places for one player only
respawn.reset_player_places = function( player )
	if not player then return false end
	local player_name = player:get_player_name()
	if not player_name then return false end
	respawn.player_places[ player_name ] = {}
	respawn.save_db( "player_places" , respawn.player_places )
	return true
end



respawn.set_player_place = function( player , place_name , data )
	if not player then return false end
	local player_name = player:get_player_name()
	if not player_name then return false end
	if not place_name or type( place_name ) ~= "string" or place_name == "" then place_name = "home" end
	if not respawn.player_places[ player_name ] then respawn.player_places[ player_name ] = {} end
	respawn.player_places[ player_name ][ place_name ] = data
	respawn.save_db( "player_places" , respawn.player_places )
	return true
end



respawn.remove_player_place = function( player , place_name )
	if not player then return false end
	local player_name = player:get_player_name()
	if not player_name then return false end
	if not place_name or type( place_name ) ~= "string" or place_name == "" then return false end
	
	-- Nothing to do
	if not respawn.player_places[ player_name ] then return true end
	
	respawn.player_places[ player_name ][ place_name ] = nil
	respawn.save_db( "player_places" , respawn.player_places )
	return true
end



respawn.output_teams = function( chat_player )
	if not chat_player then return false end

	local chat_player_name = chat_player:get_player_name()
	if chat_player_name == "" then return false end
	
	local str = S("List of teams:")
	local teams = {}
	local players = minetest.get_connected_players()
	
	for k, player in ipairs( players ) do
		local player_name = player:get_player_name()
		local meta = player:get_meta()
		local team_name = meta:get_string( "team" )
		
		if team_name and team_name ~= "" then
			if not teams[ team_name ] then teams[ team_name ] = {} end
			table.insert( teams[ team_name ] , player_name )
		end
	end
	
	for team_name, members in pairs( teams ) do
		str = str .. "\n  " .. team_name .. ":"
		
		for k2, player_name in ipairs( members ) do
			str = str .. " " .. player_name
		end
	end
	
	minetest.chat_send_player( chat_player_name , str )
end



-- TODO: for instance it just counts how many there are
respawn.output_respawn_points = function( player )
	if not player then return false end

	local player_name = player:get_player_name()
	if player_name == "" then return false end
	
	minetest.chat_send_player( player_name , S("There are @1 respawn points." , #respawn.respawn_points) )
end



-- TODO: for instance it just counts how many there are
respawn.output_team_respawn_points = function( player , team_name )
	if not player then return false end

	local player_name = player:get_player_name()
	if player_name == "" then return false end
	
	if not team_name then
		local meta = player:get_meta()
		team_name = meta:get_string( "team" )
		if not team_name or team_name == "" then
			minetest.chat_send_player( player_name , S("Team not found.") )
		end
	end
	
	if not respawn.team_respawn_points[ team_name ] then
		minetest.chat_send_player( player_name , S("There are no team respawn points.") )
	else
		minetest.chat_send_player( player_name , S("There are @1 team respawn points." , #respawn.team_respawn_points[ team_name ]) )
	end
end



respawn.output_places = function( player )
	if not player then return false end

	local player_name = player:get_player_name()
	if player_name == "" then return false end
	
	local places_str = ""
	local count = 0
	
	for key , value in pairs( respawn.places ) do
		if value.full_name then
			places_str = places_str .. "\n  " .. value.full_name .. " [" .. key .. "]"
		else
			places_str = places_str .. "\n  [" .. key .. "]"
		end
		
		count = count + 1
	end
	
	if count == 0 then
		minetest.chat_send_player( player_name , S("There is no place defined.") )
	else
		minetest.chat_send_player( player_name , S("Global places:@1" , places_str ) )
	end
end



respawn.output_player_places = function( player )
	if not player then return false end

	local player_name = player:get_player_name()
	if player_name == "" then return false end
	
	if not respawn.player_places[ player_name ] then
		minetest.chat_send_player( player_name , S("You have no own place defined.") )
		return true
	end
	
	local places_str = ""
	local count = 0
	
	for key , value in pairs( respawn.player_places[ player_name ] ) do
		if value.full_name then
			places_str = places_str .. "\n  " .. value.full_name .. " [" .. key .. "]"
		else
			places_str = places_str .. "\n  [" .. key .. "]"
		end

		count = count + 1
	end
	
	if count == 0 then
		minetest.chat_send_player( player_name , S("You have no own place defined.") )
	else
		minetest.chat_send_player( player_name , S("Your personal places:@1" , places_str ) )
	end
end



respawn.teleport = function( player , point )
	if not player or not point then return false end

	player:set_pos( point.pos )
	
	if point.look then
		player:set_look_horizontal( point.look.h )
		player:set_look_vertical( point.look.v )
	end
	
	return true
end



respawn.teleport_to_respawn = function( player , spawn_id )
	spawn_id = spawn_id or math.random( #respawn.respawn_points )
	
	local point = respawn.respawn_points[ spawn_id ]
	if not point then point = respawn.respawn_points[ 1 ] end
	
	return respawn.teleport( player , point )
end



respawn.teleport_to_team_respawn = function( player , spawn_id )
	local meta = player:get_meta()
	local team_name = meta:get_string( "team" )
	
	if not team_name or team_name == "" or not respawn.team_respawn_points[ team_name ] then
		return false
	end
	
	spawn_id = spawn_id or math.random( #respawn.team_respawn_points[ team_name ] )
	
	local point = respawn.team_respawn_points[ team_name ][ spawn_id ]
	if not point then point = respawn.team_respawn_points[ team_name ][ 1 ] end
	
	return respawn.teleport( player , point )
end



-- Argument "teams" is a hash of { team1 = true , ... }
respawn.teleport_teams_to_team_respawn = function( teams )
	local meta , team_name , spawn_id , point
	local players = minetest.get_connected_players()
	
	for k, player in ipairs( players ) do
		meta = player:get_meta()
		team_name = meta:get_string( "team" )
		
		if team_name and team_name ~= "" and ( not teams or teams[ team_name ] == true ) and respawn.team_respawn_points[ team_name ] then
			spawn_id = math.random( #respawn.team_respawn_points[ team_name ] )
			point = respawn.team_respawn_points[ team_name ][ spawn_id ]
			respawn.teleport( player , point )
		end
	end
	
	return true
end



respawn.teleport_to_place = function( player , place_name )
	local point = respawn.places[ place_name ]
	return respawn.teleport( player , point )
end



respawn.teleport_to_player_place = function( player , place_name )
	if not player then return false end

	local player_name = player:get_player_name()
	if player_name == "" or not respawn.player_places[ player_name ] then return false end
	
	local point = respawn.player_places[ player_name ][ place_name ]
	return respawn.teleport( player , point )
end



respawn.teleport_to_other_player_place = function( player , other_player , place_name )
	if not player or not other_player then return false end

	local other_player_name = other_player:get_player_name()
	if other_player_name == "" or not respawn.player_places[ other_player_name ] then return false end
	
	local point = respawn.player_places[ other_player_name ][ place_name ]
	return respawn.teleport( player , point )
end



respawn.teleport_to_other_player = function( player , other_player )
	if not player or not other_player then return false end
	
	local pos = other_player:get_pos()
	
	-- Avoid to invade one's personal place ^^
	pos.x = pos.x + math.random( -2 , 2 )
	pos.y = pos.y + math.random( 0 , 1 )
	pos.z = pos.z + math.random( -2 , 2 )
	
	return respawn.teleport( player , { pos = pos } )
end



respawn.teleport_to_player_last_death_place = function( player )
	if not player then return false end

	local player_name = player:get_player_name()
	if player_name == "" or not respawn.player_deaths[ player_name ] or #respawn.player_deaths[ player_name ] == 0 then return false end
	
	local point = respawn.player_deaths[ player_name ][ #respawn.player_deaths[ player_name ] ] ;
	return respawn.teleport( player , point )
end



respawn.teleport_delay = function( player , type , id , delay )
	minetest.after( delay , function()
		if type == "respawn" then
			respawn.teleport_to_respawn( player , id )
		elseif type == "team_respawn" then
			respawn.teleport_to_team_respawn( player , id )
		elseif type == "place" then
			respawn.teleport_to_place( player , id )
		elseif type == "player_place" then
			respawn.teleport_to_player_place( player , id )
		elseif type == "last_death" then
			respawn.teleport_to_player_last_death_place( player )
		end
	end )
end



-- a and b are position
function squared_distance( a , b )
	return ( a.x - b.x ) * ( a.x - b.x ) + ( a.y - b.y ) * ( a.y - b.y ) + ( a.z - b.z ) * ( a.z - b.z )
end



respawn.closest_thing = function( list , pos , max_dist , max_squared_dist )
	if not max_dist and not max_squared_dist then max_dist = 64000 end
	if not max_squared_dist then max_squared_dist = max_dist * max_dist end
	
	local closest_squared_dist = max_squared_dist
	local closest_place
	local closest_place_name
	local squared_dist
	
	for place_name , place in pairs( list ) do
		squared_dist = squared_distance( pos , place.pos )
		
		if squared_dist < closest_squared_dist then
			closest_squared_dist = squared_dist
			closest_place = place
			closest_place_name = place_name
		end
	end
	
	return closest_place_name , closest_place , closest_squared_dist
end



respawn.closest_respawn = function( pos , max_dist , max_squared_dist )
	return respawn.closest_thing( respawn.respawn_points , pos , max_dist , max_squared_dist )
end



respawn.closest_team_respawn = function( player_name , pos , max_dist , max_squared_dist )
	local player = minetest.get_player_by_name( player_name )
	local meta = player:get_meta()
	local team_name = meta:get_string( "team" )
	
	if respawn.team_respawn_points[ team_name ] then
		return respawn.closest_thing( respawn.team_respawn_points[ team_name ] , pos , max_dist , max_squared_dist )
	end
end



respawn.closest_place = function( pos , max_dist , max_squared_dist )
	return respawn.closest_thing( respawn.places , pos , max_dist , max_squared_dist )
end



respawn.closest_player_place = function( player_name , pos , max_dist , max_squared_dist )
	if respawn.player_places[ player_name ] then
		return respawn.closest_thing( respawn.player_places[ player_name ] , pos , max_dist , max_squared_dist )
	end
end



respawn.closest_place_or_player_place = function( player_name , pos , max_dist )
	local place_name , place , square_dist , place_name2 , place2 , square_dist2
	
	-- Use the chat player for player place, it makes more sense
	place_name , place , square_dist = respawn.closest_player_place( player_name , pos , max_dist )
	
	if place_name then
		place_name2 , place2 , square_dist2 = respawn.closest_place( pos , nil , square_dist )

		if place_name2 then
			return place_name2 , place2 , square_dist2
		else
			return place_name , place , square_dist
		end
	else
		return respawn.closest_place( pos , max_dist )
	end
end



respawn.respawn = function( player )
	-- We use a delay because returning true has no effect despite what the doc tells
	-- so we teleport after the regular spawn
	
	if minetest.settings:get_bool("enable_team_respawn") then
		local meta = player:get_meta()
		local team_name = meta:get_string( "team" )
		if team_name and team_name ~= "" and respawn.team_respawn_points[ team_name ] and #respawn.team_respawn_points[ team_name ] > 0 then
			respawn.teleport_delay( player , "team_respawn" , math.random( #respawn.team_respawn_points[ team_name ] ) , 0 )
			return true
		end
	end

	if minetest.settings:get_bool("enable_home_respawn") then
		local player_name = player:get_player_name()
		if player_name and respawn.player_places[ player_name ] and respawn.player_places[ player_name ].home then
			respawn.teleport_delay( player , "player_place" , "home" , 0 )
			return true
		end
	end

	if #respawn.respawn_points > 0 then
		respawn.teleport_delay( player , "respawn" , math.random( #respawn.respawn_points ) , 0 )
		return true
	end
	
	-- If no respawn points defined, let the default behavior kick in... then add the actual default spawn to our list!
	minetest.after( 0.5 , function()
		local pos = player:get_pos()
		
		-- Check if there is still no respawn point and if the player is still available
		if #respawn.respawn_points > 0 or not pos then return end

		respawn.set_respawn( 1 , {
			pos = pos ,
			look = { h = player:get_look_horizontal() , v = player:get_look_vertical() }
		} )
	end )
end



respawn.add_death_log = function( player , data )
	if not player then return false end
	local player_name = player:get_player_name()
	if not player_name then return false end

	if not respawn.player_deaths[ player_name ] then respawn.player_deaths[ player_name ] = {} end
	table.insert( respawn.player_deaths[ player_name ] , data )
	respawn.save_db( "player_deaths" , respawn.player_deaths )
	return true
end



local function message_node_name( node_name )
	node_name = node_name:gsub( "[^:]+:" , "" )
	node_name = node_name:gsub( "_" , " " )
	return node_name
end



local function message_biome_name( biome_name )
	biome_name = biome_name:gsub( "[^:]+:" , "" )
	biome_name = biome_name:gsub( "_" , " " )
	return biome_name
end



respawn.death_message = function( player_name , data )
	local place = S("at some unknown place")
	
	if data.place and data.place ~= "" and type( data.place ) == "string" then
		place = "near " .. message_biome_name( data.place )
	elseif data.biome and data.biome ~= "" and type( data.biome ) == "string" then
		place = "near " .. message_biome_name( data.biome )
	end
	
	if data.by_type == "player" then
		if data.using and data.using ~= "" and type( data.using ) == "string" then
			return S("@1 was killed by @2, using @3, @4." , player_name , data.by , message_node_name( data.using ) , place )
		else
			return S("@1 was killed by @2 @3." , player_name , data.by , place )
		end
	
	elseif data.by_type == "entity" then
		-- For instance there is no difference between player and entity death messages
		-- Also it's worth noting that we need to use message_node_name() because sometime we got an entity type as name (e.g. mobs_xxx:mob_type)
		if data.using and data.using ~= "" and type( data.using ) == "string" then
			return S("@1 was killed by @2, using @3, @4." , player_name , message_node_name( data.by ) , message_node_name( data.using ) , place )
		else
			return S("@1 was killed by @2 @3." , player_name , message_node_name( data.by ) , place )
		end
	
	elseif data.by_type == "fall" then
		return S("@1 has fallen @2." , player_name , place )
	
	elseif data.by_type == "drown" then
		if data.by and data.by ~= "" and type( data.by ) == "string" then
			return S("@1 has drown in @2, @3." , player_name , message_node_name( data.by ) , place )
		else
			return S("@1 has drown @2." , player_name , place )
		end
	
	elseif data.by_type == "node" then
		if data.by and data.by ~= "" and type( data.by ) == "string" then
			return S("@1 should not play with @2, @3." , player_name , message_node_name( data.by ) , place )
		else
			return S("@1 should not play with dangerous things @2." , player_name , place )
		end
	end

	return S("@1 was killed @2." , player_name , place )
end



respawn.death = function( player , data )
	if not player then return false end
	local player_name = player:get_player_name()
	if not player_name then return false end
	
	local pos = player:get_pos()
	data.pos = pos
	
	local place_name , place = respawn.closest_place( pos , 80 )
	
	if place then
		data.place = place.full_name or place_name
	end
	
	local biome_data = minetest.get_biome_data( pos )
	
	if biome_data then
		data.biome = minetest.get_biome_name( biome_data.biome )
	end
	
	respawn.add_death_log( player , data )
	minetest.chat_send_all( respawn.death_message( player_name , data ) )
	
	return true
end



respawn.output_deaths = function( chat_player , player_name )
	local chat_player_name = chat_player:get_player_name()
	if chat_player_name == "" then return false end
	
	if not player_name then player_name = chat_player_name end

	if not respawn.player_deaths[ player_name ] then
		minetest.chat_send_player( chat_player_name , S("@1 hasn't died already.", player_name ) )
		return true
	end
	
	local deaths_str = ""
	local count = 0
	
	for key , value in pairs( respawn.player_deaths[ player_name ] ) do
		deaths_str = deaths_str .. "\n  " .. key .. ": " .. respawn.death_message( player_name , value )
		count = count + 1
	end
	
	if count == 0 then
		minetest.chat_send_player( chat_player_name , S("@1 hasn't died already.") )
	else
		minetest.chat_send_player( chat_player_name , S("@1 has died @2 times: @3" , player_name , count , deaths_str ) )
	end
end

