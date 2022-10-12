
-- Maybe those storage helpers should have their own mod?

local storage_base_path = minetest.get_worldpath() .. "/"
local storage_ext = "." .. minetest.get_current_modname() .. ".db"
storage_files = {}

respawn.load_db = function( key )
	local file = storage_files[ key ]
	
	if file then
		file:seek( "set" , 0 )
	else
		local file_path = storage_base_path .. key .. storage_ext
		file = io.open( file_path , "r+" )
		
		if not file then
			return nil
		end		
		
		storage_files[ key ] = file
	end
	
	-- We only load the first line, after that line, there is garbage, see .save_db() comment.
	local str = file:read( "*l" )
	local value
	
	if str and str ~= "" then
		value = minetest.parse_json( str )
		if value then
			return value
		end
	end
	
	return nil
end



respawn.save_db = function( key , value )
	local file = storage_files[ key ]
	
	if file then
		file:seek( "set" , 0 )
	else
		local file_path = storage_base_path .. key .. storage_ext
		file = io.open( file_path , "w+" )
		
		if not file then
			error( "Can't create file: " .. file_path )
		end		
		
		storage_files[ key ] = file
	end

	-- We can't truncate files in Lua, and that sucks big time...
	-- So to improve perf and not opening/closing/overwriting files everytime something needs to be written we use this trick:
	-- we add a new line after writing JSON.
	-- When loading, we only load the first line.
	file:write( minetest.write_json( value ) , "\n" )
end

