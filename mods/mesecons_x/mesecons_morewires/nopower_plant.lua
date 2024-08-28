-- Just emits no power, always.


minetest.register_node("mesecons_morewires:nopower_plant", {
	drawtype = "plantlike",
	visual_scale = 1,
	tiles = {"jeija_nopower_plant.png"},
	inventory_image = "jeija_nopower_plant.png",
	paramtype = "light",
	is_ground_content = false,
	walkable = false,
	groups = {dig_immediate=3, mesecon = 2},
	light_source = minetest.LIGHT_MAX-9,
    	description="No Power Plant",
	selection_box = {
		type = "fixed",
		fixed = {-0.3, -0.5, -0.3, 0.3, -0.5+0.7, 0.3},
	},
	sounds = default.node_sound_leaves_defaults(),
	mesecons = {receptor = {
		state = mesecon.state.off
	}},
	on_blast = mesecon.on_blastnode,
})

minetest.register_craft({
    output = "mesecons_morewires:nopower_plant 1",
    recipe = {
	{"group:mesecon_conductor_craftable"},
	{"group:mesecon_conductor_craftable"},
	{"wool:black"},
    }
})
