globals = {
	"placeholder"
}

read_globals = {
	-- Stdlib
	string = {fields = {"split", "trim"}},
	table = {fields = {"copy", "getn"}},

	-- Minetest
	"minetest",
	"vector", "ItemStack",
	"dump", "dump2",
	"AreaStore",
	"VoxelArea",

	-- opt deps
	"mtt"
}
