-- Global respawn namespace
respawn = {}
respawn.path = minetest.get_modpath( minetest.get_current_modname() )
respawn.S = minetest.get_translator( "respawn" )

-- Load files
dofile( respawn.path .. "/storage.lua" )
dofile( respawn.path .. "/api.lua" )
dofile( respawn.path .. "/commands.lua" )

respawn.load()



minetest.register_on_respawnplayer( function( player )
	respawn.respawn( player )
	-- returning true has no effect despite what the doc tells
	return true
end )



minetest.register_on_newplayer( function( player )
	respawn.respawn( player )
	-- returning true has no effect despite what the doc tells
	return true
end )



minetest.register_on_punchplayer( function( player, hitter, time_from_last_punch, tool_capabilities, dir, damage )
	local hp = player:get_hp()
	
	if hp <= 0 or hp - damage > 0 or not hitter then return end

	if hitter:is_player() then
		respawn.death( player , {
			by_type = "player" ,
			by = hitter:get_player_name() ,
			using = hitter:get_wielded_item():get_name() ,
			damage = damage
		} )
	else
		local properties = hitter:get_properties()
		local luaEntity = hitter:get_luaentity()
		
		--[[ Debug to find some hidden names
		minetest.chat_send_all( "----- debug hitter's properties -----" )
		for k,v in pairs( properties ) do
			minetest.chat_send_all( "" .. k .. ": " .. tostring( v ) )
		end
		
		minetest.chat_send_all( "----- debug hitter's nametag attributes -----" )
		for k,v in pairs( hitter:get_nametag_attributes() ) do
			minetest.chat_send_all( "" .. k .. ": " .. tostring( v ) )
		end
		
		minetest.chat_send_all( "----- debug hitter:get_luaentity() -----" )
		for k,v in pairs( hitter:get_luaentity() ) do
			minetest.chat_send_all( "" .. k .. ": " .. tostring( v ) )
		end

		minetest.chat_send_all( "----- debug hitter:get_luaentity()'s meta table -----" )
		for k,v in pairs( getmetatable( hitter:get_luaentity() ) ) do
			minetest.chat_send_all( "" .. k .. ": " .. tostring( v ) )
		end

		minetest.chat_send_all( "----- debug hitter:get_luaentity()'s meta table's __index -----" )
		for k,v in pairs( getmetatable( hitter:get_luaentity() ).__index ) do
			minetest.chat_send_all( "" .. k .. ": " .. tostring( v ) )
		end

		minetest.chat_send_all( "----- debug hitter.name -----" .. ( hitter.name or "(none)" ) )
		minetest.chat_send_all( "----- debug hitter.nametag -----" .. ( hitter.nametag or "(none)" ) )
		minetest.chat_send_all( "----- debug hitter.nametag2 -----" .. ( hitter.nametag2 or "(none)" ) )
		minetest.chat_send_all( "----- debug hitter:get_luaentity().name -----" .. ( hitter:get_luaentity().name or "(none)" ) )
		minetest.chat_send_all( "----- debug hitter:get_luaentity().nametag -----" .. ( hitter:get_luaentity().nametag or "(none)" ) )
		minetest.chat_send_all( "----- debug hitter:get_luaentity().nametag2 -----" .. ( hitter:get_luaentity().nametag2 or "(none)" ) )
		minetest.chat_send_all( "----- debug properties.name -----" .. ( properties.name or "(none)" ) )
		minetest.chat_send_all( "----- debug properties.nametag -----" .. ( properties.nametag or "(none)" ) )
		minetest.chat_send_all( "----- debug properties.nametag2 -----" .. ( properties.nametag2 or "(none)" ) )
		--]]
		
		local name
		
		-- mobs_humans uses that, not sure how standard it is
		if luaEntity.given_name and luaEntity.given_name ~= "" and type( luaEntity.given_name ) == "string" then name = luaEntity.given_name
		-- aliveai uses that, not sure how standard it is
		elseif luaEntity.botname and luaEntity.botname ~= "" and type( luaEntity.botname ) == "string" then name = luaEntity.botname
		-- Never seen it set, but seems to me a good way to set an entity proper name
		elseif properties.name and properties.name ~= "" and type( properties.name ) == "string" then name = properties.name
		-- nametag2 is set by mobs_redo as a backup when changing nametag to display health, so it's reliable but rarely there
		elseif properties.nametag2 and properties.nametag2 ~= "" and type( properties.nametag2 ) == "string" then name = properties.nametag2
		-- nametag is not reliable, can be just the health display
		--elseif properties.nametag and properties.nametag ~= "" and type( properties.nametag ) == "string" then name = properties.nametag
		-- Usually, this is the generic name of the entity (its kind) rather than its proper name
		else name = luaEntity.name
		end
		
		respawn.death( player , {
			by_type = "entity" ,
			by = name ,
			using = hitter:get_wielded_item():get_name() ,
			damage = damage
		} )
	end
end )



minetest.register_on_player_hpchange( function( player, hp_change, reason )
	local hp = player:get_hp()
	local by_type
	local by
	
	if hp <= 0 or hp + hp_change > 0 then return end
	
	local pos = player:get_pos()
	
	if reason.type == "fall" then
		by_type = "fall"
	elseif reason.type=="drown" then
		by_type = "drown"
		local eye_pos = vector.add( { x = 0, z = 0, y = player:get_properties().eye_height } , pos )
		by = minetest.get_node( eye_pos ).name
	elseif reason.type == "node_damage" then
		-- from deathlist mod
		by_type = "node"
		local eye_pos = vector.add( { x = 0, z = 0, y = player:get_properties().eye_height } , pos )
		local killing_node_head_name = minetest.get_node( eye_pos ).name
		local killing_node_head = minetest.registered_nodes[ killing_node_head_name ]
		local killing_node_feet_name = minetest.get_node( pos ).name
		local killing_node_feet = minetest.registered_nodes[ killing_node_feet_name ]
		by = killing_node_feet_name
		
		if ( killing_node_head.node_damage or 0 ) > ( killing_node_feet.node_damage or 0 ) then
			by = killing_node_head_name
		end
	elseif reason.type == "punch" then
		-- do nothing, it should already be done by minetest.register_on_punchplayer()
		--by_type = "punch"
		return
	elseif reason.type == "set_hp" then
		-- maybe /killme
		by_type = "unknown"
	elseif reason.type == "respawn" then
		-- Usually, we don't get there because respawn give hp rather than removing them
		return
	else
		by_type = "unknown"
	end
	
	respawn.death( player , {
		by_type = by_type ,
		by = by ,
		damage = - hp_change
	} )
end )
