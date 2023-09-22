
zip-library for minetest

![](https://github.com/BuckarooBanzay/mtzip/workflows/luacheck/badge.svg)
![](https://github.com/BuckarooBanzay/mtzip/workflows/test/badge.svg)
[![Coverage Status](https://coveralls.io/repos/github/BuckarooBanzay/mtzip/badge.svg?branch=master)](https://coveralls.io/github/BuckarooBanzay/mtzip?branch=master)
[![License](https://img.shields.io/badge/License-MIT%20and%20CC%20BY--SA%203.0-green.svg)](license.txt)
[![Download](https://img.shields.io/badge/Download-ContentDB-blue.svg)](https://content.minetest.net/packages/BuckarooBanzay/mtzip)

# Overview

Lets you use zip files from within a minetest mod (both reading and writing)

Supported versions:
* Does not currently support zip64 stuff, only the basics

Disclaimer:
* Some zip-constellations may not work, this mod isn't 100% spec-complete, PR's/issues welcome

# Usage

## Within a mod

Writing:
```lua
-- create a new zip file in the world directory
local f = io.open(minetest.get_worldpath() .. "/tmp.zip", "wb")
local z = mtzip.zip(f)

-- add a sample file with dummy content
z:add("test.txt", "test123")

-- close and finalize the zip file
z:close()
-- close the file (flush pending changes)
f:close()
```

Reading:
```lua
-- open a file in the world directory (can also be somewhere in the mod itself)
local f = io.open(minetest.get_worldpath() .. "/tmp.zip", "rb")
local z, err_msg = mtzip.unzip(f)
if not z then
    -- error-handling
    panic(err_msg)
end

-- retrieve metadata (returns nil if none found)
local cd = z:get_entry("test.txt")
-- returned data (example):
cd = {
    compressed_size = 0,
    uncompressed_size = 0,
    name = "",
    mtime = os.date("*t"),
    crc = 123456
}

-- retrieve content, second parameter is for crc-verification
local data, err_msg = z:get("test.txt", true)
if data then
    print(data)
else
    -- error-handling
    print(err_msg)
end

-- list filenames in the archive
local list = z:list()
for _, filename in ipairs(list) do
    print(filename)
end
```

## Bootstrap

The individual files or the whole directory can be embedded inside a mod as a submodule or plain folder
In this case you can bootstrap the library with this code:

```lua
local MP = minetest.get_modpath("my_cool_mod_that_uses_zip_stuff")
-- the mod has a subfolder named "mtzip" that contains this mod's files
local bootstrap = loadfile(MP.."/mtzip/bootstrap.lua")()
local mtzip = bootstrap(MP)
-- do stuff with "mtzip.zip" or "mtzip.unzip"
```

# Further reading

* https://en.wikipedia.org/wiki/ZIP_(file_format)

# License

* `crc32.lua` zlib
* Everything else: MIT
