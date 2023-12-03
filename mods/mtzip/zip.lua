local common, crc32 = ...

local ZippedFile = {}
local ZippedFile_mt = { __index = ZippedFile }

local function zip(file)
	local self = {
		headers = {},
		file = file
	}
	return setmetatable(self, ZippedFile_mt)
end

local function write_file(file, filename, data)
	local offset = file:seek("end")
	local compressed = false
	local date, time = common.toDosTime(os.date("*t"))
	local crc = crc32(data)

	local uncompressed_size = #data
	if uncompressed_size > 10 then
		compressed = true
		data = minetest.compress(data, "deflate", 9)
		-- strip zlib header
		data = string.sub(data, 3)
	end
	local compressed_size = #data
	file:write(common.lfh_sig)
	file:write(string.char(0x0A, 0x00)) -- Version needed to extract (minimum)
	file:write(string.char(0x00, 0x00)) -- General purpose bit flag

	if compressed then
		file:write(string.char(0x08, 0x00))
	else
		file:write(string.char(0x00, 0x00))
	end

	file:write(common.write_uint16(time)) --File last modification time
	file:write(common.write_uint16(date)) --File last modification date

	file:write(common.write_uint32(crc))
	file:write(common.write_uint32(compressed_size))
	file:write(common.write_uint32(uncompressed_size))

	file:write(common.write_uint16(#filename)) -- File name length (n)
	file:write(string.char(0x00, 0x00)) -- Extra field length (m)
	file:write(filename)

	file:write(data)

	return {
		-- header-data
		crc = crc,
		compressed_size = compressed_size,
		uncompressed_size = uncompressed_size,
		compressed = compressed,
		time = time,
		date = date,
		offset = offset
	}
end

local function write_cd(file, filename, header_data)
	file:write(common.cd_sig)
	file:write(string.char(0x00, 0x00)) -- Version made by
	file:write(string.char(0x0A, 0x00)) -- Version needed to extract (minimum)
	file:write(string.char(0x00, 0x00)) -- General purpose bit flag

	if header_data.compressed then
		file:write(string.char(0x08, 0x00))
	else
		file:write(string.char(0x00, 0x00))
	end

	file:write(common.write_uint16(header_data.time)) --File last modification time
	file:write(common.write_uint16(header_data.date)) --File last modification date

	file:write(common.write_uint32(header_data.crc))
	file:write(common.write_uint32(header_data.compressed_size))
	file:write(common.write_uint32(header_data.uncompressed_size))

	file:write(common.write_uint16(#filename)) -- File name length (n)
	file:write(string.char(0x00, 0x00)) -- Extra field length (m)
	file:write(string.char(0x00, 0x00)) -- File comment length (k)
	file:write(string.char(0x00, 0x00)) -- Disk number where file starts
	file:write(string.char(0x00, 0x00)) -- Internal file attributes
	file:write(string.char(0x00, 0x00, 0x00, 0x00)) -- External file attributes
	file:write(common.write_uint32(header_data.offset+0)) -- Relative offset of local file header
	file:write(filename)

	return 46 + #filename
end

local function write_eocd(file, count, offset, cd_size)
	file:write(common.eocd_sig)
	file:write(string.char(0x00, 0x00)) -- Number of this disk (or 0xffff for ZIP64)
	file:write(string.char(0x00, 0x00)) -- Disk where central directory starts (or 0xffff for ZIP64)
	file:write(common.write_uint16(count)) -- Number of central directory records on this disk (or 0xffff for ZIP64)
	file:write(common.write_uint16(count)) -- Total number of central directory records (or 0xffff for ZIP64)
	file:write(common.write_uint32(cd_size)) -- Size of central directory (bytes) (or 0xffffffff for ZIP64)
	file:write(common.write_uint32(offset)) -- Offset of start of central directory
	file:write(string.char(0x00, 0x00)) -- Comment length (n)
end

function ZippedFile:add(filename, data)
	self.headers[filename] = write_file(self.file, filename, data)
end

function ZippedFile:close()
	-- offset of cd
	local offset = self.file:seek("end")
	local cd_size = 0
	local count = 0
	for filename, header_data in pairs(self.headers) do
		cd_size = cd_size + write_cd(self.file, filename, header_data)
		count = count + 1
	end
	write_eocd(self.file, count, offset, cd_size)
end

return zip