
local pos = { x=0, y=0, z=0 }
mtt.emerge_area(pos, pos)

mtt.register("timestamp parsing", function(callback)
    local date = 21621
    local time = 23636
    local o = mtzip.fromDosTime(date, time)

    local d2, t2 = mtzip.toDosTime(o)
    assert(date == d2)
    assert(time == t2)
    callback()
end)

mtt.register("creates valid checksums", function(callback)
    local crc = mtzip.crc32("teststr")
    assert(615670416 == crc)
    callback()
end)

mtt.register("reading a simple zip file", function(callback)
    local filename = minetest.get_modpath("mtzip") .. "/test/out2.zip"
    local f = io.open(filename, "rb")
    local z = mtzip.unzip(f)
    local data = z:get("crc32.lua", true)
    f:close()
    assert(#data == 5996, "content-length mismatch")
    callback()
end)

mtt.register("reading a bx-exported zip file", function(callback)
    local filename = minetest.get_modpath("mtzip") .. "/test/scifi_lamp_small.zip"
    local f = io.open(filename, "rb")
    local z = mtzip.unzip(f)
    assert(z:get_entry("schema.json") ~= nil, "schema.json not found")
    assert(z:get_entry("schemapart_0_0_0.json") ~= nil, "schemapart_0_0_0.json not found")
    local data = z:get("mods.json", true)
    local mods = minetest.parse_json(data)
    assert(#mods == 1, "mods.json list count wrong")

    local list = z:list()
    assert(#list == 3)

    f:close()
    callback()
end)

mtt.register("creating a zip file", function(callback)
    local f = io.open(minetest.get_worldpath() .. "/stage1.zip", "wb")
    local z = mtzip.zip(f)
    z:add("test.txt", "abcdefghijklmnopqrstuvwxyz")
    z:close()
    callback()
end)
