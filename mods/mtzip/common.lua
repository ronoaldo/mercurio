
local function compare_bytes(b1, o1, b2, o2, len)
	for i=1,len do
		if b1:byte(i+o1) ~= b2:byte(i+o2) then
			return false
		end
	end

	return true
end

-- https://gist.github.com/mebens/938502
local function rshift(x, by)
	return math.floor(x / 2 ^ by)
end

local function lshift(x, by)
	return x * 2 ^ by
end

local function read_uint32(data, offset)
	return (
		string.byte(data,1+offset) +
		lshift(string.byte(data,2+offset), 8) +
		lshift(string.byte(data,3+offset), 16) +
		lshift(string.byte(data,4+offset), 24)
	)
end

local function read_uint16(data, offset)
	return (
		string.byte(data,1+offset) +
		lshift(string.byte(data,2+offset), 8)
	)
end

-- https://stackoverflow.com/a/32387452
local function bitand(a, b)
	local result = 0
	local bitval = 1
	while a > 0 and b > 0 do
	  if a % 2 == 1 and b % 2 == 1 then -- test the rightmost bits
		  result = result + bitval      -- set the current bit
	  end
	  bitval = bitval * 2 -- shift left
	  a = math.floor(a/2) -- shift right
	  b = math.floor(b/2)
	end
	return result
end

local function write_uint16(v)
	local b1 = bitand(v, 0xFF)
	local b2 = bitand( rshift(v, 8), 0xFF )
	return string.char(b1, b2)
end

local function write_uint32(v)
	local b1 = bitand(v, 0xFF)
	local b2 = bitand( rshift(v, 8), 0xFF )
	local b3 = bitand( rshift(v, 16), 0xFF )
	local b4 = bitand( rshift(v, 24), 0xFF )
	return string.char(b1, b2, b3, b4)
end

-- https://cs.opensource.google/go/go/+/master:src/archive/zip/struct.go;l=222-246;drc=master
local function fromDosTime(date, time)
	return {
		year = rshift(date, 9) + 1980,
		month = bitand( rshift(date, 5), 0x0F ),
		day = bitand(date, 0x1F),
		hour = rshift(time, 11),
		min = bitand( rshift(time, 5), 0x3F ),
		sec = bitand(time, 0x1F) * 2
	}
end

local function toDosTime(o)
	local date = o.day + lshift(o.month, 5) + lshift(o.year - 1980, 9)
	local time = (o.sec / 2) + lshift(o.min, 5) + lshift(o.hour, 11)

	return date, time
end

return {
	lfh_sig = string.char(80, 75, 3, 4),
	eocd_sig = string.char(80, 75, 5, 6),
	cd_sig = string.char(80, 75, 1, 2),
	zlib_header = string.char(0x78, 0xDA),
	compression_flag_deflate = 8,
	compression_flag_none = 0,
	compare_bytes = compare_bytes,
	read_uint16 = read_uint16,
	write_uint16 = write_uint16,
	read_uint32 = read_uint32,
	write_uint32 = write_uint32,
	fromDosTime = fromDosTime,
	toDosTime = toDosTime
}
