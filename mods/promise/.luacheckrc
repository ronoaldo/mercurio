std = "min+minetest"

globals = {
	"Promise",
	"minetest" -- for testing
}

read_globals = {
	-- missing from minetest std
	"unpack",
	-- opt deps
	"mtt", "fakelib"
}
