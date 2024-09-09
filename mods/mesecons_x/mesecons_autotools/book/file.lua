mesecons_autotools.rand = PcgRandom(2);


function generate_file_name(user)
        local days = minetest.get_day_count()
        local sec = minetest.get_gametime()
        local rand = math.abs(mesecons_autotools.rand:next())
        local file = "circuit-"..user.."-"..sec.."-" .. rand
        return file
end

function generate_file_name_fsm(user)
        local days = minetest.get_day_count()
        local sec = minetest.get_gametime()
        local rand = math.abs(mesecons_autotools.rand:next())
        local file = "fsm-"..user.."-"..sec.."-" .. rand
        return file
end


function generate_file_name_library(user)
        local days = minetest.get_day_count()
        local sec = minetest.get_gametime()
        local rand = math.abs(mesecons_autotools.rand:next())
        local file = "library-"..user.."-"..sec.."-" .. rand
        return file	
end

local path = minetest.get_worldpath() .. "/circuits/"

function save_table_to_file(filename,tab)
                minetest.mkdir(path)
                local file, err = io.open(path .. filename, "wb")
		if err ~= nil then
			-- player_notify(name, "Could not save file to \"" .. filename .. "\"")
                        print ("mesecons_autotools: ERROR: file save error")
			return
		end
                local result = minetest.serialize(tab)
                
		file:write(result)
		file:flush()
		file:close()        
end


function read_table_from_file(filename)
        minetest.mkdir(path)
        local file, err = io.open(path .. filename, "rb")
        if err ~= nil then
                -- notify
                print ("mesecons_autotools: ERROR: file read error")
                return nil
        end
        
        local value = file:read("*a")
        file:close()
        
        local tab = minetest.deserialize(value)
        return tab
end



