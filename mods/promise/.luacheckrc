globals = {
	"Promise",
	"minetest" -- for testing
}

read_globals = {
	-- Stdlib
	string = {fields = {"split", "trim"}},
	table = {fields = {"copy", "getn"}},

	-- Minetest
	"vector", "ItemStack",
	"dump", "dump2",
	"AreaStore",
	"VoxelArea",

	-- opt deps
	"mtt"
}
