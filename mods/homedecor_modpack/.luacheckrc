unused_args = false

globals = {
	"homedecor",
    "homedecor_lighting",
    "homedecor_windows_and_treatments",
    "homedecor_roofing",
    "homedecor_misc",
    "homedecor_exterior",
    "homedecor_electrical",
    "homedecor_cobweb",
    "lavalamp",
    "lrfurn",
    "signs_lib",
    "homedecor_doors_and_gates",

    -- mod-deps
    "armor"
}

read_globals = {
	"minetest", "core",
	"vector", "ItemStack",
    "dump",

	-- Stdlib
	string = {fields = {"split", "trim"}},
	table = {fields = {"copy", "getn"}},

    -- mod-deps
    "default",
    "unifieddyes",
    "player_api",
    "screwdriver",
    "hopper",
    "mesecon",
    "skins",
    "stairsplus",
    "creative",
    "doors",
    "i3",
}