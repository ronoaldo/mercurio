
-- bootstrap function for use in the main mod and as a submodule/subdir
return function(MP)
	local common = loadfile(MP.."/common.lua")()
	local crc32 = loadfile(MP.."/crc32.lua")()

	return {
		crc32 = crc32,
		common = common,
		unzip = loadfile(MP.."/unzip.lua")(common, crc32),
		zip = loadfile(MP.."/zip.lua")(common, crc32)
	}
end