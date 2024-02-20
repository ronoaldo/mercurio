local read_uint16, read_uint32, insert = mtzip.read_uint16, mtzip.read_uint32, table.insert

-- Local file header
local function read_local_file_header(data, offset)
	if not mtzip.compare_bytes(data, offset, mtzip.lfh_sig, 0, 4) then
		return nil, "invalid local file header signature"
	end

	local name_len = read_uint16(data, offset+26)
	local extra_len = read_uint16(data, offset+28)

	return {
		header_len = 30+name_len+extra_len,
		compression = read_uint16(data, offset+8)
	}
end

-- End of central directory record (EOCD)
local function read_eocd(data, offset)
	if not mtzip.compare_bytes(data, offset, mtzip.eocd_sig, 0, 4) then
		return nil, "invalid eocd signature"
	end

	return {
		cd_size = read_uint32(data, offset+12),
		cd_offset = read_uint32(data, offset+16),
		cd_count = read_uint16(data, offset+8)
	}
end

-- Central directory file header
local function read_cd(data, offset)
	if not mtzip.compare_bytes(data, offset, mtzip.cd_sig, 0, 4) then
		return nil, "invalid cd signature"
	end

	local time = read_uint16(data, offset+12)
	local date = read_uint16(data, offset+14)
	local name_len = read_uint16(data, offset+28)
	local extra_len = read_uint16(data, offset+30)
	local comment_len = read_uint16(data, offset+32)

	return {
		version = read_uint16(data, offset+4),
		version_needed = read_uint16(data, offset+6),
		compression = read_uint16(data, offset+10),
		mtime = mtzip.fromDosTime(date, time),
		crc32 = read_uint32(data, offset+16),
		compressed_size = read_uint32(data, offset+20),
		uncompressed_size = read_uint32(data, offset+24),
		file_offset = read_uint32(data, offset+42),
		name = data:sub(offset+46+1, offset+46+name_len),
		extra_len = extra_len,
		comment_len = comment_len,
		header_len = 46+name_len+extra_len+comment_len
	}
end

local UnzippedFile = {}
local UnzippedFile_mt = { __index = UnzippedFile }

function mtzip.unzip(file)
	if not file then
		return nil, "file is nil"
	end
	local size = file:seek("end")
	file:seek("set", size - 22) -- expects the comment-length to be 0
	local data = file:read(22)
	-- read eocd
	local eocd, err_msg = read_eocd(data, 0)
	if not eocd then
		return nil, err_msg
	end

	-- read cd
	file:seek("set", eocd.cd_offset)
	data = file:read(eocd.cd_size)

	-- filename -> cd
	local entries = {}

	-- read all entries from the cd
	local offset = 0
	for _=1,eocd.cd_count do
		local cd, cd_err_msg = read_cd(data, offset)
		if not cd then
			return nil, cd_err_msg
		end
		entries[cd.name] = cd
		offset = offset + cd.header_len
	end

	local self = {
		entries = entries,
		file = file
	}
	return setmetatable(self, UnzippedFile_mt)
end

function UnzippedFile:get_entry(filename)
	return self.entries[filename]
end

function UnzippedFile:get(filename, verify)
	local cd = self.entries[filename]
	if not cd then
		return nil, "no such file: '" .. filename .. "'"
	end

	self.file:seek("set", cd.file_offset)
	local header_data = self.file:read(30)
	local header, err_msg = read_local_file_header(header_data, 0)
	if not header then
		return nil, err_msg
	end

	self.file:seek("set", cd.file_offset+header.header_len)
	local data = self.file:read(cd.compressed_size)

	if header.compression == mtzip.compression_flag_deflate then
		data = minetest.decompress(mtzip.zlib_header .. data, "deflate")
	elseif header.compression ~= mtzip.compression_flag_none then
		return nil, "unsupported compression type: " .. header.compression
	end

	if verify then
		local crc = mtzip.crc32(data)
		if crc ~= cd.crc32 then
			return nil, "checksum mismatch, calculated: '"..crc.."' expected: '"..cd.crc32.."'"
		end
	end

	return data
end

function UnzippedFile:list()
	local list = {}
	for k in pairs(self.entries) do
		insert(list, k)
	end
	return list
end
