read_globals = {
	"dump",
	"vector",
	"VoxelArea",
	minetest = {
		fields = {
			add_node = {
				read_only = false
			},
			place_schematic = {
				read_only = false
			},
			registered_chatcommands = {
				read_only = false,
				other_fields = true
			}
		},
		other_fields = true
	}
}
globals = {"worldedit"}
